---
name: deploy-manager
description: 프로젝트 배포 관리 스킬. 단일/다중 프로젝트 배포, 환경별 배포, 롤백을 담당합니다. "/deploy", "배포해줘", "롤백해줘" 요청 시 사용.
context: fork
allowed-tools:
  - Bash
  - Read
  - Write
  - Grep
  - Glob
---

# Deploy Manager Skill

프로젝트 배포를 자동화하고 관리하는 스킬입니다.

## 명령어

| 명령어 | 설명 |
|--------|------|
| `/deploy [project]` | 단일 프로젝트 프로덕션 배포 |
| `/deploy all` | 전체 프로젝트 배포 (오케스트레이터 연동) |
| `/deploy [project] --env [환경]` | 환경별 배포 (dev/staging/prod) |
| `/deploy preview [project]` | 프리뷰 배포 (Vercel) |
| `/deploy rollback [project]` | 이전 버전으로 롤백 |
| `/deploy status` | 배포 상태 확인 |
| `/deploy history [project]` | 배포 이력 조회 |

## 지원 프로젝트 유형

| 유형 | 배포 방법 | 프로젝트 |
|------|----------|---------|
| **nextjs** | Vercel | home, home-krdn, ai-note-taking |
| **npm-package** | npm publish | claude-code-auto |
| **docker-compose** | docker compose | docker-n8n, news-sentiment-analyzer |
| **express** | PM2 / Docker | gonsai2 |

## 환경 설정

### 환경 종류
| 환경 | 설명 | 용도 |
|------|------|------|
| **dev** | 개발 환경 | 로컬 테스트 |
| **staging** | 스테이징 | 배포 전 검증 |
| **prod** | 프로덕션 | 실제 서비스 |

### 환경 설정 파일
```
~/.claude/skills/deploy-manager/
├── SKILL.md
├── config/
│   └── environments.json    # 환경별 설정
└── scripts/
    ├── deploy.sh           # 배포 스크립트
    └── rollback.sh         # 롤백 스크립트
```

## 배포 프로세스

### 1. 사전 검증
```
요청: /deploy ai-note-taking

1. 프로젝트 경로 확인
2. git 상태 확인 (uncommitted changes 경고)
3. 현재 브랜치 확인 (main/master 권장)
4. 빌드 테스트 실행
5. 시스템 상태 확인 (system-check 연동)
```

### 2. 배포 실행
```
6. 현재 버전 백업 (롤백용)
7. 배포 명령 실행
8. 헬스체크 수행
9. 배포 결과 기록
10. notify-important로 알림
```

### 3. 롤백 (실패 시)
```
11. 이전 버전 복원
12. 서비스 재시작
13. 헬스체크 확인
14. 실패 원인 보고
```

## 프로젝트별 배포 명령

### Next.js 프로젝트 (Vercel)
```bash
# 프로덕션 배포
cd /path/to/project
npm run build          # 로컬 빌드 테스트
vercel --prod          # 프로덕션 배포

# 프리뷰 배포
vercel                 # 프리뷰 URL 생성
```

### Docker Compose 프로젝트
```bash
# docker-n8n 배포
cd /home/gon/docker-n8n
docker compose pull    # 이미지 업데이트
docker compose up -d   # 서비스 재시작

# 헬스체크
docker compose ps
curl -s http://localhost:5678/healthz
```

### NPM 패키지
```bash
# claude-code-auto 배포
cd /data/home-data/projects/ai/claude-code-auto
npm run build
npm version patch      # 버전 업
npm publish            # npm 배포
```

## 롤백 전략

### Vercel 롤백
```bash
# 이전 배포로 롤백
vercel rollback [deployment-url]

# 특정 버전으로 롤백
vercel alias set [previous-deployment] [domain]
```

### Docker 롤백
```bash
# 이전 이미지로 롤백
docker compose down
docker compose pull [previous-tag]
docker compose up -d
```

### NPM 롤백
```bash
# npm에서 버전 deprecate
npm deprecate [package]@[version] "reason"

# 이전 버전 재배포
git checkout [previous-tag]
npm publish
```

## 보고 형식

```markdown
## 배포 결과

### 프로젝트: [프로젝트명]
**환경**: production | staging | development
**상태**: ✅ 성공 | ⚠️ 경고 | ❌ 실패
**시간**: 2026-01-08 12:00:00

### 배포 정보
- 이전 버전: v1.2.3
- 새 버전: v1.2.4
- 배포 URL: https://...
- 소요시간: 45초

### 헬스체크
- 상태: OK
- 응답시간: 120ms

### 변경사항
[최근 커밋 목록]

### 롤백 명령
\`/deploy rollback ai-note-taking\`
```

## 배포 이력 관리

배포 이력은 다음 파일에 저장됩니다:
```
~/.claude/frameworks/krdn-claude/knowledge/box/deployments.json
```

### 필수: 배포 완료 시 자동 기록

**배포가 완료되면 반드시 다음 작업을 수행하세요:**

1. **deployments.json 업데이트**
   - 새 배포 기록 추가
   - statistics 업데이트
   - last_updated 갱신

2. **index.json 크로스 참조 업데이트**
   - by_project 인덱스에 배포 ID 추가
   - statistics 갱신

### 배포 기록 형식

```json
{
  "id": "deploy-{YYYYMMDD}-{NNN}",
  "project": "프로젝트명",
  "environment": "dev|staging|prod",
  "version": "새 버전",
  "previous_version": "이전 버전",
  "url": "배포 URL",
  "commit_hash": "git commit SHA",
  "status": "success|failure|rolled_back",
  "deployed_at": "ISO-8601",
  "duration_seconds": 45,
  "deployed_by": "claude",
  "related_decisions": ["adr-id"],
  "related_incidents": []
}
```

### 기록 시점
- **성공 시**: status: "success", 모든 정보 기록
- **실패 시**: status: "failure", 에러 원인 포함
- **롤백 시**: status: "rolled_back", 롤백 사유 포함

### 예시 코드

배포 완료 후 JSON 파일을 Read로 읽고, Write로 새 기록을 추가:

```
1. Read로 deployments.json 읽기
2. deployments 배열에 새 기록 추가
3. statistics.total_deployments 증가
4. statistics.by_status[status] 증가
5. Write로 저장
6. index.json의 by_project 업데이트
```

## 연동 시스템

- **orchestrator**: 전체 배포 시 도메인별 조율
- **system-check**: 배포 전 시스템 상태 확인
- **code-reviewer**: 배포 전 코드 리뷰 (선택)
- **notify-important**: 배포 결과 알림
- **context-manager**: 배포 컨텍스트 저장

## 안전 장치

### 배포 전 체크리스트
- [ ] git status clean (uncommitted changes 없음)
- [ ] 올바른 브랜치 (main/master)
- [ ] 빌드 성공
- [ ] 테스트 통과
- [ ] 시스템 리소스 충분
- [ ] 백업 완료

### 자동 롤백 조건
- 헬스체크 3회 연속 실패
- 배포 후 5분 내 에러율 급증
- 메모리/CPU 임계치 초과

## 주의사항

1. **프로덕션 배포**: 업무 시간 외 권장
2. **docker-n8n**: 프로덕션 서비스, 백업 필수
3. **환경변수**: `.env` 파일 확인 필요
4. **의존성**: 크로스 도메인 의존성 고려
5. **롤백 준비**: 항상 이전 버전 백업 유지
