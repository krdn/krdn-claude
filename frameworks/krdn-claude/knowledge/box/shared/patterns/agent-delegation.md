# 에이전트 위임 패턴

## 개요
부모 에이전트가 자식 에이전트에게 작업을 위임하는 패턴입니다.

## 패턴 구조

```
[Parent Agent]
    │
    ├── Task 도구로 위임
    │   └── subagent_type: "child-agent"
    │
    └── 결과 취합 및 보고
```

## 구현 예시

### 부모 에이전트 (orchestrator)
```markdown
# 작업 위임 시
1. 작업 유형 분석
2. 적절한 도메인 에이전트 선택
3. Task 도구로 작업 위임
4. 결과 취합
5. 사용자에게 보고
```

### 자식 에이전트 호출
```
Task 도구 사용:
- subagent_type: "ai-manager"
- prompt: "claude-code-auto 프로젝트 빌드 실행"
```

## 사용 시나리오

| 시나리오 | 부모 | 자식 | 위임 내용 |
|----------|------|------|----------|
| 전체 빌드 | orchestrator | ai/n8n/web-manager | 각 도메인 빌드 |
| 시스템 점검 | orchestrator | monitor | 상태 체크 |
| 코드 리뷰 | domain-manager | code-reviewer | PR 리뷰 |

## 주의사항

1. **컨텍스트 전달**: 자식에게 충분한 컨텍스트 제공
2. **결과 검증**: 자식의 결과를 부모가 검증
3. **에러 처리**: 자식 실패 시 부모가 대응 결정

## 관련 문서
- [[트리-구조-에이전트-시스템]]
- [[Orchestrator-Agent]]
