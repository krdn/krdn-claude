# Claude Code 팀 설정 가이드

## 빠른 시작

### 1. 저장소 클론

```bash
# 기존 설정 백업
[ -d ~/.claude ] && mv ~/.claude ~/.claude.backup

# 팀 설정 저장소 클론
git clone https://github.com/krdn/krdn-claude.git ~/.claude
```

### 2. 개인 설정 생성

`settings.local.json`은 Git에 포함되지 않으므로 각자 생성해야 합니다:

```bash
cat > ~/.claude/settings.local.json << 'EOF'
{
  "permissions": {
    "allow": [],
    "deny": []
  }
}
EOF
```

### 3. Claude Code 로그인

```bash
claude login
```

## 설정 업데이트

팀 설정이 변경되면:

```bash
cd ~/.claude && git pull origin main
```

## 파일 구조

| 파일 | 용도 | Git 포함 |
|------|------|----------|
| `settings.json` | 팀 공유 설정 | ✅ |
| `settings.local.json` | 개인 설정 | ❌ |
| `CLAUDE.md` | 프롬프트 규칙 | ✅ |
| `frameworks/` | 프레임워크 | ✅ |
| `skills/` | 커스텀 스킬 | ✅ |

## 주의사항

- `.credentials.json`은 절대 공유하지 마세요
- 개인 API 키는 `settings.local.json`에 저장
- 권한 변경 시 팀에 알려주세요
