#!/bin/bash
# Combined Claude Code Statusline
# Part 1: Claude Code session info (model, project, branch, output-style)
# Part 2: Infrastructure monitoring (Docker, n8n, resources, security, timers)

# Performance optimization
set -o pipefail

# Cache directory
CACHE_DIR="/tmp/claude-statusline"
mkdir -p "$CACHE_DIR"

# =============================================================================
# PART 1: Read Claude Code JSON Input
# =============================================================================
input=$(cat)

# Extract Claude Code context
cwd=$(echo "$input" | jq -r '.workspace.current_dir')
model=$(echo "$input" | jq -r '.model.display_name')
output_style=$(echo "$input" | jq -r '.output_style.name // "default"')
transcript_path=$(echo "$input" | jq -r '.transcript_path')

# Get project name
project=$(basename "$cwd")

# Get git branch
if git -C "$cwd" rev-parse --git-dir > /dev/null 2>&1; then
    branch=$(git -C "$cwd" -c core.fileMode=false -c gc.autodetach=false branch --show-current 2>/dev/null || echo "detached")
    git_info="🌿 $branch"
else
    git_info="🌿 no-repo"
fi

# =============================================================================
# Token Usage Monitoring
# =============================================================================
token_info() {
    local max_tokens=200000
    local current_tokens=0

    # Parse transcript file for token usage
    if [ -f "$transcript_path" ]; then
        # Extract the last token usage warning from transcript
        current_tokens=$(grep -o 'Token usage: [0-9]*' "$transcript_path" 2>/dev/null | tail -1 | grep -o '[0-9]*')

        # If no token info found, estimate from file size (rough approximation)
        if [ -z "$current_tokens" ] || [ "$current_tokens" = "0" ]; then
            local file_size=$(stat -c%s "$transcript_path" 2>/dev/null || echo 0)
            # Rough estimate: 1 token ≈ 4 characters
            current_tokens=$((file_size / 4))
        fi
    fi

    # Calculate percentage
    local percent=$((current_tokens * 100 / max_tokens))

    # Format numbers with K suffix for readability
    local current_k=$((current_tokens / 1000))
    local max_k=$((max_tokens / 1000))

    # Determine status icon and color
    local status_icon
    if [ "$percent" -lt 50 ]; then
        status_icon="✅"
    elif [ "$percent" -lt 75 ]; then
        status_icon="⚠️"
    elif [ "$percent" -lt 90 ]; then
        status_icon="🟠"
    else
        status_icon="🔴"
    fi

    # Output format: icon current/max (percent%)
    printf "%s %dK/%dK (%d%%)" "$status_icon" "$current_k" "$max_k" "$percent"
}

# =============================================================================
# Context Window Usage (Session-based)
# =============================================================================
context_window_info() {
    # Extract context window data from Claude Code JSON input
    local context_size=$(echo "$input" | jq -r '.context_window.context_window_size // 200000')
    local current_usage=$(echo "$input" | jq -r '.context_window.current_usage // {}')

    # Calculate total tokens used (input + cache creation)
    local input_tokens=$(echo "$current_usage" | jq -r '.input_tokens // 0')
    local cache_tokens=$(echo "$current_usage" | jq -r '.cache_creation_input_tokens // 0')
    local current_total=$((input_tokens + cache_tokens))

    # Calculate percentage
    local percent=0
    if [ "$context_size" -gt 0 ]; then
        percent=$((current_total * 100 / context_size))
    fi

    # Format with K suffix
    local current_k=$((current_total / 1000))
    local size_k=$((context_size / 1000))

    # Status icon based on usage
    local icon
    if [ "$percent" -lt 50 ]; then
        icon="📊"
    elif [ "$percent" -lt 75 ]; then
        icon="⚠️"
    elif [ "$percent" -lt 90 ]; then
        icon="🟠"
    else
        icon="🔴"
    fi

    printf "%s %dK/%dK (%d%%)" "$icon" "$current_k" "$size_k" "$percent"
}

# =============================================================================
# PART 2: Infrastructure Monitoring Functions
# =============================================================================

# Docker Services Status
docker_status() {
    local running=$(docker ps -q 2>/dev/null | wc -l)
    local total=$(docker ps -aq 2>/dev/null | wc -l)

    if [ "$running" -eq "$total" ] && [ "$total" -gt 0 ]; then
        echo "🐳 $running/$total"
    elif [ "$running" -gt 0 ]; then
        echo "⚠️ $running/$total"
    else
        echo "❌ 0/$total"
    fi
}

# n8n Health Check (with cache)
n8n_health() {
    local cache_file="$CACHE_DIR/n8n_health"
    local cache_age=30

    if [ -f "$cache_file" ] && [ $(($(date +%s) - $(stat -c %Y "$cache_file" 2>/dev/null || echo 0))) -lt $cache_age ]; then
        cat "$cache_file"
        return
    fi

    if timeout 1 curl -sf http://localhost:5678/healthz > /dev/null 2>&1; then
        echo "✅ n8n" | tee "$cache_file"
    else
        echo "⚪ n8n" | tee "$cache_file"
    fi
}

# PostgreSQL Status
postgres_status() {
    local cache_file="$CACHE_DIR/postgres_status"
    local cache_age=30

    if [ -f "$cache_file" ] && [ $(($(date +%s) - $(stat -c %Y "$cache_file" 2>/dev/null || echo 0))) -lt $cache_age ]; then
        cat "$cache_file"
        return
    fi

    local container_id=$(docker ps -qf "name=postgres" 2>/dev/null)
    if [ -n "$container_id" ] && docker exec "$container_id" pg_isready -U n8n 2>/dev/null | grep -q "accepting connections"; then
        echo "✅ pg" | tee "$cache_file"
    else
        echo "⚪ pg" | tee "$cache_file"
    fi
}

# Redis Status
redis_status() {
    local cache_file="$CACHE_DIR/redis_status"
    local cache_age=30

    if [ -f "$cache_file" ] && [ $(($(date +%s) - $(stat -c %Y "$cache_file" 2>/dev/null || echo 0))) -lt $cache_age ]; then
        cat "$cache_file"
        return
    fi

    local container_id=$(docker ps -qf "name=redis" 2>/dev/null)
    if [ -n "$container_id" ] && docker exec "$container_id" redis-cli ping 2>/dev/null | grep -q PONG; then
        echo "✅ redis" | tee "$cache_file"
    else
        echo "⚪ redis" | tee "$cache_file"
    fi
}

# MongoDB Status
mongodb_health() {
    local cache_file="$CACHE_DIR/mongodb_health"
    local cache_age=30

    if [ -f "$cache_file" ] && [ $(($(date +%s) - $(stat -c %Y "$cache_file" 2>/dev/null || echo 0))) -lt $cache_age ]; then
        cat "$cache_file"
        return
    fi

    if docker ps --filter "name=mongo" --filter "status=running" --format "{{.Names}}" 2>/dev/null | grep -q mongo; then
        echo "✅ mongo" | tee "$cache_file"
    else
        echo "⚪ mongo" | tee "$cache_file"
    fi
}

# Disk Usage
disk_usage() {
    local usage=$(df -h / | awk 'NR==2 {print $5}')
    local percent=$(echo "$usage" | sed 's/%//')

    if [ "$percent" -gt 90 ]; then
        echo "🔴 $usage"
    elif [ "$percent" -gt 80 ]; then
        echo "🟡 $usage"
    else
        echo "💾 $usage"
    fi
}

# Memory Usage
mem_usage() {
    local mem=$(free -m | awk 'NR==2{printf "%.0f%%", $3*100/$2}')
    local percent=$(echo "$mem" | sed 's/%//')

    if [ "$percent" -gt 90 ]; then
        echo "🔴 $mem"
    elif [ "$percent" -gt 80 ]; then
        echo "🟡 $mem"
    else
        echo "🧠 $mem"
    fi
}

# CPU Load
cpu_load() {
    local load=$(uptime | awk -F'load average:' '{print $2}' | awk '{print $1}' | sed 's/,//')
    echo "⚡ $load"
}

# Security Status
security_status() {
    local cache_file="$CACHE_DIR/security_status"
    local cache_age=60

    if [ -f "$cache_file" ] && [ $(($(date +%s) - $(stat -c %Y "$cache_file" 2>/dev/null || echo 0))) -lt $cache_age ]; then
        cat "$cache_file"
        return
    fi

    if command -v fail2ban-client > /dev/null 2>&1; then
        local banned=$(fail2ban-client status sshd 2>/dev/null | grep 'Currently banned:' | grep -o '[0-9]*' || echo "?")

        if [ "$banned" = "?" ] || [ -z "$banned" ]; then
            banned=$(fail2ban-client status sshd 2>/dev/null | grep 'Currently banned:' | grep -o '[0-9]*' || echo "?")
        fi

        if [ "$banned" != "?" ] && [ "$banned" -gt 0 ]; then
            echo "🔒 Ban:$banned" | tee "$cache_file"
        else
            echo "🔒 OK" | tee "$cache_file"
        fi
    else
        echo "🔒 -" | tee "$cache_file"
    fi
}

# Next Backup Time
next_backup() {
    local cache_file="$CACHE_DIR/next_backup"
    local cache_age=300

    if [ -f "$cache_file" ] && [ $(($(date +%s) - $(stat -c %Y "$cache_file" 2>/dev/null || echo 0))) -lt $cache_age ]; then
        cat "$cache_file"
        return
    fi

    if systemctl is-active --quiet n8n-backup.timer 2>/dev/null; then
        local next_full=$(systemctl list-timers n8n-backup.timer 2>/dev/null | grep n8n-backup | awk '{print $1, $2}')

        if [ -n "$next_full" ]; then
            echo "📦 $next_full" | tee "$cache_file"
        else
            echo "📦 On" | tee "$cache_file"
        fi
    else
        echo "📦 -" | tee "$cache_file"
    fi
}

# Next Update Time
next_update() {
    local cache_file="$CACHE_DIR/next_update"
    local cache_age=300

    if [ -f "$cache_file" ] && [ $(($(date +%s) - $(stat -c %Y "$cache_file" 2>/dev/null || echo 0))) -lt $cache_age ]; then
        cat "$cache_file"
        return
    fi

    if systemctl is-active --quiet n8n-update.timer 2>/dev/null; then
        local next_full=$(systemctl list-timers n8n-update.timer 2>/dev/null | grep n8n-update | awk '{print $1, $2}')

        if [ -n "$next_full" ]; then
            echo "🔄 $next_full" | tee "$cache_file"
        else
            echo "🔄 On" | tee "$cache_file"
        fi
    else
        echo "🔄 -" | tee "$cache_file"
    fi
}

# =============================================================================
# PART 3: Combined Output
# =============================================================================

# Environment Detection
env_status() {
    if [ -n "$SSH_CONNECTION" ] || [ -n "$SSH_CLIENT" ] || [ "$WORK_ENVIRONMENT" = "remote" ]; then
        echo "🌐 Remote"
    else
        echo "💻 Local"
    fi
}

# Line 1: Claude Code Session Info with Token Usage and Context Window
printf "🤖 %s | 📁 %s | %s | 🎨 %s | $(env_status) | 🪙 %s | %s\n" "$model" "$project" "$git_info" "$output_style" "$(token_info)" "$(context_window_info)"

# Line 2: Infrastructure Monitoring
echo "$(docker_status) | $(n8n_health) | $(postgres_status) | $(redis_status) | $(mongodb_health) | $(disk_usage) | $(mem_usage) | $(cpu_load) | $(security_status) | $(next_backup) $(next_update)"
