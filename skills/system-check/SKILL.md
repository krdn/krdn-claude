---
name: system-check
description: Ubuntu 서버 전체 시스템 점검 및 문제 해결. 사용자가 "시스템 점검", "서버 상태 확인", "system check" 등을 요청할 때 사용.
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
