---
name: port-manager
description: 개발 프로젝트 포트 관리. 프로젝트별 포트 등록, 목록 조회, 개발 서버 시작. "/port", "/port register", "/port start" 등으로 사용.
---

# Port Manager - 개발 포트 관리 스킬

프로젝트별 개발 포트를 중앙에서 관리하는 스킬입니다.

## 설정 파일 위치

- 설정: `~/.config/dev-ports/config.json`
- 레지스트리: `~/.config/dev-ports/registry.json`

## 명령어

### `/port` 또는 `/port list`
등록된 모든 프로젝트와 포트 목록을 표시합니다.

```bash
cat ~/.config/dev-ports/registry.json | jq '.projects | to_entries[] | "\(.value.port) - \(.value.name) (\(.key))"'
```

### `/port register [포트번호]`
현재 프로젝트에 포트를 등록합니다.

**실행 단계:**
1. 현재 작업 디렉토리 확인: `pwd`
2. 레지스트리 파일 읽기: `cat ~/.config/dev-ports/registry.json`
3. 이미 등록된 프로젝트인지 확인
4. 포트번호가 지정되지 않으면 `nextPort` 값 사용
5. 포트 충돌 확인 (reservedPorts, 이미 사용 중인 포트)
6. 레지스트리에 프로젝트 추가
7. `nextPort` 값 증가
8. package.json의 dev 스크립트에 포트 추가 (선택적)

**레지스트리 업데이트 예시:**
```bash
# jq를 사용하여 레지스트리 업데이트
jq --arg path "$PWD" \
   --arg name "$(basename $PWD)" \
   --argjson port $PORT \
   --arg type "nextjs" \
   --arg date "$(date -Iseconds)" \
   '.projects[$path] = {port: $port, name: $name, type: $type, registeredAt: $date} | .nextPort = ($port + 1)' \
   ~/.config/dev-ports/registry.json > /tmp/registry.json && \
   mv /tmp/registry.json ~/.config/dev-ports/registry.json
```

### `/port start`
현재 프로젝트에 등록된 포트로 개발 서버를 시작합니다.

**실행 단계:**
1. 현재 프로젝트의 등록된 포트 확인
2. 등록되지 않은 경우 자동 등록 제안
3. 프로젝트 타입에 따라 적절한 명령 실행:
   - nextjs: `npm run dev -- -p $PORT`
   - vite: `npm run dev -- --port $PORT`
   - react: `PORT=$PORT npm start`

### `/port free`
현재 프로젝트의 포트 등록을 해제합니다.

```bash
jq --arg path "$PWD" 'del(.projects[$path])' \
   ~/.config/dev-ports/registry.json > /tmp/registry.json && \
   mv /tmp/registry.json ~/.config/dev-ports/registry.json
```

### `/port check`
현재 시스템에서 사용 중인 개발 포트를 확인합니다.

```bash
lsof -i -P -n | grep LISTEN | grep -E ":3[0-9]{3}|:5[0-9]{3}" | awk '{print $9, $1}' | sort -t: -k2 -n | uniq
```

## 출력 형식

### `/port list` 출력 예시
```
## 등록된 개발 포트

| 포트 | 프로젝트 | 경로 | 타입 |
|------|----------|------|------|
| 3100 | ai-note-taking | /home/gon/projects/ai/ai-note-taking | nextjs |
| 3101 | my-blog | /home/gon/projects/my-blog | nextjs |

다음 사용 가능 포트: 3102
```

### `/port register` 출력 예시
```
## 포트 등록 완료

- 프로젝트: ai-note-taking
- 경로: /home/gon/projects/ai/ai-note-taking
- 포트: 3100
- 타입: nextjs

개발 서버 시작: `/port start` 또는 `npm run dev -- -p 3100`
```

## 프로젝트 타입 감지

package.json을 분석하여 프로젝트 타입을 자동 감지합니다:

- `next` 의존성 → nextjs
- `vite` 의존성 → vite
- `react-scripts` 의존성 → react
- 그 외 → generic

## 주의사항

1. 포트 범위: 3100-3999 (config.json에서 변경 가능)
2. 예약 포트: 3000, 5555는 기본 제외
3. 충돌 방지: 이미 사용 중인 포트는 자동 스킵
4. jq 필요: 레지스트리 조작에 jq 명령어 필요
