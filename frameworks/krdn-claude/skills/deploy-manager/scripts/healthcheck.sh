#!/bin/bash
#
# Deploy Manager - 헬스체크 스크립트
# 사용법: ./healthcheck.sh <project> [--retry N] [--timeout S]
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
log_success() { echo -e "${GREEN}[OK]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[FAIL]${NC} $1"; }

# 기본 설정
DEFAULT_RETRY=3
DEFAULT_TIMEOUT=10
DEFAULT_INTERVAL=5

# 인자 파싱
PROJECT=""
RETRY_COUNT=$DEFAULT_RETRY
TIMEOUT_SECONDS=$DEFAULT_TIMEOUT
RETRY_INTERVAL=$DEFAULT_INTERVAL

while [[ $# -gt 0 ]]; do
    case $1 in
        --retry)
            RETRY_COUNT="$2"
            shift 2
            ;;
        --timeout)
            TIMEOUT_SECONDS="$2"
            shift 2
            ;;
        --interval)
            RETRY_INTERVAL="$2"
            shift 2
            ;;
        *)
            PROJECT="$1"
            shift
            ;;
    esac
done

if [ -z "$PROJECT" ]; then
    log_error "프로젝트명을 지정해주세요"
    echo "사용법: $0 <project> [--retry N] [--timeout S] [--interval S]"
    echo ""
    echo "프로젝트:"
    echo "  ai-note-taking, home, docker-n8n, news-sentiment-analyzer, gonsai2"
    exit 1
fi

# 프로젝트별 헬스체크 엔드포인트
get_health_endpoint() {
    case $1 in
        "ai-note-taking")
            echo "http://localhost:3000/api/health"
            ;;
        "home")
            echo "https://krdn.kr"
            ;;
        "home-krdn")
            echo "http://localhost:3001"
            ;;
        "docker-n8n")
            echo "http://localhost:5678/healthz"
            ;;
        "news-sentiment-analyzer")
            echo "http://localhost:3010/_stcore/health"
            ;;
        "gonsai2")
            echo "http://localhost:3002/health"
            ;;
        "claude-code-auto")
            echo "npm-package"  # 특수 케이스
            ;;
        *)
            echo ""
            ;;
    esac
}

# HTTP 헬스체크
check_http_health() {
    local url=$1
    local timeout=$2

    local start_time=$(date +%s%N)
    local http_code=$(curl -s -o /dev/null -w "%{http_code}" --connect-timeout $timeout --max-time $timeout "$url" 2>/dev/null || echo "000")
    local end_time=$(date +%s%N)

    local response_time=$(( (end_time - start_time) / 1000000 ))

    if [ "$http_code" = "200" ] || [ "$http_code" = "201" ] || [ "$http_code" = "204" ]; then
        echo "success|$http_code|$response_time"
    else
        echo "failure|$http_code|$response_time"
    fi
}

# Docker 헬스체크
check_docker_health() {
    local project=$1
    local compose_dir=""

    case $project in
        "docker-n8n")
            compose_dir="/home/gon/docker-n8n"
            ;;
        "news-sentiment-analyzer")
            compose_dir="/data/home-data/projects/n8n/news-sentiment-analyzer2"
            ;;
        *)
            return 1
            ;;
    esac

    if [ -d "$compose_dir" ]; then
        cd "$compose_dir"
        local unhealthy=$(docker compose ps --format json 2>/dev/null | jq -r 'select(.Health == "unhealthy") | .Name' | wc -l)
        local not_running=$(docker compose ps --format json 2>/dev/null | jq -r 'select(.State != "running") | .Name' | wc -l)

        if [ "$unhealthy" -gt 0 ] || [ "$not_running" -gt 0 ]; then
            echo "failure|unhealthy:$unhealthy,not_running:$not_running"
        else
            echo "success|all_healthy"
        fi
    else
        echo "failure|directory_not_found"
    fi
}

# NPM 패키지 체크 (npm view로 확인)
check_npm_health() {
    local package_name=$1

    if npm view "$package_name" version &>/dev/null; then
        local version=$(npm view "$package_name" version 2>/dev/null)
        echo "success|version:$version"
    else
        echo "failure|not_found"
    fi
}

# 메인 헬스체크 로직
run_healthcheck() {
    local project=$1
    local endpoint=$(get_health_endpoint "$project")

    if [ -z "$endpoint" ]; then
        log_error "알 수 없는 프로젝트: $project"
        return 1
    fi

    echo ""
    log_info "=========================================="
    log_info "헬스체크 시작: $project"
    log_info "엔드포인트: $endpoint"
    log_info "재시도: $RETRY_COUNT회, 타임아웃: ${TIMEOUT_SECONDS}초"
    log_info "=========================================="
    echo ""

    local attempt=1
    local success=false

    while [ $attempt -le $RETRY_COUNT ]; do
        log_info "시도 $attempt/$RETRY_COUNT..."

        local result=""

        # 프로젝트 유형별 체크
        if [ "$endpoint" = "npm-package" ]; then
            result=$(check_npm_health "claude-code-auto")
        elif [[ "$project" == "docker-n8n" ]] || [[ "$project" == "news-sentiment-analyzer" ]]; then
            # Docker 프로젝트는 HTTP + Docker 상태 모두 체크
            local http_result=$(check_http_health "$endpoint" "$TIMEOUT_SECONDS")
            local docker_result=$(check_docker_health "$project")

            local http_status=$(echo "$http_result" | cut -d'|' -f1)
            local docker_status=$(echo "$docker_result" | cut -d'|' -f1)

            if [ "$http_status" = "success" ] && [ "$docker_status" = "success" ]; then
                result="success|http_ok,docker_ok"
            else
                result="failure|http:$http_status,docker:$docker_status"
            fi
        else
            result=$(check_http_health "$endpoint" "$TIMEOUT_SECONDS")
        fi

        local status=$(echo "$result" | cut -d'|' -f1)
        local details=$(echo "$result" | cut -d'|' -f2-)

        if [ "$status" = "success" ]; then
            log_success "헬스체크 성공 ($details)"
            success=true
            break
        else
            log_warn "헬스체크 실패 ($details)"

            if [ $attempt -lt $RETRY_COUNT ]; then
                log_info "${RETRY_INTERVAL}초 후 재시도..."
                sleep $RETRY_INTERVAL
            fi
        fi

        ((attempt++))
    done

    echo ""

    if [ "$success" = true ]; then
        log_success "=========================================="
        log_success "헬스체크 완료: $project - 성공"
        log_success "=========================================="
        return 0
    else
        log_error "=========================================="
        log_error "헬스체크 실패: $project"
        log_error "$RETRY_COUNT회 재시도 후에도 실패"
        log_error "=========================================="
        return 1
    fi
}

# 모든 프로젝트 헬스체크
check_all_projects() {
    local projects=("docker-n8n" "news-sentiment-analyzer" "home")
    local failed=()

    echo ""
    log_info "=========================================="
    log_info "전체 프로덕션 서비스 헬스체크"
    log_info "=========================================="
    echo ""

    for project in "${projects[@]}"; do
        if run_healthcheck "$project"; then
            log_success "$project: OK"
        else
            log_error "$project: FAIL"
            failed+=("$project")
        fi
        echo ""
    done

    echo ""
    log_info "=========================================="
    if [ ${#failed[@]} -eq 0 ]; then
        log_success "모든 서비스 정상"
    else
        log_error "실패한 서비스: ${failed[*]}"
    fi
    log_info "=========================================="

    return ${#failed[@]}
}

# 실행
if [ "$PROJECT" = "all" ]; then
    check_all_projects
else
    run_healthcheck "$PROJECT"
fi
