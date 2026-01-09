# CLAUDE.md 템플릿

프로젝트별 CLAUDE.md 파일 작성 시 사용하는 템플릿입니다.

---

```markdown
# {프로젝트명}

## 개요
{프로젝트 한 줄 설명}

## 기술 스택
- **프레임워크**: {Next.js, Express, etc.}
- **언어**: {TypeScript, Python, etc.}
- **데이터베이스**: {PostgreSQL, MongoDB, etc.}
- **배포**: {Vercel, Docker, etc.}

## 주요 명령어

```bash
# 의존성 설치
{npm install | pip install -r requirements.txt}

# 개발 서버 실행
{npm run dev | python main.py}

# 빌드
{npm run build}

# 테스트
{npm test}

# 린트
{npm run lint}
```

## 프로젝트 구조

```
{프로젝트루트}/
├── src/                # 소스 코드
│   ├── components/     # UI 컴포넌트
│   ├── pages/          # 페이지
│   ├── lib/            # 유틸리티
│   └── api/            # API 라우트
├── public/             # 정적 파일
├── tests/              # 테스트
└── docs/               # 문서
```

## 환경 변수

| 변수명 | 설명 | 필수 |
|--------|------|------|
| `DATABASE_URL` | DB 연결 문자열 | ✅ |
| `API_KEY` | 외부 API 키 | ✅ |
| `DEBUG` | 디버그 모드 | ❌ |

## 개발 가이드

### 브랜치 전략
- `main`: 프로덕션
- `develop`: 개발
- `feature/*`: 기능 개발

### 커밋 컨벤션
- `feat`: 새 기능
- `fix`: 버그 수정
- `docs`: 문서
- `refactor`: 리팩토링

### 코드 스타일
- ESLint/Prettier 설정 준수
- TypeScript strict mode

## 배포

### 프로덕션
```bash
/deploy {프로젝트명}
```

### 스테이징
```bash
/deploy {프로젝트명} --env staging
```

## 트러블슈팅

### 자주 발생하는 이슈
1. **{이슈1}**: {해결방법}
2. **{이슈2}**: {해결방법}

## 관련 링크
- [Repository]({GitHub URL})
- [Production]({배포 URL})
- [Documentation]({문서 URL})
```

---

## 사용 방법

1. 위 템플릿을 복사
2. `{}`로 표시된 부분을 프로젝트에 맞게 수정
3. 프로젝트 루트에 `CLAUDE.md`로 저장

## 자동 생성

```bash
/doc generate [project]
```

위 명령으로 프로젝트 분석 후 자동 생성 가능.

## 관련 문서
- [[Auto-Doc-Skill]]
