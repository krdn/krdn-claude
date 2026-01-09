#!/bin/bash
#
# Deploy Manager - 배포 스크립트
# 사용법: ./deploy.sh <project> [environment]
#
# 프로젝트: ai-note-taking, claude-code-auto, docker-n8n,
#          news-sentiment-analyzer, home, home-krdn, gonsai2
# 환경: dev, staging, prod (기본: prod)
#

set -e

# 색상 정의
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 로그 함수
log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# 설정
PROJECTS_FILE="$HOME/.claude/knowledge/box/projects.json"
DEPLOYMENTS_FILE="$HOME/.claude/knowledge/box/deployments.json"
TIMESTAMP=$(date +%Y%m%d-%H%M%S)

# 인자 확인
PROJECT=$1
ENVIRONMENT=${2:-prod}

if [ -z "$PROJECT" ]; then
    log_error "프로젝트명을 지정해주세요"
    echo "사용법: $0 <project> [environment]"
    echo "프로젝트: ai-note-taking, claude-code-auto, docker-n8n, home, etc."
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

# Git 상태 확인
check_git_status() {
    local path=$1
    cd "$path"

    if [ -n "$(git status --porcelain)" ]; then
        log_warn "커밋되지 않은 변경사항이 있습니다"
        git status --short
        read -p "계속 진행하시겠습니까? (y/N): " confirm
        if [ "$confirm" != "y" ] && [ "$confirm" != "Y" ]; then
            log_info "배포가 취소되었습니다"
            exit 0
        fi
    fi

    local branch=$(git rev-parse --abbrev-ref HEAD)
    if [ "$branch" != "main" ] && [ "$branch" != "master" ]; then
        log_warn "현재 브랜치: $branch (main/master가 아님)"
    fi

    log_info "현재 브랜치: $branch"
}

# Next.js 프로젝트 배포 (Vercel)
deploy_nextjs() {
    local path=$1
    local env=$2

    log_info "Next.js 프로젝트 배포 시작..."
    cd "$path"

    # 빌드 테스트
    log_info "빌드 테스트 중..."
    npm run build || {
        log_error "빌드 실패"
        exit 1
    }

    # Vercel 배포
    if [ "$env" = "prod" ]; then
        log_info "프로덕션 배포 중..."
        vercel --prod --yes
    else
        log_info "프리뷰 배포 중..."
        vercel --yes
    fi

    log_success "Next.js 배포 완료"
}

# Docker Compose 프로젝트 배포
deploy_docker() {
    local path=$1
    local project=$2

    log_info "Docker Compose 프로젝트 배포 시작..."
    cd "$path"

    # 현재 상태 백업
    log_info "현재 상태 백업..."
    docker compose ps > "/tmp/docker-backup-$project-$TIMESTAMP.txt"

    # 이미지 업데이트
    log_info "이미지 업데이트 중..."
    docker compose pull

    # 서비스 재시작
    log_info "서비스 재시작 중..."
    docker compose up -d

    # 헬스체크 대기
    log_info "헬스체크 대기 중 (30초)..."
    sleep 30

    # 상태 확인
    docker compose ps

    log_success "Docker Compose 배포 완료"
}

# NPM 패키지 배포
deploy_npm() {
    local path=$1

    log_info "NPM 패키지 배포 시작..."
    cd "$path"

    # 빌드
    log_info "빌드 중..."
    npm run build || {
        log_error "빌드 실패"
        exit 1
    }

    # 테스트
    log_info "테스트 실행 중..."
    npm test || {
        log_warn "테스트 실패, 계속 진행합니다"
    }

    # 버전 확인
    local current_version=$(node -p "require('./package.json').version")
    log_info "현재 버전: $current_version"

    # npm publish
    log_info "npm publish 실행 중..."
    npm publish || {
        log_error "npm publish 실패"
        exit 1
    }

    log_success "NPM 패키지 배포 완료: $current_version"
}

# Express 프로젝트 배포 (PM2)
deploy_express() {
    local path=$1
    local project=$2

    log_info "Express 프로젝트 배포 시작..."
    cd "$path"

    # 빌드
    if [ -f "package.json" ] && grep -q '"build"' package.json; then
        log_info "빌드 중..."
        npm run build
    fi

    # PM2로 재시작
    if command -v pm2 &> /dev/null; then
        log_info "PM2로 재시작 중..."
        pm2 restart "$project" || pm2 start npm --name "$project" -- start
    else
        log_warn "PM2가 설치되지 않았습니다"
    fi

    log_success "Express 배포 완료"
}

# 배포 이력 기록
record_deployment() {
    local project=$1
    local env=$2
    local status=$3

    # deployments.json이 없으면 생성
    if [ ! -f "$DEPLOYMENTS_FILE" ]; then
        echo '{"deployments":[]}' > "$DEPLOYMENTS_FILE"
    fi

    # jq가 있으면 JSON 업데이트
    if command -v jq &> /dev/null; then
        local new_deployment=$(cat <<EOF
{
    "id": "deploy-$TIMESTAMP",
    "project": "$project",
    "environment": "$env",
    "status": "$status",
    "deployed_at": "$(date -Iseconds)",
    "deployed_by": "deploy-manager"
}
EOF
)
        jq ".deployments += [$new_deployment]" "$DEPLOYMENTS_FILE" > "/tmp/deployments.tmp" && \
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

    if [ ! -d "$project_path" ]; then
        log_error "프로젝트 경로가 존재하지 않습니다: $project_path"
        exit 1
    fi

    echo ""
    log_info "=========================================="
    log_info "프로젝트: $PROJECT"
    log_info "경로: $project_path"
    log_info "유형: $project_type"
    log_info "환경: $ENVIRONMENT"
    log_info "=========================================="
    echo ""

    # Git 상태 확인
    check_git_status "$project_path"

    # 유형별 배포
    case $project_type in
        "nextjs")
            deploy_nextjs "$project_path" "$ENVIRONMENT"
            ;;
        "docker-compose")
            deploy_docker "$project_path" "$PROJECT"
            ;;
        "npm-package")
            deploy_npm "$project_path"
            ;;
        "express")
            deploy_express "$project_path" "$PROJECT"
            ;;
        *)
            log_error "지원하지 않는 프로젝트 유형: $project_type"
            exit 1
            ;;
    esac

    # 배포 이력 기록
    record_deployment "$PROJECT" "$ENVIRONMENT" "success"

    echo ""
    log_success "=========================================="
    log_success "배포 완료: $PROJECT ($ENVIRONMENT)"
    log_success "시간: $(date)"
    log_success "=========================================="
}

# 실행
main
