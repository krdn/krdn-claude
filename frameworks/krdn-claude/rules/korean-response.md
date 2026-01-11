# 한국어 응답 규칙

## 규칙
- 사용자가 한국어로 질문하면 한국어로 응답합니다
- 기술 용어는 영어 원문을 병기합니다 (예: "배포(deploy)")
- 코드 주석은 한국어로 작성합니다

## 예외
- 코드 자체는 영어로 작성합니다
- API 문서는 영어로 유지합니다

## 커밋 메시지 규칙

### 형식
```
<타입>: <제목>

<본문 (선택)>

Co-Authored-By: Claude <noreply@anthropic.com>
```

### 타입 (영어 유지)
| 타입 | 설명 |
|------|------|
| feat | 새 기능 추가 |
| fix | 버그 수정 |
| docs | 문서 수정 |
| refactor | 코드 리팩토링 |
| style | 코드 스타일 변경 (포맷팅 등) |
| test | 테스트 추가/수정 |
| chore | 빌드, 설정 등 기타 작업 |

### 제목 규칙
- 한국어로 작성
- 50자 이내
- 명령문 형태 사용 (예: "추가", "수정", "삭제")
- 마침표 생략

### 본문 규칙 (선택)
- 한국어로 상세 설명
- 변경 이유와 영향 설명
- 72자에서 줄바꿈

### 예시
```
feat: 사용자 인증 기능 추가

JWT 기반 인증 시스템 구현
- 로그인/로그아웃 API 추가
- 토큰 갱신 로직 구현
- 인증 미들웨어 적용

Co-Authored-By: Claude <noreply@anthropic.com>
```

```
fix: 날짜 포맷 오류 수정

한국 시간대(KST) 적용 시 날짜가 하루 밀리는 문제 해결

Co-Authored-By: Claude <noreply@anthropic.com>
```

```
docs: README 설치 가이드 업데이트

Co-Authored-By: Claude <noreply@anthropic.com>
```

## TODO 리스트 규칙

### 기본 원칙
- 작업 내용은 한국어로 작성
- 기술 용어는 영어 병기 (필요시)
- 동사로 시작하는 명령문 형태

### 작성 형식

| 필드 | 규칙 | 예시 |
|------|------|------|
| content | 할 일 (명령문) | "API 엔드포인트 추가" |
| activeForm | 진행 중 표현 | "API 엔드포인트 추가 중" |

### 좋은 예시

```json
{
  "content": "사용자 인증 로직 구현",
  "activeForm": "사용자 인증 로직 구현 중",
  "status": "in_progress"
}
```

```json
{
  "content": "테스트 코드 작성 (Jest)",
  "activeForm": "테스트 코드 작성 중",
  "status": "pending"
}
```

```json
{
  "content": "Docker 컨테이너 설정 확인",
  "activeForm": "Docker 컨테이너 설정 확인 중",
  "status": "completed"
}
```

### 작성 팁
- 구체적인 작업 단위로 분리
- 검증 가능한 완료 조건 포함
- 기술 스택은 괄호로 병기: "API 문서 작성 (Swagger)"
