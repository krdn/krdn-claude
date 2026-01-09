<#
.SYNOPSIS
    Claude Code Windows 설정 스크립트
.DESCRIPTION
    Ubuntu와 동일한 환경을 Windows에서 구성합니다.
    - 개발자 모드 확인
    - Git symlinks 설정
    - 저장소 클론 (심볼릭 링크 포함)
.NOTES
    사용법: PowerShell에서 실행
    .\setup-windows.ps1
#>

param(
    [switch]$Force,
    [switch]$SkipDevModeCheck
)

$ErrorActionPreference = "Stop"

# 색상 함수
function Write-Info { param($msg) Write-Host "[INFO] $msg" -ForegroundColor Green }
function Write-Warn { param($msg) Write-Host "[WARN] $msg" -ForegroundColor Yellow }
function Write-Err { param($msg) Write-Host "[ERROR] $msg" -ForegroundColor Red }

# 설정
$CLAUDE_DIR = "$env:USERPROFILE\.claude"
$REPO_URL = "https://github.com/krdn/krdn-claude.git"

Write-Host ""
Write-Host "╔═══════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║     Claude Code Windows Setup Script                  ║" -ForegroundColor Cyan
Write-Host "║     Ubuntu와 동일한 환경 구성                          ║" -ForegroundColor Cyan
Write-Host "╚═══════════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

# ═══════════════════════════════════════════════════════════════
# 1. 개발자 모드 확인
# ═══════════════════════════════════════════════════════════════
Write-Info "1단계: 개발자 모드 확인..."

if (-not $SkipDevModeCheck) {
    try {
        $devMode = Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock" -Name "AllowDevelopmentWithoutDevLicense" -ErrorAction SilentlyContinue

        if ($devMode.AllowDevelopmentWithoutDevLicense -ne 1) {
            Write-Warn "개발자 모드가 비활성화되어 있습니다!"
            Write-Host ""
            Write-Host "  개발자 모드를 활성화하려면:" -ForegroundColor Yellow
            Write-Host "  1. 설정 → 개인 정보 및 보안 → 개발자용" -ForegroundColor White
            Write-Host "  2. '개발자 모드' 토글을 켜기" -ForegroundColor White
            Write-Host ""
            Write-Host "  또는 PowerShell (관리자)에서:" -ForegroundColor Yellow
            Write-Host '  reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock" /t REG_DWORD /f /v "AllowDevelopmentWithoutDevLicense" /d "1"' -ForegroundColor Gray
            Write-Host ""

            $continue = Read-Host "개발자 모드 없이 계속하시겠습니까? (관리자 권한 필요) [y/N]"
            if ($continue -ne 'y' -and $continue -ne 'Y') {
                Write-Info "설정을 활성화한 후 다시 실행해 주세요."
                exit 0
            }
        } else {
            Write-Info "개발자 모드 활성화됨 ✓"
        }
    } catch {
        Write-Warn "개발자 모드 상태를 확인할 수 없습니다. 계속 진행합니다."
    }
}

# ═══════════════════════════════════════════════════════════════
# 2. Git 확인 및 symlinks 설정
# ═══════════════════════════════════════════════════════════════
Write-Info "2단계: Git 설정..."

# Git 설치 확인
try {
    $gitVersion = git --version
    Write-Info "Git 설치됨: $gitVersion"
} catch {
    Write-Err "Git이 설치되어 있지 않습니다!"
    Write-Host "  https://git-scm.com/download/win 에서 설치하세요." -ForegroundColor Yellow
    exit 1
}

# Git symlinks 설정
Write-Info "Git symlinks 설정 중..."
git config --global core.symlinks true
Write-Info "core.symlinks = true 설정됨 ✓"

# ═══════════════════════════════════════════════════════════════
# 3. 기존 설정 백업
# ═══════════════════════════════════════════════════════════════
Write-Info "3단계: 기존 설정 확인..."

if (Test-Path $CLAUDE_DIR) {
    if (Test-Path "$CLAUDE_DIR\.git") {
        Write-Info "기존 Git 저장소 발견. 업데이트합니다..."
        Push-Location $CLAUDE_DIR
        git pull origin main
        Pop-Location
        Write-Info "업데이트 완료! ✓"
        exit 0
    }

    $timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
    $backupDir = "$CLAUDE_DIR.backup.$timestamp"
    Write-Warn "기존 설정을 백업합니다: $backupDir"
    Move-Item $CLAUDE_DIR $backupDir
}

# ═══════════════════════════════════════════════════════════════
# 4. 저장소 클론 (심볼릭 링크 포함)
# ═══════════════════════════════════════════════════════════════
Write-Info "4단계: 저장소 클론 중..."

git clone -c core.symlinks=true $REPO_URL $CLAUDE_DIR

if ($LASTEXITCODE -ne 0) {
    Write-Err "클론 실패!"
    exit 1
}

Write-Info "클론 완료 ✓"

# ═══════════════════════════════════════════════════════════════
# 5. 심볼릭 링크 확인 및 수정
# ═══════════════════════════════════════════════════════════════
Write-Info "5단계: 심볼릭 링크 확인..."

$links = @(
    @{Name="agents"; Target="frameworks\krdn-claude\agents"},
    @{Name="commands"; Target="frameworks\krdn-claude\commands"},
    @{Name="knowledge"; Target="frameworks\krdn-claude\knowledge"},
    @{Name="orchestration"; Target="frameworks\krdn-claude\orchestration"},
    @{Name="rules"; Target="frameworks\krdn-claude\rules"}
)

$needsFix = $false
foreach ($link in $links) {
    $linkPath = Join-Path $CLAUDE_DIR $link.Name
    $targetPath = Join-Path $CLAUDE_DIR $link.Target

    if (Test-Path $linkPath) {
        $item = Get-Item $linkPath -Force
        if ($item.LinkType -eq "SymbolicLink") {
            Write-Host "  ✓ $($link.Name) → 심볼릭 링크 정상" -ForegroundColor Green
        } else {
            Write-Host "  ✗ $($link.Name) → 심볼릭 링크 아님" -ForegroundColor Red
            $needsFix = $true
        }
    } else {
        Write-Host "  ✗ $($link.Name) → 존재하지 않음" -ForegroundColor Red
        $needsFix = $true
    }
}

# 심볼릭 링크 수동 생성 필요 시
if ($needsFix) {
    Write-Warn "심볼릭 링크를 수동으로 생성합니다..."

    foreach ($link in $links) {
        $linkPath = Join-Path $CLAUDE_DIR $link.Name
        $targetPath = Join-Path $CLAUDE_DIR $link.Target

        # 기존 파일/폴더 제거
        if (Test-Path $linkPath) {
            Remove-Item $linkPath -Recurse -Force
        }

        # 심볼릭 링크 생성
        try {
            New-Item -ItemType SymbolicLink -Path $linkPath -Target $targetPath -Force | Out-Null
            Write-Host "  ✓ $($link.Name) 생성됨" -ForegroundColor Green
        } catch {
            Write-Err "  ✗ $($link.Name) 생성 실패: $_"
            Write-Host "    관리자 권한으로 다시 실행하거나 개발자 모드를 활성화하세요." -ForegroundColor Yellow
        }
    }
}

# ═══════════════════════════════════════════════════════════════
# 6. 로컬 설정 파일 생성
# ═══════════════════════════════════════════════════════════════
Write-Info "6단계: 로컬 설정 파일 생성..."

$localSettings = Join-Path $CLAUDE_DIR "settings.local.json"
if (-not (Test-Path $localSettings)) {
    $defaultLocalSettings = @"
{
  "permissions": {
    "allow": [],
    "deny": []
  }
}
"@
    Set-Content -Path $localSettings -Value $defaultLocalSettings -Encoding UTF8
    Write-Info "settings.local.json 생성됨 ✓"
} else {
    Write-Info "settings.local.json 이미 존재함 ✓"
}

# ═══════════════════════════════════════════════════════════════
# 완료
# ═══════════════════════════════════════════════════════════════
Write-Host ""
Write-Host "╔═══════════════════════════════════════════════════════╗" -ForegroundColor Green
Write-Host "║                    설정 완료! ✓                       ║" -ForegroundColor Green
Write-Host "╚═══════════════════════════════════════════════════════╝" -ForegroundColor Green
Write-Host ""
Write-Host "다음 단계:" -ForegroundColor Cyan
Write-Host "  1. claude login          # Claude Code 로그인" -ForegroundColor White
Write-Host "  2. claude                # Claude Code 시작" -ForegroundColor White
Write-Host ""
Write-Host "설정 위치: $CLAUDE_DIR" -ForegroundColor Gray
Write-Host ""
