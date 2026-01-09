# 이슈 저장 스킬 (Save Issue)

작업 완료 후 커밋, 푸시, GitHub 이슈 등록, develop 머지를 자동화합니다.

## 실행 단계

### 1단계: 변경사항 분석
```bash
git status
git diff --stat
git log --oneline -3
```

변경된 파일과 최근 커밋을 분석하여 작업 내용을 파악합니다.

### 2단계: 커밋 메시지 생성 및 커밋

**커밋 메시지 형식**:
```
<type>: <간결한 설명>

## 변경사항
- <상세 변경 내용 1>
- <상세 변경 내용 2>

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>
```

**커밋 타입**:
- `feat`: 새로운 기능
- `fix`: 버그 수정
- `refactor`: 코드 리팩토링
- `docs`: 문서 변경
- `style`: 코드 스타일 변경
- `test`: 테스트 추가/수정
- `chore`: 빌드/설정 변경

```bash
git add -A
git commit -m "커밋 메시지"
```

### 3단계: 원격 저장소에 Push
```bash
git push origin <현재 브랜치>
```

### 4단계: 프롬프트 정리 (AI 자동 수정)

**중요**: 사용자가 요청한 원본 프롬프트를 AI가 다음 기준으로 정리합니다:

**정리 기준**:
1. **간결성**: 불필요한 수식어, 중복 표현 제거
2. **명확성**: 모호한 표현을 구체적으로 변환
3. **구조화**: 여러 요청이 있으면 번호 매기기
4. **핵심 추출**: 실제 구현해야 할 내용만 남기기

**정리 예시**:
```
# Before (원본)
"음... 그러니까 로그인 기능 있잖아요, 그거 좀 고쳐주세요.
비밀번호 틀리면 에러 메시지가 안 나와서 사용자가 헷갈려해요.
그리고 가능하면 로그인 버튼도 좀 예쁘게 해주시면 좋겠어요."

# After (정리됨)
"로그인 기능 개선:
1. 비밀번호 오류 시 에러 메시지 표시 추가
2. 로그인 버튼 UI 개선"
```

**정리된 프롬프트는 이슈 본문의 "📝 요청 프롬프트" 섹션에 포함됩니다.**

### 5단계: GitHub 이슈 등록

**이슈 제목**: `<type>: <작업 내용 요약>`

**이슈 본문 템플릿**:
```markdown
## 📝 요청 프롬프트

> <AI가 정리한 간결하고 명확한 프롬프트>

<details>
<summary>원본 프롬프트</summary>

> <사용자가 처음 요청한 프롬프트 원문>

</details>

## 🚀 기능 설명 / 🐛 문제 설명

<작업 내용 상세 설명>

## ✅ 구현/해결 내용

### 주요 변경사항
- <변경 1>
- <변경 2>

### 수정된 파일
| 파일 | 변경 내용 |
|------|----------|
| `path/to/file` | <설명> |

## 🧪 테스트 결과

- ✅ <테스트 항목 1>
- ✅ <테스트 항목 2>

## 📁 관련 파일

- `file1.ts` - <역할>
- `file2.ts` - <역할>

---

**커밋**: <커밋 해시>
**브랜치**: <브랜치명>
**상태**: ✅ 완료
```

**라벨 선택 규칙**:
1. 먼저 `gh label list`로 저장소의 기존 라벨 확인
2. 적절한 라벨이 있으면 사용
3. 없으면 새 라벨 생성:
   ```bash
   gh label create "<라벨명>" --description "<설명>" --color "<색상코드>"
   ```

**라벨 카테고리**:
- `type:` - feature, bug, refactor, docs, chore
- `area:` - backend, frontend, api, auth, database
- `priority:` - critical, high, medium, low
- `status:` - in-progress, ready, blocked

```bash
gh issue create --title "<제목>" --label "<라벨1>,<라벨2>" --body "<본문>"
```

### 6단계: develop 브랜치에 머지

```bash
# 현재 브랜치 저장
CURRENT_BRANCH=$(git branch --show-current)

# develop으로 전환 및 최신화
git checkout develop
git pull origin develop

# 머지 (non-fast-forward)
git merge $CURRENT_BRANCH --no-ff -m "Merge branch '$CURRENT_BRANCH' into develop

<머지 커밋 메시지>

Related: #<이슈번호>"

# 푸시
git push origin develop
```

### 7단계: 원래 브랜치로 복귀

```bash
git checkout $CURRENT_BRANCH
```

### 8단계: Wiki 저장 (선택적)

**Wiki 저장 기준** - 다음 중 하나에 해당하면 저장:
- 새로운 아키텍처 패턴 도입
- 중요한 API 엔드포인트 추가
- 복잡한 비즈니스 로직 구현
- 보안 관련 변경
- 성능 최적화 기법
- 트러블슈팅 경험
- 재사용 가능한 코드 패턴

```bash
# Wiki 저장소 클론 (처음 한 번만)
git clone https://github.com/<owner>/<repo>.wiki.git /tmp/wiki

# Wiki 페이지 생성/수정
cd /tmp/wiki
echo "<위키 내용>" > "<페이지명>.md"
git add .
git commit -m "docs: <설명>"
git push
```

**Wiki 페이지 구조**:
```markdown
# <제목>

## 개요
<간략한 설명>

## 상세 내용
<기술적 상세 내용>

## 코드 예시
```typescript
// 관련 코드 예시
```

## 관련 이슈
- #<이슈번호>

## 참고 자료
- <링크>
```

---

## 사용 예시

```
/save-issue
```

또는 인자와 함께:
```
/save-issue 폴더 권한 시스템 구현 완료
```

## 주의사항

1. **커밋 전 확인**: 민감한 정보(.env, 자격증명 등)가 포함되지 않았는지 확인
2. **머지 충돌**: develop 머지 시 충돌이 발생하면 수동 해결 필요
3. **라벨 권한**: 일부 저장소는 라벨 생성 권한이 제한될 수 있음
4. **Wiki 권한**: Wiki가 비활성화된 저장소도 있음

## 출력 형식

작업 완료 후 다음 형식으로 결과를 출력합니다:

```
## 작업 완료 요약

### 커밋
- **커밋 해시**: <hash>
- **브랜치**: <branch>
- **변경 파일**: N개

### GitHub 이슈
- **URL**: <issue_url>
- **라벨**: <labels>

### 머지
- **타겟**: develop
- **머지 커밋**: <merge_hash>

### Wiki (해당 시)
- **페이지**: <wiki_page_url>

### 현재 브랜치
- **복귀**: <current_branch>
```
