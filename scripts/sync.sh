#!/bin/bash
# Claude Code 설정 동기화 스크립트 (Ubuntu/Linux/macOS)
# 사용법: ~/.claude/scripts/sync.sh [push|pull]

set -e

CLAUDE_DIR="$HOME/.claude"
cd "$CLAUDE_DIR"

ACTION="${1:-pull}"

case "$ACTION" in
    push)
        echo "📤 변경사항을 GitHub에 푸시합니다..."
        git add -A

        # 변경사항 있는지 확인
        if git diff --cached --quiet; then
            echo "✅ 푸시할 변경사항이 없습니다."
            exit 0
        fi

        # 커밋 메시지 입력
        echo ""
        echo "변경된 파일:"
        git diff --cached --name-only
        echo ""
        read -p "커밋 메시지 (Enter=자동): " MSG

        if [ -z "$MSG" ]; then
            MSG="chore: 설정 동기화 $(date '+%Y-%m-%d %H:%M')"
        fi

        git commit -m "$MSG"
        git push origin main
        echo "✅ 푸시 완료!"
        ;;

    pull)
        echo "📥 GitHub에서 최신 설정을 가져옵니다..."
        git pull origin main
        echo "✅ 동기화 완료!"
        ;;

    status)
        echo "📊 현재 상태:"
        git status
        echo ""
        echo "📅 마지막 커밋:"
        git log -1 --oneline
        ;;

    *)
        echo "사용법: $0 [push|pull|status]"
        echo ""
        echo "  push   - 로컬 변경사항을 GitHub에 푸시"
        echo "  pull   - GitHub에서 최신 설정 가져오기 (기본값)"
        echo "  status - 현재 상태 확인"
        exit 1
        ;;
esac
