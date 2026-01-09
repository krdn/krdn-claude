# 프레임워크 컨벤션 규칙

## 프로젝트 관리
- 새 프로젝트는 반드시 `projects.json`에 등록합니다
- 도메인 에이전트 파일에 명령어를 추가합니다
- 프로젝트 루트에 `CLAUDE.md`를 생성합니다

## 지식 저장소
- 중요한 결정은 `decisions.json`에 ADR로 기록합니다
- 학습 내용은 `learnings.json`에 저장합니다
- 배포 이력은 `deployments.json`에 기록합니다

## 스킬 사용
- 시스템 점검: `/system-check`
- 포트 관리: `/port`
- 배포: `/deploy`
- 문서화: `/doc`

## 커밋 컨벤션
- feat: 새 기능
- fix: 버그 수정
- docs: 문서 수정
- refactor: 리팩토링
- chore: 기타 작업
