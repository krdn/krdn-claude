#!/bin/bash
# 프로젝트에 Claude Code 설정 초기화
# 사용법: init-project.sh [project-path]

PROJECT_PATH="${1:-.}"
TEMPLATE_DIR="$HOME/.claude/templates"

mkdir -p "$PROJECT_PATH/.claude"

if [ ! -f "$PROJECT_PATH/.claude/settings.json" ]; then
    cp "$TEMPLATE_DIR/project-settings.json" "$PROJECT_PATH/.claude/settings.json"
    echo "✅ $PROJECT_PATH/.claude/settings.json 생성됨"
else
    echo "⚠️  이미 설정 파일이 존재합니다"
fi

# .gitignore에 로컬 설정 추가
if [ -f "$PROJECT_PATH/.gitignore" ]; then
    if ! grep -q "settings.local.json" "$PROJECT_PATH/.gitignore"; then
        echo ".claude/settings.local.json" >> "$PROJECT_PATH/.gitignore"
        echo "✅ .gitignore에 settings.local.json 추가됨"
    fi
fi
