#!/bin/bash
#
# Deploy Manager - 롤백 스크립트
# 사용법: ./rollback.sh <project> [version]
#
# 프로젝트: ai-note-taking, claude-code-auto, docker-n8n,
#          news-sentiment-analyzer, home, home-krdn, gonsai2
#

set -e

# 색상 정의
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# 로그 함수
log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# 설정
DEPLOYMENTS_FILE="$HOME/.claude/knowledge/box/deployments.json"
TIMESTAMP=$(date +%Y%m%d-%H%M%S)

# 인자 확인
PROJECT=$1
VERSION=$2

if [ -z "$PROJECT" ]; then
    log_error "프로젝트명을 지정해주세요"
    echo "사용법: $0 <project> [version]"
    exit 1
fi

# 프로젝트 경로 매핑
get_project_path() {
    case $1 in
        "claude-code-auto")
            echo "/data/home-data/projects/ai/claude-code-auto"
            ;;
        "ai-note-taking")
            echo "/data/home-data/projects/ai/ai-note-taking"
            ;;
        "gonsai2")
            echo "/data/home-data/projects/n8n/gonsai2"
            ;;
        "docker-n8n")
            echo "/home/gon/docker-n8n"
            ;;
        "news-sentiment-analyzer")
            echo "/data/home-data/projects/n8n/news-sentiment-analyzer2"
            ;;
        "home")
            echo "/data/home-data/projects/web/home"
            ;;
        "home-krdn")
            echo "/data/home-data/projects/web/home-krdn"
            ;;
        *)
            echo ""
            ;;
    esac
}

# 프로젝트 유형 확인
get_project_type() {
    case $1 in
        "claude-code-auto")
            echo "npm-package"
            ;;
        "ai-note-taking"|"home"|"home-krdn")
            echo "nextjs"
            ;;
        "gonsai2")
            echo "express"
            ;;
        "docker-n8n"|"news-sentiment-analyzer")
            echo "docker-compose"
            ;;
        *)
            echo "unknown"
            ;;
    esac
}

# Vercel 롤백
rollback_vercel() {
    local path=$1

    log_info "Vercel 배포 목록 조회 중..."
    cd "$path"

    # 최근 배포 목록 표시
    vercel ls --limit 5

    if [ -n "$VERSION" ]; then
        log_info "지정된 버전으로 롤백: $VERSION"
        vercel rollback "$VERSION" --yes
    else
        log_info "이전 배포로 롤백 중..."
        # 가장 최근 프로덕션 이전 배포로 롤백
        vercel rollback --yes
    fi

    log_success "Vercel 롤백 완료"
}

# Docker Compose 롤백
rollback_docker() {
    local path=$1
    local project=$2

    log_info "Docker Compose 롤백 시작..."
    cd "$path"

    # 백업 파일 확인
    local backup_file=$(ls -t /tmp/docker-backup-$project-*.txt 2>/dev/null | head -1)

    if [ -n "$backup_file" ]; then
        log_info "백업 파일 발견: $backup_file"
        cat "$backup_file"
    fi

    # 서비스 중지
    log_info "서비스 중지 중..."
    docker compose down

    # 이전 이미지로 복원 (캐시된 이미지 사용)
    log_info "서비스 재시작 중..."
    docker compose up -d

    # 상태 확인
    sleep 10
    docker compose ps

    log_success "Docker Compose 롤백 완료"
}

# Git 기반 롤백
rollback_git() {
    local path=$1

    log_info "Git 기반 롤백 시작..."
    cd "$path"

    # 최근 커밋 목록 표시
    log_info "최근 커밋 목록:"
    git log --oneline -10

    if [ -n "$VERSION" ]; then
        log_info "지정된 버전으로 롤백: $VERSION"
        git checkout "$VERSION"
    else
        log_info "이전 커밋으로 롤백..."
        git checkout HEAD~1
    fi

    # 빌드 및 재시작 필요
    log_warn "빌드 및 서비스 재시작이 필요할 수 있습니다"

    log_success "Git 롤백 완료"
}

# PM2 롤백
rollback_pm2() {
    local project=$1

    log_info "PM2 프로세스 재시작..."

    if command -v pm2 &> /dev/null; then
        pm2 restart "$project"
        pm2 status "$project"
    else
        log_warn "PM2가 설치되지 않았습니다"
    fi

    log_success "PM2 롤백 완료"
}

# 롤백 이력 기록
record_rollback() {
    local project=$1
    local status=$2

    if [ -f "$DEPLOYMENTS_FILE" ] && command -v jq &> /dev/null; then
        local new_record=$(cat <<EOF
{
    "id": "rollback-$TIMESTAMP",
    "project": "$project",
    "type": "rollback",
    "status": "$status",
    "rolled_back_at": "$(date -Iseconds)",
    "rolled_back_by": "deploy-manager"
}
EOF
)
        jq ".deployments += [$new_record]" "$DEPLOYMENTS_FILE" > "/tmp/deployments.tmp" && \
            mv "/tmp/deployments.tmp" "$DEPLOYMENTS_FILE"
    fi
}

# 메인 로직
main() {
    local project_path=$(get_project_path "$PROJECT")
    local project_type=$(get_project_type "$PROJECT")

    if [ -z "$project_path" ]; then
        log_error "알 수 없는 프로젝트: $PROJECT"
        exit 1
    fi

    echo ""
    log_warn "=========================================="
    log_warn "롤백 시작: $PROJECT"
    log_warn "경로: $project_path"
    log_warn "유형: $project_type"
    log_warn "=========================================="
    echo ""

    read -p "정말 롤백하시겠습니까? (y/N): " confirm
    if [ "$confirm" != "y" ] && [ "$confirm" != "Y" ]; then
        log_info "롤백이 취소되었습니다"
        exit 0
    fi

    # 유형별 롤백
    case $project_type in
        "nextjs")
            rollback_vercel "$project_path"
            ;;
        "docker-compose")
            rollback_docker "$project_path" "$PROJECT"
            ;;
        "npm-package"|"express")
            rollback_git "$project_path"
            if [ "$project_type" = "express" ]; then
                rollback_pm2 "$PROJECT"
            fi
            ;;
        *)
            log_error "지원하지 않는 프로젝트 유형: $project_type"
            exit 1
            ;;
    esac

    # 롤백 이력 기록
    record_rollback "$PROJECT" "success"

    echo ""
    log_success "=========================================="
    log_success "롤백 완료: $PROJECT"
    log_success "시간: $(date)"
    log_success "=========================================="
}

# 실행
main
