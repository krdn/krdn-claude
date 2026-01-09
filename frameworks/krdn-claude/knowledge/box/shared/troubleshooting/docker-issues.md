# Docker 문제 해결

## 일반적인 문제

### 1. 컨테이너가 시작되지 않음

**증상**: `docker compose up` 후 컨테이너 종료

**진단**:
```bash
docker compose logs [서비스명]
docker ps -a  # Exited 상태 확인
```

**해결**:
1. 로그에서 에러 메시지 확인
2. 환경 변수 누락 확인
3. 포트 충돌 확인: `ss -tulpn | grep [포트]`

### 2. 디스크 공간 부족

**증상**: `no space left on device`

**진단**:
```bash
docker system df
df -h
```

**해결**:
```bash
# 미사용 리소스 정리
docker system prune -a -f --volumes

# 특정 이미지만 삭제
docker image prune -a
```

### 3. 네트워크 연결 실패

**증상**: 컨테이너 간 통신 불가

**진단**:
```bash
docker network ls
docker network inspect [네트워크명]
```

**해결**:
1. 같은 네트워크에 있는지 확인
2. 서비스명으로 접근하는지 확인 (localhost X)
3. 포트 노출 확인

### 4. 권한 문제

**증상**: `permission denied`

**진단**:
```bash
ls -la [마운트 디렉토리]
docker exec [컨테이너] id
```

**해결**:
```bash
# 호스트 디렉토리 권한 변경
sudo chown -R 1000:1000 [디렉토리]

# 또는 docker-compose에서 user 지정
```

## 프로젝트별 이슈

### docker-n8n

| 문제 | 원인 | 해결 |
|------|------|------|
| DB 연결 실패 | PostgreSQL 미시작 | `docker compose up -d postgres` 먼저 실행 |
| 메모리 부족 | 워크플로우 과다 | NODE_OPTIONS에 메모리 제한 설정 |

### news-sentiment-analyzer

| 문제 | 원인 | 해결 |
|------|------|------|
| Streamlit 503 | 컨테이너 초기화 중 | 30초 대기 후 재시도 |
| 데이터 로드 실패 | 볼륨 마운트 오류 | 경로 확인 |

## 유용한 명령어

```bash
# 컨테이너 상태 확인
docker ps -a --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

# 실시간 로그
docker compose logs -f [서비스]

# 컨테이너 접속
docker exec -it [컨테이너] /bin/bash

# 리소스 사용량
docker stats
```

## 관련 문서
- [[N8N-Manager-Agent]]
- [[System-Check-Skill]]
