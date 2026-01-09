# 개인 설정

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

---

## 활성 프레임워크

<!-- FRAMEWORKS:BEGIN (auto-managed by /framework command) -->

### krdn-claude (v2.1.0)
> **우선순위**: 100 | **상태**: ✅ 활성

**트리 구조 에이전트 시스템**으로 AI, N8N, Web 프로젝트를 통합 관리합니다.

| 명령어 | 설명 |
|--------|------|
| `/orchestrate` | 프로젝트 오케스트레이션 |
| `/system-check` | 시스템 상태 점검 |
| `/deploy` | 프로젝트 배포 |
| `/framework` | 프레임워크 관리 |

**호출 키워드**: krdn-claude, 크든클로드, 프레임워크, 오케스트레이터

**문서**: https://github.com/krdn/krdn-claude/wiki

<!-- FRAMEWORKS:END -->

---

## 프레임워크 관리

프레임워크를 관리하려면 다음 명령어를 사용하세요:

```
/framework list          # 설치된 프레임워크 목록
/framework status        # 활성 프레임워크 상태
/framework enable [name] # 활성화
/framework disable [name] # 비활성화
```

프레임워크 파일 위치: `~/.claude/frameworks/`
