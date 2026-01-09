#!/bin/bash

# krdn-claude Framework Migration Script
# 현재 ~/.claude의 파일들을 frameworks/krdn-claude로 마이그레이션

set -e

CLAUDE_DIR="$HOME/.claude"
FRAMEWORKS_DIR="$CLAUDE_DIR/frameworks"
FRAMEWORK_NAME="${1:-krdn-claude}"
TARGET_DIR="$FRAMEWORKS_DIR/$FRAMEWORK_NAME"
BACKUP_DIR="$CLAUDE_DIR/backups/$(date +%Y%m%d_%H%M%S)"

echo "=== krdn-claude Framework Migration ==="
echo "Target: $TARGET_DIR"
echo ""

# 1. 백업 생성
echo "[1/7] 백업 생성 중..."
mkdir -p "$BACKUP_DIR"
cp -r "$CLAUDE_DIR/agents" "$BACKUP_DIR/" 2>/dev/null || true
cp -r "$CLAUDE_DIR/skills" "$BACKUP_DIR/" 2>/dev/null || true
cp -r "$CLAUDE_DIR/knowledge" "$BACKUP_DIR/" 2>/dev/null || true
cp -r "$CLAUDE_DIR/rules" "$BACKUP_DIR/" 2>/dev/null || true
cp -r "$CLAUDE_DIR/orchestration" "$BACKUP_DIR/" 2>/dev/null || true
cp -r "$CLAUDE_DIR/commands" "$BACKUP_DIR/" 2>/dev/null || true
cp "$CLAUDE_DIR/CLAUDE.md" "$BACKUP_DIR/" 2>/dev/null || true
echo "  백업 완료: $BACKUP_DIR"

# 2. 프레임워크 디렉토리 생성
echo "[2/7] 프레임워크 디렉토리 생성 중..."
mkdir -p "$TARGET_DIR"/{agents/domain,skills,knowledge/box/shared,rules,orchestration,commands}
mkdir -p "$FRAMEWORKS_DIR/.active"/{agents/domain,skills,knowledge,rules}

# 3. 에이전트 이동
echo "[3/7] 에이전트 이동 중..."
if [ -d "$CLAUDE_DIR/agents" ]; then
    # 도메인 에이전트
    if [ -d "$CLAUDE_DIR/agents/domain" ]; then
        cp -r "$CLAUDE_DIR/agents/domain/"* "$TARGET_DIR/agents/domain/" 2>/dev/null || true
    fi
    # 루트 에이전트 (orchestrator, monitor, code-reviewer)
    for agent in orchestrator monitor code-reviewer; do
        if [ -f "$CLAUDE_DIR/agents/$agent.md" ]; then
            cp "$CLAUDE_DIR/agents/$agent.md" "$TARGET_DIR/agents/"
        fi
    done
    echo "  에이전트 이동 완료"
fi

# 4. 스킬 이동 (framework-manager 제외)
echo "[4/7] 스킬 이동 중..."
if [ -d "$CLAUDE_DIR/skills" ]; then
    for skill_dir in "$CLAUDE_DIR/skills"/*; do
        skill_name=$(basename "$skill_dir")
        # framework-manager는 제외 (CLI에서 직접 사용해야 함)
        if [ "$skill_name" != "framework-manager" ] && [ -d "$skill_dir" ]; then
            cp -r "$skill_dir" "$TARGET_DIR/skills/"
            echo "    - $skill_name 이동"
        fi
    done
fi

# 5. 지식 저장소 이동
echo "[5/7] 지식 저장소 이동 중..."
if [ -d "$CLAUDE_DIR/knowledge" ]; then
    cp -r "$CLAUDE_DIR/knowledge/"* "$TARGET_DIR/knowledge/" 2>/dev/null || true
    echo "  지식 저장소 이동 완료"
fi

# 6. 규칙 이동
echo "[6/7] 규칙 이동 중..."
if [ -d "$CLAUDE_DIR/rules" ]; then
    cp -r "$CLAUDE_DIR/rules/"* "$TARGET_DIR/rules/" 2>/dev/null || true
    echo "  규칙 이동 완료"
fi

# 7. 오케스트레이션 이동
echo "[7/7] 오케스트레이션 및 명령어 이동 중..."
if [ -d "$CLAUDE_DIR/orchestration" ]; then
    cp -r "$CLAUDE_DIR/orchestration/"* "$TARGET_DIR/orchestration/" 2>/dev/null || true
fi
if [ -d "$CLAUDE_DIR/commands" ]; then
    cp -r "$CLAUDE_DIR/commands/"* "$TARGET_DIR/commands/" 2>/dev/null || true
fi
echo "  완료"

echo ""
echo "=== 마이그레이션 완료 ==="
echo "프레임워크 위치: $TARGET_DIR"
echo "백업 위치: $BACKUP_DIR"
echo ""
echo "다음 단계:"
echo "1. framework.json 생성 필요"
echo "2. .registry.json 생성 필요"
echo "3. 원본 파일 정리 (선택)"
echo "4. 심볼릭 링크 생성"
