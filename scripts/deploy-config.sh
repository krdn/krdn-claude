#!/bin/bash
# Claude Code 설정 배포 스크립트
# 사용법: ./deploy-config.sh [remote-host]

set -e

REMOTE_HOST="$1"
CLAUDE_DIR="$HOME/.claude"
REPO_URL="https://github.com/krdn/krdn-claude.git"

# 색상 정의
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

log_info() { echo -e "${GREEN}[INFO]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

deploy_local() {
    log_info "로컬 설정 업데이트 중..."
    cd "$CLAUDE_DIR"
    git pull origin main
    log_info "완료!"
}

deploy_remote() {
    local host="$1"
    log_info "원격 서버 배포: $host"

    # 원격 서버에 .claude 디렉토리 존재 여부 확인
    if ssh "$host" "[ -d ~/.claude/.git ]"; then
        log_info "기존 설정 업데이트 중..."
        ssh "$host" "cd ~/.claude && git pull origin main"
    else
        log_info "새로 클론 중..."
        ssh "$host" "
            [ -d ~/.claude ] && mv ~/.claude ~/.claude.backup.\$(date +%Y%m%d)
            git clone $REPO_URL ~/.claude
        "
    fi

    log_info "$host 배포 완료!"
}

# 메인 로직
if [ -z "$REMOTE_HOST" ]; then
    deploy_local
else
    deploy_remote "$REMOTE_HOST"
fi
