---
name: context-manager
description: 세션 컨텍스트 저장/복원 및 인수인계 자동화. "컨텍스트 저장", "세션 복원", "인수인계", "/context" 요청 시 사용.
---

# Context Manager Skill

세션별 작업 컨텍스트를 저장하고 복원하여 프로젝트 간 전환을 원활하게 합니다.

## 명령어

| 명령어 | 설명 |
|--------|------|
| `/context save [name]` | 현재 세션 컨텍스트 저장 |
| `/context restore [id]` | 이전 세션 복원 |
| `/context list` | 저장된 컨텍스트 목록 |
| `/context handoff` | 인수인계 문서 생성 |
| `/context delete [id]` | 컨텍스트 삭제 |

## 저장 위치

```
~/.claude/knowledge/
├── contexts/           # 세션 컨텍스트 JSON 파일
│   └── {id}.json
└── handoffs/           # 인수인계 마크다운 문서
    └── {timestamp}-summary.md
```

## 컨텍스트 구조

각 컨텍스트는 다음 정보를 포함합니다:

```json
{
  "id": "ctx-20260108-abc123",
  "name": "사용자 지정 이름 (선택)",
  "created_at": "2026-01-08T10:00:00Z",
  "updated_at": "2026-01-08T12:00:00Z",
  "project": {
    "path": "/path/to/project",
    "name": "project-name",
    "domain": "ai|n8n|web"
  },
  "summary": "이 세션에서 수행한 작업 요약",
  "files_modified": [
    "src/index.ts",
    "package.json"
  ],
  "decisions": [
    {
      "topic": "인증 방식",
      "decision": "JWT 사용",
      "reason": "stateless 특성으로 확장성 우수"
    }
  ],
  "todos": [
    "테스트 코드 추가",
    "문서화 업데이트"
  ],
  "blockers": [
    "API 키 발급 대기 중"
  ],
  "notes": "추가 메모사항"
}
```

## 사용 방법

### 1. 컨텍스트 저장 (`/context save`)

현재 작업 세션의 컨텍스트를 저장합니다.

**실행 단계:**
1. 현재 작업 디렉토리 확인
2. 최근 수정된 파일 목록 수집
3. 대화에서 주요 결정사항 추출
4. 미완료 작업(TODO) 식별
5. 컨텍스트 JSON 파일 생성

**예시:**
```
사용자: /context save 인증 기능 구현
Claude:
✅ 컨텍스트가 저장되었습니다.

📁 ID: ctx-20260108-auth
📍 프로젝트: ai-note-taking
📝 수정된 파일: 5개
🎯 결정사항: 2개
📋 TODO: 3개

복원하려면: /context restore ctx-20260108-auth
```

### 2. 컨텍스트 복원 (`/context restore`)

이전 세션의 컨텍스트를 불러옵니다.

**실행 단계:**
1. 컨텍스트 파일 로드
2. 프로젝트 정보 표시
3. 이전 결정사항 요약
4. 미완료 작업 알림
5. 작업 재개 준비

**예시:**
```
사용자: /context restore ctx-20260108-auth
Claude:
📂 컨텍스트 복원됨: 인증 기능 구현

## 프로젝트
- 경로: /data/home-data/projects/ai/ai-note-taking
- 도메인: AI

## 이전 작업 요약
JWT 기반 인증 시스템 구현 중. 로그인/로그아웃 API 완료.

## 주요 결정사항
1. JWT 사용 (stateless 특성)
2. 토큰 만료: 1시간

## 남은 작업
- [ ] 토큰 갱신 로직 구현
- [ ] 테스트 코드 작성
- [ ] API 문서화

## 차단 요소
- 없음

작업을 계속하시겠습니까?
```

### 3. 컨텍스트 목록 (`/context list`)

저장된 모든 컨텍스트를 표시합니다.

**예시:**
```
사용자: /context list
Claude:
## 저장된 컨텍스트

| ID | 이름 | 프로젝트 | 날짜 | TODO |
|----|------|---------|------|------|
| ctx-20260108-auth | 인증 기능 구현 | ai-note-taking | 01/08 | 3개 |
| ctx-20260107-deploy | 배포 설정 | docker-n8n | 01/07 | 0개 |
| ctx-20260106-ui | UI 개선 | home | 01/06 | 5개 |

복원: /context restore [ID]
삭제: /context delete [ID]
```

### 4. 인수인계 문서 생성 (`/context handoff`)

세션 종료 시 상세한 인수인계 문서를 생성합니다.

**실행 단계:**
1. 현재 세션 전체 분석
2. 작업 내용 요약
3. 코드 변경사항 정리
4. 다음 단계 명확화
5. 마크다운 문서 생성

**생성되는 문서 형식:**
```markdown
# 세션 인수인계 문서

**날짜**: 2026-01-08
**프로젝트**: ai-note-taking
**작업자**: Claude

---

## 작업 요약
[이번 세션에서 수행한 작업 상세 설명]

## 변경된 파일
| 파일 | 변경 유형 | 설명 |
|------|----------|------|
| src/auth/jwt.ts | 신규 | JWT 유틸리티 |
| src/api/login.ts | 수정 | 로그인 로직 |

## 주요 결정사항
1. **JWT 토큰 구조**: access_token + refresh_token
   - 이유: 보안성과 UX 균형

## 다음 단계
1. 토큰 갱신 API 구현
2. 프론트엔드 연동
3. E2E 테스트 작성

## 주의사항
- 환경변수 JWT_SECRET 설정 필요
- 테스트 시 Redis 실행 확인

## 관련 문서
- /docs/auth-architecture.md
```

## 자동화 기능

### 세션 시작 시 자동 복원 제안
```
[세션 시작]
Claude: 이전 컨텍스트가 발견되었습니다.

📁 ctx-20260108-auth (인증 기능 구현)
   └─ TODO 3개, 마지막 작업: 2시간 전

복원하시겠습니까? (Y/n)
```

### 세션 종료 시 자동 저장 제안
```
[세션 종료 감지]
Claude: 작업 내용을 저장하시겠습니까?

수정된 파일: 5개
결정사항: 2개
미완료 작업: 3개

1. 저장 후 종료
2. 인수인계 문서 생성 후 종료
3. 저장 없이 종료
```

## 연동 시스템

- **orchestrator**: 프로젝트 전환 시 컨텍스트 자동 관리
- **auto-doc**: 컨텍스트 기반 문서 자동 업데이트
- **notify-important**: 중요 작업 완료 시 알림

## 데이터 정리

### 자동 정리 규칙
- 30일 이상 된 컨텍스트: 자동 보관
- 완료된 TODO가 없는 컨텍스트: 90일 후 삭제
- 인수인계 문서: 영구 보관

### 수동 정리
```
/context delete ctx-20260108-auth  # 특정 컨텍스트 삭제
/context clean                      # 오래된 컨텍스트 정리
```
