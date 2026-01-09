# krdn-claude Framework

> **버전**: 2.3.0
> **CLI 호환**: Claude Code 2.1.x
> **별칭**: 크든클로드, 프레임워크, 오케스트레이터

## 개요

krdn-claude는 여러 개발 프로젝트(AI, N8N, Web)를 **트리 구조 에이전트 시스템**으로 통합 관리하는 프레임워크입니다.

```
                    [Orchestrator]
                          │
          ┌───────────────┼───────────────┐
          ▼               ▼               ▼
     [AI Manager]   [N8N Manager]   [Web Manager]
          │               │               │
    ┌─────┼─────┐    ┌────┴────┐    ┌────┴────┐
    ▼     ▼     ▼    ▼         ▼    ▼         ▼
claude- ai-  gonsai2 docker-  news- home    home-
code-  note         n8n     senti-         krdn
auto   taking              ment
```

## 설치

이 프레임워크는 `~/.claude/frameworks/krdn-claude/`에 설치됩니다.

### 활성화

```bash
/framework enable krdn-claude
```

### 비활성화

```bash
/framework disable krdn-claude
```

## 구성 요소

### 에이전트 (agents/)

| 에이전트 | 역할 |
|---------|------|
| orchestrator | 프로젝트 오케스트레이션, 작업 분배 |
| monitor | 시스템 모니터링, 자동 복구 |
| code-reviewer | 코드 리뷰 자동화 |
| ai-manager | AI 도메인 프로젝트 관리 |
| n8n-manager | N8N/Docker 프로젝트 관리 |
| web-manager | Web 프로젝트 관리 |

### 스킬 (skills/)

| 스킬 | 명령어 | 설명 |
|------|--------|------|
| auto-doc | `/doc` | 자동 문서화, PR 생성, 대시보드 |
| context-manager | `/context` | 세션 컨텍스트 관리 |
| deploy-manager | `/deploy` | 프로젝트 배포, 롤백, 헬스체크 |
| notify-important | `/notify-important` | 중요 알림 발송 |
| port-manager | `/port` | 개발 포트 관리 |
| prompt-assistant | `/prompt` | 프롬프트 분석, 인터뷰 |
| system-check | `/system-check` | 시스템 점검, 자동 복구 |

### 지식 저장소 (knowledge/)

| 파일 | 용도 |
|------|------|
| projects.json | 프로젝트 맵 (진실의 원천) |
| decisions.json | ADR (Architecture Decision Records) |
| learnings.json | 학습 내용 기록 |
| deployments.json | 배포 이력 |
| incidents.json | 인시던트 로그 |

### 규칙 (rules/)

| 규칙 | 설명 |
|------|------|
| korean-response.md | 한국어 응답 규칙 |
| framework-conventions.md | 프레임워크 컨벤션 |
| security.md | 보안 규칙 |

## 명령어 레퍼런스

### 오케스트레이션

```
"프로젝트 목록 보여줘"
"/orchestrate"
"전체 상태 확인"
```

### 배포

```
/deploy [project]          # 단일 프로젝트 배포
/deploy all                 # 전체 배포
/deploy rollback [project]  # 롤백
```

### 시스템 점검

```
/system-check              # 전체 시스템 점검
"서버 상태 확인해줘"
```

### 포트 관리

```
/port list                 # 포트 목록
/port register [port]      # 포트 등록
/port start [project]      # 개발 서버 시작
```

## 프레임워크 관리

### 정보 확인

```
/framework info krdn-claude
/framework status
```

### 우선순위 변경

```
/framework priority krdn-claude 100
```

## 문서

- [Wiki](https://github.com/krdn/krdn-claude/wiki)
- [Framework 사용 가이드](https://github.com/krdn/krdn-claude/wiki/Framework-사용-가이드)
- [프로젝트 생성 가이드](https://github.com/krdn/krdn-claude/wiki/Framework-프로젝트-생성-가이드)

## 라이선스

MIT
