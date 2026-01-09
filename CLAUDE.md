# krdn-claude 프레임워크

> **별칭**: 크든클로드, krdn-claude, 프레임워크
> **버전**: CLI 2.1.x 호환
> **문서**: https://github.com/krdn/krdn-claude/wiki

## 프레임워크 개요

krdn-claude는 여러 개발 프로젝트(AI, N8N, Web)를 **트리 구조 에이전트 시스템**으로 통합 관리하는 프레임워크입니다.

```
                [Orchestrator]
                      │
        ┌─────────────┼─────────────┐
        ▼             ▼             ▼
   [AI Manager] [N8N Manager] [Web Manager]
```

## 주요 명령어

| 명령어 | 설명 |
|--------|------|
| `/orchestrate` | 프로젝트 오케스트레이션 |
| `/system-check` | 시스템 상태 점검 |
| `/deploy [project]` | 프로젝트 배포 |
| `/port` | 포트 관리 |
| `/doc` | 자동 문서화 |
| `/context` | 세션 컨텍스트 관리 |

## 프레임워크 호출 키워드

다음 키워드로 프레임워크를 참조할 수 있습니다:
- "krdn-claude" / "크든클로드"
- "프레임워크"
- "오케스트레이터"
- "프로젝트 관리 시스템"
- "트리 에이전트"

## 핵심 파일

| 파일 | 용도 |
|------|------|
| `~/.claude/knowledge/box/projects.json` | 프로젝트 맵 (진실의 원천) |
| `~/.claude/agents/orchestrator.md` | 메인 오케스트레이터 |
| `~/.claude/agents/domain/*.md` | 도메인 에이전트 |
| `~/.claude/skills/*/SKILL.md` | 스킬 정의 |

---

# 개인 설정 및 작업 환경

## 작업 환경
- **환경 유형**: 원격 연결 (SSH)
- **모든 작업**: 원격 서버를 통한 연결 작업
- **판단 기준**: 이 환경 정보를 기반으로 작업 계획 수립

## 작업 시 고려사항
- 네트워크 지연 가능성 고려
- 원격 파일시스템 경로 사용
- 장시간 실행 작업에 타임아웃 설정 필요

## 자동 감지
원격 연결 환경이 자동으로 감지되고 있습니다.
