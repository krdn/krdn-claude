---
name: auto-doc
description: 자동 문서화 스킬. 코드 변경 시 문서 자동 업데이트, ADR 생성, 학습 내용 정리를 수행합니다. "/doc", "문서화", "ADR 작성" 등을 요청할 때 사용.
---

# Auto Documentation Skill

코드 변경 사항을 자동으로 문서화하고, 의사결정 기록(ADR)을 관리하며, 학습 내용을 체계적으로 정리합니다.

## 명령어

| 명령어 | 설명 |
|--------|------|
| `/doc generate [project]` | 프로젝트 문서 자동 생성 |
| `/doc update` | 변경 사항 기반 문서 업데이트 |
| `/doc adr [title]` | ADR(Architecture Decision Record) 생성 |
| `/doc learn [topic]` | 학습 내용 기록 |
| `/doc search [query]` | 지식 저장소 스마트 검색 |
| `/doc share [topic]` | 공유 지식으로 등록 |
| `/doc pr` | GitHub Pull Request 생성 |
| `/doc dashboard` | 지식 저장소 현황 대시보드 |
| `/doc handoff` | 인수인계 문서 생성 |

## 1. 문서 자동 생성

### CLAUDE.md 생성 규칙

프로젝트 분석 후 CLAUDE.md 자동 생성:

```markdown
# {프로젝트명}

## 개요
{package.json 또는 README.md 기반 설명}

## 기술 스택
- {감지된 프레임워크/라이브러리}

## 주요 명령어
```bash
# 개발
{npm run dev 또는 감지된 스크립트}

# 빌드
{npm run build}

# 테스트
{npm test}
```

## 프로젝트 구조
{주요 디렉토리 설명}

## 개발 가이드
{컨벤션 및 주의사항}
```

### 분석 대상 파일

| 파일 | 추출 정보 |
|------|----------|
| `package.json` | 이름, 스크립트, 의존성 |
| `README.md` | 프로젝트 설명 |
| `tsconfig.json` | TypeScript 설정 |
| `docker-compose.yml` | Docker 구성 |
| `.env.example` | 환경 변수 |

## 2. ADR (Architecture Decision Records)

### ADR 저장 위치
`~/.claude/knowledge/box/decisions.json`

### ADR 구조

```json
{
  "id": "adr-{NNN}",
  "title": "의사결정 제목",
  "date": "2026-01-08",
  "status": "accepted|deprecated|superseded",
  "context": "배경 및 문제 상황",
  "decision": "결정 내용",
  "consequences": {
    "positive": ["긍정적 결과"],
    "negative": ["부정적 결과/트레이드오프"]
  },
  "alternatives": [
    {
      "option": "대안 옵션",
      "reason_rejected": "선택하지 않은 이유"
    }
  ],
  "related_projects": ["관련 프로젝트"],
  "tags": ["architecture", "performance", "security"]
}
```

### ADR 생성 프로세스

```
1. 의사결정 필요 감지
   ├─ 사용자 요청
   ├─ 아키텍처 변경 감지
   └─ 기술 선택 시점
   ↓
2. 컨텍스트 수집
   ├─ 현재 상황 분석
   ├─ 제약 조건 파악
   └─ 대안 조사
   ↓
3. ADR 작성
   ├─ 구조화된 형식으로 기록
   ├─ 대안과 트레이드오프 명시
   └─ 관련 프로젝트 연결
   ↓
4. 저장 및 인덱싱
   → decisions.json에 추가
```

### ADR 템플릿

```markdown
## ADR-{NNN}: {제목}

**날짜**: {YYYY-MM-DD}
**상태**: Accepted

### 컨텍스트
{왜 이 결정이 필요한지}

### 결정
{무엇을 결정했는지}

### 결과
**긍정적:**
- {장점 1}
- {장점 2}

**부정적:**
- {단점/트레이드오프}

### 고려한 대안
1. **{대안 1}**: {선택하지 않은 이유}
2. **{대안 2}**: {선택하지 않은 이유}
```

## 3. 학습 내용 관리

### 저장 위치
`~/.claude/knowledge/box/learnings.json`

### 학습 구조

```json
{
  "id": "learn-{timestamp}",
  "topic": "학습 주제",
  "date": "2026-01-08",
  "category": "pattern|bug|optimization|tool|concept",
  "project": "발견한 프로젝트",
  "summary": "핵심 내용 요약",
  "details": "상세 설명",
  "code_example": "코드 예시 (선택)",
  "references": ["참고 링크"],
  "tags": ["react", "performance"],
  "reusable": true
}
```

### 학습 카테고리

| 카테고리 | 설명 | 예시 |
|----------|------|------|
| **pattern** | 코드 패턴/디자인 패턴 | "React에서 커스텀 훅으로 로직 분리" |
| **bug** | 버그 원인 및 해결책 | "CORS 에러 해결 방법" |
| **optimization** | 성능 최적화 기법 | "메모이제이션으로 리렌더링 방지" |
| **tool** | 도구/라이브러리 사용법 | "Docker 멀티스테이지 빌드" |
| **concept** | 개념/원리 | "트랜잭션 격리 수준" |

### 자동 학습 감지

다음 상황에서 학습 내용 자동 기록 제안:

1. **새로운 문제 해결**: 처음 마주친 에러 해결 시
2. **최적화 적용**: 성능 개선 작업 완료 시
3. **새 라이브러리 사용**: 처음 사용하는 도구 적용 시
4. **패턴 발견**: 재사용 가능한 코드 패턴 작성 시

## 4. 지식 공유 시스템

### 공유 지식 디렉토리
`~/.claude/knowledge/box/shared/`

### 공유 문서 구조

```
shared/
├── patterns/           # 재사용 가능한 코드 패턴
│   ├── react-hooks.md
│   └── error-handling.md
├── guides/             # 가이드 문서
│   ├── deployment.md
│   └── testing.md
├── troubleshooting/    # 문제 해결 가이드
│   ├── docker.md
│   └── networking.md
└── templates/          # 템플릿
    ├── component.md
    └── api-endpoint.md
```

### 공유 등록 기준

재사용 가치가 있는 지식:
- 2개 이상 프로젝트에서 사용 가능
- 일반화된 해결책
- 문서화할 가치가 있는 인사이트

## 5. 문서 업데이트 트리거

### 자동 감지

| 변경 유형 | 업데이트 대상 |
|----------|--------------|
| 새 의존성 추가 | CLAUDE.md 기술 스택 |
| 스크립트 변경 | CLAUDE.md 명령어 |
| 디렉토리 구조 변경 | CLAUDE.md 구조 |
| 아키텍처 결정 | decisions.json |
| 버그 해결 | learnings.json |

### 수동 트리거

```bash
# 문서 전체 재생성
/doc generate [project]

# 특정 섹션 업데이트
/doc update --section [section]
```

## 6. 검색 및 조회

### 지식 검색

```bash
# 키워드 검색
/doc search "react hook"

# 카테고리 필터
/doc search --category pattern

# 프로젝트 필터
/doc search --project ai-note-taking
```

### 검색 대상

| 저장소 | 검색 필드 |
|--------|----------|
| `decisions.json` | title, context, decision, tags |
| `learnings.json` | topic, summary, details, tags |
| `shared/` | 파일 내용 전체 |

## 7. 연동 시스템

| 시스템 | 연동 내용 |
|--------|----------|
| **orchestrator** | 프로젝트별 문서 현황 보고 |
| **context-manager** | 세션 컨텍스트에 관련 ADR/학습 포함 |
| **code-reviewer** | 리뷰 시 관련 학습 내용 참조 |
| **deploy-manager** | 배포 시 문서 업데이트 체크 |

## 8. 사용 예시

### ADR 생성
```
사용자: "상태 관리를 Redux 대신 Zustand로 변경하려고 해"

1. ADR 컨텍스트 수집
2. 대안 분석 (Redux, Zustand, Jotai, Context API)
3. ADR 작성 및 저장
4. 관련 프로젝트 연결
```

### 학습 기록
```
사용자: "이 CORS 문제 해결한 거 기록해줘"

1. 문제 상황 요약
2. 해결 방법 문서화
3. learnings.json에 저장
4. 공유 가치 평가 → shared/troubleshooting/에 추가
```

### 문서 생성
```
사용자: "/doc generate ai-note-taking"

1. 프로젝트 분석
2. package.json, tsconfig.json 등 파싱
3. CLAUDE.md 생성
4. 결과 보고
```

## 9. 주의사항

1. **중복 방지**: 유사한 ADR/학습 내용 감지 및 병합 제안
2. **관련성 유지**: 오래된 문서 자동 아카이브 (1년 이상)
3. **민감 정보**: API 키, 비밀번호 등 자동 필터링
4. **버전 관리**: 문서 변경 이력 추적

## 10. 파일 목록

```
~/.claude/
├── skills/
│   └── auto-doc/
│       └── SKILL.md              # 이 파일
└── knowledge/
    └── box/
        ├── decisions.json        # ADR 저장소
        ├── learnings.json        # 학습 내용
        ├── deployments.json      # 배포 이력
        ├── incidents.json        # 인시던트 기록
        ├── index.json            # 크로스 참조 인덱스
        └── shared/               # 공유 지식
            ├── patterns/
            ├── guides/
            ├── troubleshooting/
            └── templates/
```

---

## 11. Pull Request 생성 (`/doc pr`)

GitHub Pull Request를 자동으로 생성합니다.

### 실행 프로세스

```
1. 변경사항 분석
   ├─ git status로 변경된 파일 확인
   ├─ git diff로 변경 내용 파악
   └─ 커밋 히스토리 분석

2. PR 내용 생성
   ├─ 변경 유형 파악 (feat/fix/refactor/docs)
   ├─ PR 제목 생성 (conventional commit 스타일)
   └─ PR 본문 작성 (Summary, Changes, Test plan)

3. PR 생성
   ├─ 브랜치 확인/생성
   ├─ 변경사항 커밋 (필요 시)
   ├─ 원격 저장소 push
   └─ gh pr create 실행

4. 결과 반환
   └─ PR URL 제공
```

### PR 본문 템플릿

```markdown
## Summary
{변경사항 요약 - 1~3줄}

## Changes
- {변경 내용 1}
- {변경 내용 2}
- {변경 내용 3}

## Test plan
- [ ] {테스트 항목 1}
- [ ] {테스트 항목 2}

## Related
- Closes #{관련 이슈 번호} (있는 경우)
- Related ADR: {adr-id} (있는 경우)

🤖 Generated with [Claude Code](https://claude.com/claude-code)
```

### 사용 예시

```bash
# 현재 브랜치의 변경사항으로 PR 생성
/doc pr

# 특정 프로젝트에서 PR 생성
/doc pr ai-note-taking

# 드래프트 PR 생성
/doc pr --draft
```

### 자동 연결

- **관련 이슈**: 커밋 메시지나 브랜치 이름에서 이슈 번호 자동 감지
- **관련 ADR**: decisions.json에서 관련 ADR 찾아 본문에 링크
- **라벨**: 변경 유형에 따라 자동 라벨 추가 (enhancement, bug, documentation)

---

## 12. 지식 대시보드 (`/doc dashboard`)

지식 저장소의 현황을 한눈에 파악할 수 있는 대시보드를 제공합니다.

### 실행 프로세스

```
1. 지식 저장소 스캔
   ├─ decisions.json 로드
   ├─ learnings.json 로드
   ├─ deployments.json 로드
   ├─ incidents.json 로드
   └─ index.json 로드

2. 통계 계산
   ├─ 각 저장소별 항목 수
   ├─ 상태별/카테고리별 분류
   └─ 최근 활동 추출

3. 연결 상태 분석
   ├─ 고아 ADR (프로젝트 미연결)
   ├─ 미해결 인시던트
   └─ 크로스 참조 현황

4. 대시보드 출력
```

### 출력 형식

```markdown
## 📊 지식 저장소 대시보드

### 통계 요약
| 저장소 | 항목 수 | 최근 추가 |
|--------|---------|----------|
| ADR | 2개 | 2026-01-09 |
| 학습 | 4개 | 2026-01-08 |
| 배포 | 5개 | 2026-01-09 |
| 인시던트 | 1개 | 2026-01-07 |

### ADR 상태
- ✅ Accepted: 2개
- ⏳ Proposed: 0개
- ❌ Deprecated: 0개

### 학습 카테고리
- 🧩 pattern: 1개
- 🔧 tool: 2개
- ⚡ optimization: 1개

### 최근 활동 (7일)
| 날짜 | 유형 | 내용 |
|------|------|------|
| 2026-01-09 | ADR | 모델 계층화 전략 결정 |
| 2026-01-08 | 학습 | GitHub Wiki 자동화 방법 |

### 연결 현황
- 🔗 프로젝트 연결 ADR: 2/2 (100%)
- ⚠️ 미해결 인시던트: 0개
- 📚 재사용 가능 학습: 3개

### 권장 조치
- 없음 (모든 항목 정상)
```

---

## 13. 스마트 검색 (`/doc search`)

Claude의 의미 기반 검색으로 관련 지식을 찾습니다.

### 검색 범위

| 저장소 | 검색 필드 |
|--------|----------|
| `decisions.json` | title, context, decision, tags, consequences |
| `learnings.json` | topic, summary, details, tags, code_example |
| `deployments.json` | project, version, commit_hash |
| `incidents.json` | description, category, recovery_action |
| `index.json` | 크로스 참조 관계 |

### 검색 모드

```bash
# 기본 검색 (모든 저장소)
/doc search "react hook"

# 카테고리 필터
/doc search "react hook" --category pattern

# 프로젝트 필터
/doc search --project ai-note-taking

# 태그 필터
/doc search --tag performance

# 날짜 범위
/doc search --since 2026-01-01
```

### 검색 결과 형식

```markdown
## 🔍 검색 결과: "react hook"

### ADR 관련 (2건)
| ID | 제목 | 관련도 |
|----|------|--------|
| adr-001 | 트리 구조 에이전트 시스템 | 95% |
| adr-002 | 모델 계층화 전략 | 72% |

### 학습 기록 (1건)
| ID | 주제 | 카테고리 | 관련도 |
|----|------|----------|--------|
| learn-001 | Claude Code 에이전트 정의 | pattern | 87% |

### 관련 프로젝트
- claude-code-auto (ADR 2건, 학습 1건)
- ai-note-taking (학습 1건)

### 추천 문서
- `shared/patterns/react-hooks.md`
```

### 관련성 점수 계산

- **직접 매칭**: 제목/주제에 키워드 포함 (100%)
- **태그 매칭**: 태그에 키워드 포함 (80%)
- **내용 매칭**: 상세 내용에 키워드 포함 (60%)
- **연관 매칭**: 크로스 참조된 항목 (40%)

---

## 14. 인수인계 문서 생성 (`/doc handoff`)

프로젝트 또는 현재 작업의 인수인계 문서를 생성합니다.

### 실행 프로세스

```
1. 컨텍스트 수집
   ├─ 현재 프로젝트 상태
   ├─ 진행 중인 작업
   ├─ 관련 ADR/학습 내용
   └─ 최근 배포/인시던트

2. 인수인계 문서 생성
   ├─ 프로젝트 개요
   ├─ 현재 상태
   ├─ 주요 결정사항
   ├─ 알려진 이슈
   └─ 다음 단계

3. 파일 저장
   → ~/.claude/handoffs/{project}-{date}.md
```

### 문서 템플릿

```markdown
# 인수인계 문서: {프로젝트명}

**생성일**: {YYYY-MM-DD}
**작성자**: Claude Code

## 프로젝트 개요
{프로젝트 설명}

## 현재 상태
- **브랜치**: {현재 브랜치}
- **최근 배포**: {최근 배포 정보}
- **빌드 상태**: {빌드 상태}

## 주요 결정사항 (ADR)
| ID | 제목 | 상태 |
|----|------|------|
| adr-001 | {제목} | accepted |

## 진행 중인 작업
- [ ] {작업 1}
- [ ] {작업 2}

## 알려진 이슈
- {이슈 1}

## 학습 내용
- {관련 학습 1}

## 다음 단계
1. {권장 다음 단계 1}
2. {권장 다음 단계 2}

## 참고 자료
- {관련 문서 링크}
```

---

## 15. 자동 태깅

학습 내용 저장 시 자동으로 카테고리와 태그를 추천합니다.

### 자동 분류 규칙

| 키워드 패턴 | 추천 카테고리 |
|-------------|--------------|
| error, fix, bug, issue | bug |
| pattern, hook, component | pattern |
| performance, optimize, fast | optimization |
| library, tool, package, npm | tool |
| concept, principle, theory | concept |
| security, auth, permission | security |

### 자동 태그 추천

```
내용: "React에서 useMemo를 사용한 메모이제이션으로 리렌더링 최적화"

추천 카테고리: optimization
추천 태그: ["react", "performance", "memoization", "hooks"]
```

### 저장 시 확인

```
학습 내용 저장 전 확인:

카테고리: optimization (자동 추천)
태그: react, performance, memoization (자동 추천)

[Y] 승인  [E] 수정  [C] 취소
```
