---
name: context-manager
description: 세션 컨텍스트 저장/복원. "컨텍스트 저장", "세션 복원", "/context" 요청 시 사용.
---

# Context Manager Skill

세션별 작업 컨텍스트를 저장하고 복원하여 프로젝트 간 전환을 원활하게 합니다.

## 명령어

| 명령어 | 설명 |
|--------|------|
| `/context save [name]` | 현재 세션 컨텍스트 저장 |
| `/context restore [id]` | 이전 세션 복원 |
| `/context list` | 저장된 컨텍스트 목록 |
| `/context delete [id]` | 컨텍스트 삭제 |

> 인수인계 문서가 필요하면 `/doc handoff` 명령을 사용하세요 (auto-doc 스킬).

## 저장 위치

```
~/.claude/knowledge/contexts/
└── {id}.json
```

## 컨텍스트 구조

```json
{
  "id": "ctx-20260108-abc123",
  "name": "사용자 지정 이름",
  "created_at": "2026-01-08T10:00:00Z",
  "updated_at": "2026-01-08T12:00:00Z",
  "project": {
    "path": "/path/to/project",
    "name": "project-name",
    "domain": "ai|n8n|web"
  },
  "summary": "작업 요약",
  "files_modified": ["src/index.ts"],
  "decisions": [
    {"topic": "인증 방식", "decision": "JWT", "reason": "확장성"}
  ],
  "todos": ["테스트 코드 추가"],
  "blockers": []
}
```

## 사용 방법

### 1. 컨텍스트 저장 (`/context save`)

```
/context save 인증 기능 구현
```

**실행 단계:**
1. 현재 작업 디렉토리 확인
2. 최근 수정된 파일 목록 수집
3. 대화에서 주요 결정사항 추출
4. 미완료 작업(TODO) 식별
5. 컨텍스트 JSON 파일 생성

**출력:**
```
컨텍스트 저장 완료

ID: ctx-20260108-auth
프로젝트: ai-note-taking
수정된 파일: 5개
TODO: 3개

복원: /context restore ctx-20260108-auth
```

### 2. 컨텍스트 복원 (`/context restore`)

```
/context restore ctx-20260108-auth
```

**출력:**
```
컨텍스트 복원: 인증 기능 구현

프로젝트: ai-note-taking (/data/home-data/projects/ai/ai-note-taking)

이전 작업 요약:
JWT 기반 인증 시스템 구현 중. 로그인/로그아웃 API 완료.

주요 결정사항:
1. JWT 사용 (stateless 특성)
2. 토큰 만료: 1시간

남은 작업:
- [ ] 토큰 갱신 로직
- [ ] 테스트 코드
```

### 3. 컨텍스트 목록 (`/context list`)

```
저장된 컨텍스트

| ID | 이름 | 프로젝트 | 날짜 | TODO |
|----|------|---------|------|------|
| ctx-20260108-auth | 인증 기능 | ai-note-taking | 01/08 | 3개 |
| ctx-20260107-deploy | 배포 설정 | docker-n8n | 01/07 | 0개 |
```

## 자동화

### 세션 시작 시 복원 제안
```
이전 컨텍스트 발견:
ctx-20260108-auth (인증 기능 구현) - TODO 3개

복원하시겠습니까? (Y/n)
```

### 세션 종료 시 저장 제안
```
작업 내용을 저장하시겠습니까?
수정된 파일: 5개, TODO: 3개

1. 저장 후 종료
2. 저장 없이 종료
```

## 데이터 정리

- **30일 이상**: 자동 보관
- **90일 이상** (완료된 TODO 없음): 자동 삭제

```
/context delete ctx-20260108-auth  # 특정 삭제
```
