#!/bin/bash

# Framework Activation Script
# 프레임워크를 활성화하고 심볼릭 링크를 생성합니다

set -e

CLAUDE_DIR="$HOME/.claude"
FRAMEWORKS_DIR="$CLAUDE_DIR/frameworks"
ACTIVE_DIR="$FRAMEWORKS_DIR/.active"
REGISTRY_FILE="$FRAMEWORKS_DIR/.registry.json"

FRAMEWORK_NAME="$1"
ACTION="${2:-enable}"  # enable or disable

if [ -z "$FRAMEWORK_NAME" ]; then
    echo "Usage: $0 <framework-name> [enable|disable]"
    exit 1
fi

FRAMEWORK_DIR="$FRAMEWORKS_DIR/$FRAMEWORK_NAME"

# 프레임워크 존재 확인
if [ ! -d "$FRAMEWORK_DIR" ]; then
    echo "Error: Framework '$FRAMEWORK_NAME' not found at $FRAMEWORK_DIR"
    exit 1
fi

# framework.json 로드
MANIFEST="$FRAMEWORK_DIR/framework.json"
if [ ! -f "$MANIFEST" ]; then
    echo "Error: framework.json not found in $FRAMEWORK_DIR"
    exit 1
fi

create_symlinks() {
    echo "=== $FRAMEWORK_NAME 활성화 ==="

    # 에이전트 심볼릭 링크
    if [ -d "$FRAMEWORK_DIR/agents" ]; then
        echo "[1/4] 에이전트 링크 생성..."
        for agent in "$FRAMEWORK_DIR/agents"/*.md; do
            if [ -f "$agent" ]; then
                agent_name=$(basename "$agent")
                ln -sf "$agent" "$ACTIVE_DIR/agents/$agent_name"
                echo "    - $agent_name"
            fi
        done
        # 도메인 에이전트
        if [ -d "$FRAMEWORK_DIR/agents/domain" ]; then
            mkdir -p "$ACTIVE_DIR/agents/domain"
            for agent in "$FRAMEWORK_DIR/agents/domain"/*.md; do
                if [ -f "$agent" ]; then
                    agent_name=$(basename "$agent")
                    ln -sf "$agent" "$ACTIVE_DIR/agents/domain/$agent_name"
                    echo "    - domain/$agent_name"
                fi
            done
        fi
    fi

    # 스킬 심볼릭 링크
    if [ -d "$FRAMEWORK_DIR/skills" ]; then
        echo "[2/4] 스킬 링크 생성..."
        for skill_dir in "$FRAMEWORK_DIR/skills"/*; do
            if [ -d "$skill_dir" ]; then
                skill_name=$(basename "$skill_dir")
                ln -sf "$skill_dir" "$ACTIVE_DIR/skills/$skill_name"
                echo "    - $skill_name"
            fi
        done
    fi

    # 규칙 심볼릭 링크
    if [ -d "$FRAMEWORK_DIR/rules" ]; then
        echo "[3/4] 규칙 링크 생성..."
        for rule in "$FRAMEWORK_DIR/rules"/*.md; do
            if [ -f "$rule" ]; then
                rule_name=$(basename "$rule")
                ln -sf "$rule" "$ACTIVE_DIR/rules/$rule_name"
                echo "    - $rule_name"
            fi
        done
    fi

    # 지식 저장소 심볼릭 링크
    if [ -d "$FRAMEWORK_DIR/knowledge" ]; then
        echo "[4/4] 지식 저장소 링크 생성..."
        ln -sf "$FRAMEWORK_DIR/knowledge" "$ACTIVE_DIR/knowledge/$FRAMEWORK_NAME"
        echo "    - knowledge/$FRAMEWORK_NAME"
    fi

    echo ""
    echo "=== 활성화 완료 ==="
}

remove_symlinks() {
    echo "=== $FRAMEWORK_NAME 비활성화 ==="

    # 해당 프레임워크의 심볼릭 링크만 제거
    echo "심볼릭 링크 제거 중..."
    find "$ACTIVE_DIR" -type l -lname "*$FRAMEWORK_NAME*" -delete 2>/dev/null || true

    echo "=== 비활성화 완료 ==="
}

update_registry() {
    local enabled="$1"

    if [ ! -f "$REGISTRY_FILE" ]; then
        echo "Warning: Registry file not found, creating new one"
        echo '{"version":"1.0.0","frameworks":{},"active_resources":{}}' > "$REGISTRY_FILE"
    fi

    # jq로 레지스트리 업데이트
    if command -v jq &> /dev/null; then
        local temp_file=$(mktemp)
        jq --arg name "$FRAMEWORK_NAME" --argjson enabled "$enabled" \
           '.frameworks[$name].enabled = $enabled | .frameworks[$name].last_updated = (now | todate)' \
           "$REGISTRY_FILE" > "$temp_file"
        mv "$temp_file" "$REGISTRY_FILE"
        echo "레지스트리 업데이트 완료"
    else
        echo "Warning: jq not installed, registry not updated"
    fi
}

# 메인 로직
case "$ACTION" in
    enable)
        create_symlinks
        update_registry "true"
        ;;
    disable)
        remove_symlinks
        update_registry "false"
        ;;
    *)
        echo "Unknown action: $ACTION"
        echo "Usage: $0 <framework-name> [enable|disable]"
        exit 1
        ;;
esac
