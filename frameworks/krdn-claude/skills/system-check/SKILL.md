---
name: system-check
description: Ubuntu 서버 전체 시스템 점검 및 문제 해결. 사용자가 "시스템 점검", "서버 상태 확인", "system check" 등을 요청할 때 사용.
context: fork
agent: haiku
allowed-tools:
  - Bash
  - Read
  - Grep
---

# Ubuntu Server System Check Skill

이 스킬은 Ubuntu 서버의 전체 시스템 상태를 점검하고 문제를 자동으로 해결합니다.

## sudo 권한

sudo가 필요한 명령은 사용자에게 확인 후 실행합니다.
passwordless sudo가 설정되어 있거나, 사용자가 직접 비밀번호를 입력해야 합니다.

## 1단계: 기본 시스템 상태 점검 (병렬 실행)

다음 명령들을 **병렬로** 실행하여 시스템 상태를 빠르게 파악합니다:

```bash
# 시스템 상태
systemctl is-system-running

# 실패한 서비스
systemctl --failed

# 디스크 사용량
df -h

# 메모리 및 SWAP
free -h

# 시스템 로드
uptime

# 최근 오류 로그
journalctl -p err -b --no-pager | tail -50

# Docker 컨테이너 상태
docker ps -a

# 온도 확인
sensors

# GPU 상태 (있는 경우)
nvidia-smi
```

## 2단계: 보안 점검 (병렬 실행)

```bash
# 방화벽 상태
sudo ufw status

# fail2ban 상태
sudo fail2ban-client status sshd

# SSH 실패 시도 횟수
cat /var/log/auth.log 2>/dev/null | grep -c "Failed password"

# 최근 로그인
last -5
```

## 3단계: 추가 점검 (병렬 실행)

```bash
# Docker 디스크 사용량
docker system df

# SSL 인증서 만료일
sudo certbot certificates 2>/dev/null | grep -E "(Certificate Name|Expiry Date)"

# 업데이트 가능한 패키지
apt list --upgradable 2>/dev/null | head -20

# 열린 포트
ss -tulpn | grep LISTEN
```

## 문제 해결 방법

### SWAP 과다 사용 (80% 이상)
```bash
sudo swapoff -a && sudo swapon -a
```

### 실패한 systemd 서비스
1. 서비스 상태 확인: `systemctl status [서비스명]`
2. 로그 확인: `journalctl -u [서비스명] -n 50`
3. docker-compose → docker compose 변경 필요한 경우 스크립트 수정
4. 서비스 재시작: `sudo systemctl restart [서비스명]`

### Docker 정리 (디스크 공간 확보)
```bash
docker system prune -a -f --volumes
```

### SSH 브루트포스 공격 감지 시
- fail2ban이 활성화되어 있는지 확인
- 차단된 IP 확인: `sudo fail2ban-client status sshd`

## 점검 결과 보고 형식

### 심각한 문제 (빨간색)
- 시스템 상태가 degraded인 경우
- SWAP 사용량 80% 이상
- 실패한 서비스 존재
- 디스크 사용량 90% 이상

### 주의 필요 (노란색)
- Docker 정리로 확보 가능한 공간이 10GB 이상
- SSL 인증서 만료 30일 이내
- 메모리 사용량 80% 이상

### 정상 (녹색)
- 위 항목 외 모든 것

## 결과 표시 예시

```
## 시스템 분석 결과

### 심각한 문제
| 문제 | 상태 | 설명 |
|------|------|------|
| **SWAP 과다 사용** | 97.5% | 8GB 중 7.8GB 사용 |

### 정상
| 항목 | 상태 |
|------|------|
| 디스크 | 루트 57% |
| CPU 온도 | 54.8°C |

### 권장 조치
1. SWAP 초기화: `sudo swapoff -a && sudo swapon -a`
```

---

## 4단계: 예측적 모니터링 (확장)

### 트렌드 분석 명령어

```bash
# CPU 사용량 추이 (최근 1시간)
sar -u 1 5 2>/dev/null || echo "sysstat 미설치"

# 메모리 사용량 추이
vmstat 1 5

# 디스크 I/O 추이
iostat -x 1 5 2>/dev/null || echo "sysstat 미설치"

# 네트워크 트래픽 추이
sar -n DEV 1 5 2>/dev/null || echo "sysstat 미설치"
```

### 예측 알림 임계치

| 지표 | 경고 | 위험 | 예측 기준 |
|------|------|------|----------|
| 디스크 | 70% | 85% | 일일 증가율 × 7일 |
| 메모리 | 70% | 85% | 피크 사용량 추세 |
| CPU | 70% | 90% | 5분 평균 부하 |
| SWAP | 50% | 80% | 메모리 압박 지표 |

### 예측 알림 예시

```markdown
## 예측 경고

### 디스크 공간 부족 예측
- 현재 사용량: 72%
- 일일 증가율: 0.5%
- 예상 포화일: 7일 후

### 권장 조치
1. 불필요한 로그 정리
2. Docker 이미지 정리
3. 오래된 백업 삭제
```

---

## 5단계: 자동 복구 (확장)

### 자동 복구 가능 항목

| 문제 | 자동 복구 | 명령어 |
|------|----------|--------|
| SWAP 과다 사용 | ✅ | `sudo swapoff -a && sudo swapon -a` |
| Docker 디스크 부족 | ✅ | `docker system prune -f` |
| 실패한 서비스 | ⚠️ 확인 후 | `sudo systemctl restart [서비스]` |
| 메모리 부족 | ⚠️ 캐시만 | `sync && echo 3 > /proc/sys/vm/drop_caches` |
| SSL 인증서 갱신 | ✅ | `sudo certbot renew` |

### 자동 복구 프로세스

```
1. 문제 감지
   ↓
2. 자동 복구 가능 여부 확인
   ↓
3. 사용자 확인 (위험한 작업)
   ↓
4. 복구 실행
   ↓
5. 결과 확인
   ↓
6. 인시던트 기록 (incidents.json)
   ↓
7. 알림 발송 (notify-important)
```

### 자동 복구 스크립트

```bash
# SWAP 자동 복구
auto_fix_swap() {
    local swap_usage=$(free | grep Swap | awk '{print int($3/$2 * 100)}')
    if [ "$swap_usage" -gt 80 ]; then
        echo "SWAP 사용량 $swap_usage% - 초기화 중..."
        sudo swapoff -a && sudo swapon -a
        echo "SWAP 초기화 완료"
    fi
}

# Docker 자동 정리
auto_clean_docker() {
    local docker_reclaimable=$(docker system df --format '{{.Reclaimable}}' | head -1)
    echo "Docker 정리 가능 공간: $docker_reclaimable"
    docker system prune -f
    echo "Docker 정리 완료"
}

# SSL 인증서 자동 갱신
auto_renew_ssl() {
    sudo certbot renew --quiet
    echo "SSL 인증서 갱신 시도 완료"
}
```

---

## 6단계: 인시던트 로그

### 인시던트 기록 위치
`~/.claude/frameworks/krdn-claude/knowledge/box/incidents.json`

### 필수: 문제 감지 시 자동 기록

**문제가 감지되면 반드시 다음 작업을 수행하세요:**

1. **incidents.json 업데이트**
   - 새 인시던트 기록 추가
   - severity에 따른 분류 (critical > warning > info)
   - statistics 업데이트
   - last_updated 갱신

2. **index.json 크로스 참조 업데이트**
   - by_project 인덱스에 인시던트 ID 추가 (해당 서비스가 특정 프로젝트에 연결된 경우)
   - statistics 갱신

3. **관련 학습 연결**
   - 인시던트 해결 시 새로운 학습이 발생하면 learnings.json에 기록
   - triggered_by_incident 필드로 연결

### 인시던트 구조

```json
{
  "id": "inc-{YYYYMMDD}-{NNN}",
  "timestamp": "ISO-8601",
  "severity": "critical|warning|info",
  "category": "disk|memory|cpu|service|security|network|swap",
  "service": "docker-n8n|system|nginx|프로젝트명",
  "description": "문제 설명",
  "metrics": {
    "value": 95,
    "threshold": 90,
    "unit": "%"
  },
  "auto_recovered": true,
  "recovery_action": "수행된 복구 조치",
  "resolved_at": "ISO-8601 또는 null",
  "notified": true,
  "related_project": "프로젝트명 또는 null",
  "related_learnings": []
}
```

### 기록 시점
- **Critical**: 즉시 기록 + notify-important 호출
- **Warning**: 기록 + 필요시 알림
- **Info**: 기록만 (통계용)

### 인시던트 명령어

```bash
# 인시던트 기록 추가 (jq 사용)
record_incident() {
    local incidents_file="$HOME/.claude/knowledge/box/incidents.json"
    local new_incident="$1"

    if command -v jq &> /dev/null; then
        jq ".incidents += [$new_incident]" "$incidents_file" > /tmp/incidents.tmp
        mv /tmp/incidents.tmp "$incidents_file"
    fi
}
```

---

## 7단계: 프로젝트 서비스 점검

### Docker 프로젝트 헬스체크

```bash
# docker-n8n 헬스체크
check_n8n() {
    echo "=== docker-n8n 상태 ==="
    cd /home/gon/docker-n8n
    docker compose ps
    curl -s http://localhost:5678/healthz && echo " - n8n OK" || echo " - n8n FAIL"
}

# news-sentiment-analyzer 헬스체크
check_news_analyzer() {
    echo "=== news-sentiment-analyzer 상태 ==="
    cd /data/home-data/projects/n8n/news-sentiment-analyzer2
    docker compose -f docker-compose.prod.yml ps
    curl -s http://localhost:3010/_stcore/health && echo " - Streamlit OK" || echo " - Streamlit FAIL"
}
```

### 전체 프로젝트 헬스체크

```bash
# 모든 프로덕션 서비스 점검
check_all_services() {
    echo "=== 프로덕션 서비스 헬스체크 ==="

    # docker-n8n
    curl -s -o /dev/null -w "n8n: %{http_code}\n" http://localhost:5678/healthz

    # news-sentiment-analyzer
    curl -s -o /dev/null -w "news-analyzer: %{http_code}\n" http://localhost:3010/_stcore/health

    echo "=== 헬스체크 완료 ==="
}
```

---

## 연동 시스템

- **monitor 에이전트**: 정기적 자동 점검 트리거
- **notify-important**: 문제 발견 시 알림 발송
- **deploy-manager**: 배포 후 헬스체크 연동
- **orchestrator**: 전체 시스템 상태 보고

## 점검 주기 권장

| 점검 유형 | 주기 | 자동화 |
|----------|------|--------|
| 기본 상태 | 5분 | cron/systemd timer |
| 보안 점검 | 1시간 | cron |
| 트렌드 분석 | 6시간 | cron |
| 전체 점검 | 1일 | systemd timer |

```bash
# crontab 예시
*/5 * * * * /home/gon/.claude/skills/system-check/scripts/quick-check.sh
0 * * * * /home/gon/.claude/skills/system-check/scripts/security-check.sh
```
