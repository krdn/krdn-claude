---
name: framework-manager
description: 프레임워크 관리 스킬. 프레임워크 설치, 활성화/비활성화, 마이그레이션을 담당합니다. "/framework", "프레임워크 관리" 요청 시 사용.
context: fork
allowed-tools:
  - Bash
  - Read
  - Write
  - Glob
  - Grep
---

# Framework Manager Skill

다중 프레임워크를 관리하고 충돌을 해결하는 시스템입니다.

## 명령어

| 명령어 | 설명 |
|--------|------|
| `/framework list` | 설치된 프레임워크 목록 |
| `/framework status` | 활성화된 프레임워크 상태 |
| `/framework enable [name]` | 프레임워크 활성화 |
| `/framework disable [name]` | 프레임워크 비활성화 |
| `/framework create [name]` | 새 프레임워크 생성 |
| `/framework migrate` | 현재 파일을 프레임워크로 마이그레이션 |
| `/framework priority [name] [num]` | 우선순위 설정 |
| `/framework info [name]` | 프레임워크 상세 정보 |

## 디렉토리 구조

```
~/.claude/frameworks/
├── .registry.json           # 프레임워크 레지스트리
├── .active/                 # 활성 리소스 심볼릭 링크
│   ├── agents/
│   ├── skills/
│   ├── rules/
│   └── knowledge/
└── {framework-name}/        # 각 프레임워크
    ├── framework.json       # 매니페스트
    ├── agents/
    ├── skills/
    ├── knowledge/
    └── rules/
```

## 핵심 파일

### framework.json (매니페스트)

```json
{
  "name": "framework-name",
  "displayName": "Display Name",
  "version": "1.0.0",
  "description": "Framework description",
  "priority": 100,
  "components": {
    "agents": { "enabled": true, "path": "./agents" },
    "skills": { "enabled": true, "path": "./skills" },
    "knowledge": { "enabled": true, "path": "./knowledge" },
    "rules": { "enabled": true, "path": "./rules" }
  },
  "metadata": {
    "repository": "https://github.com/...",
    "documentation": "https://..."
  }
}
```

### .registry.json (레지스트리)

```json
{
  "version": "1.0.0",
  "last_updated": "2026-01-09T00:00:00Z",
  "frameworks": {
    "krdn-claude": {
      "enabled": true,
      "priority": 100,
      "installed_at": "2026-01-09T00:00:00Z",
      "path": "./krdn-claude"
    }
  },
  "active_resources": {
    "agents": ["krdn-claude"],
    "skills": ["krdn-claude"],
    "knowledge": ["krdn-claude"],
    "rules": ["krdn-claude"]
  }
}
```

## 명령어 상세

### /framework list

```bash
echo "=== 설치된 프레임워크 ==="
cat ~/.claude/frameworks/.registry.json | jq -r '.frameworks | to_entries[] | "\(.key): \(if .value.enabled then "✅" else "❌" end) (priority: \(.value.priority))"'
```

### /framework status

```bash
echo "=== 활성 프레임워크 상태 ==="
# 활성화된 프레임워크 및 리소스 표시
cat ~/.claude/frameworks/.registry.json | jq '.active_resources'
```

### /framework enable [name]

1. 프레임워크 존재 확인
2. framework.json 로드
3. 각 컴포넌트에 대해 심볼릭 링크 생성
4. .registry.json 업데이트
5. 충돌 체크 및 우선순위 적용

```bash
# 심볼릭 링크 생성 예시
ln -sf ~/.claude/frameworks/krdn-claude/agents/* ~/.claude/frameworks/.active/agents/
ln -sf ~/.claude/frameworks/krdn-claude/skills/* ~/.claude/frameworks/.active/skills/
```

### /framework disable [name]

1. 프레임워크 활성화 상태 확인
2. 관련 심볼릭 링크 제거
3. .registry.json 업데이트

```bash
# 심볼릭 링크 제거 예시
find ~/.claude/frameworks/.active -lname "*krdn-claude*" -delete
```

### /framework migrate

현재 `~/.claude/`에 있는 파일들을 프레임워크 구조로 마이그레이션:

1. 백업 생성
2. 프레임워크 디렉토리 생성
3. 파일 이동:
   - `agents/` → `frameworks/{name}/agents/`
   - `skills/` (8개) → `frameworks/{name}/skills/`
   - `knowledge/` → `frameworks/{name}/knowledge/`
   - `rules/` → `frameworks/{name}/rules/`
   - `orchestration/` → `frameworks/{name}/orchestration/`
4. framework.json 생성
5. .registry.json 생성
6. CLAUDE.md 분리

```bash
# 마이그레이션 스크립트 경로
~/.claude/skills/framework-manager/scripts/migrate.sh
```

### /framework create [name]

1. 새 프레임워크 디렉토리 생성
2. 기본 framework.json 생성
3. 컴포넌트 디렉토리 생성
4. .registry.json에 등록

### /framework priority [name] [num]

1. 프레임워크 우선순위 변경
2. 충돌하는 리소스 재계산
3. 심볼릭 링크 재생성

## 충돌 해결 전략

### 우선순위 기반

```
Priority: 100 (krdn-claude) > 80 (devops-tools) > 50 (minimal)

같은 이름의 리소스가 있을 때:
  skills/deploy-manager → 우선순위 높은 프레임워크 것 사용
```

### 리소스 유형별 전략

| 리소스 | 전략 | 설명 |
|--------|------|------|
| agents | priority | 높은 우선순위만 사용 |
| skills | priority | 높은 우선순위만 사용 |
| rules | append | 모든 프레임워크의 규칙 병합 |
| knowledge | merge | 깊은 병합, 충돌 시 우선순위 |

## 연동 시스템

- **CLAUDE.md**: 활성 프레임워크 목록 자동 업데이트
- **context-manager**: 프레임워크 변경 시 컨텍스트 저장
- **notify-important**: 중요 변경 알림

## 사용 예시

### 새 프레임워크 설치

```
/framework create my-framework
# my-framework 디렉토리에 파일 추가
/framework enable my-framework
```

### 프레임워크 비활성화

```
/framework disable krdn-claude
# krdn-claude 리소스가 비활성화됨
```

### 우선순위 변경

```
/framework priority devops-tools 150
# devops-tools가 krdn-claude보다 우선됨
```

## 주의사항

1. **백업 필수**: 마이그레이션 전 반드시 백업
2. **CLI 재시작**: 활성화/비활성화 후 Claude Code 재시작 권장
3. **의존성 확인**: 프레임워크 간 의존성 고려
4. **경로 문제**: 심볼릭 링크는 절대 경로 사용 권장

## 문제 해결

### 심볼릭 링크 깨짐

```bash
# 깨진 링크 찾기
find ~/.claude/frameworks/.active -type l ! -exec test -e {} \; -print

# 재생성
/framework disable [name]
/framework enable [name]
```

### 충돌 확인

```bash
# 같은 이름의 리소스 찾기
find ~/.claude/frameworks/*/skills -maxdepth 1 -type d -printf '%f\n' | sort | uniq -d
```
