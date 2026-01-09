<#
.SYNOPSIS
    Claude Code 설정 동기화 스크립트 (Windows)
.DESCRIPTION
    Ubuntu와 Windows 간 설정 동기화
.EXAMPLE
    .\sync.ps1 pull   # GitHub에서 가져오기
    .\sync.ps1 push   # GitHub에 푸시
    .\sync.ps1 status # 상태 확인
#>

param(
    [ValidateSet("push", "pull", "status")]
    [string]$Action = "pull"
)

$CLAUDE_DIR = "$env:USERPROFILE\.claude"
Set-Location $CLAUDE_DIR

switch ($Action) {
    "push" {
        Write-Host "📤 변경사항을 GitHub에 푸시합니다..." -ForegroundColor Cyan
        git add -A

        # 변경사항 확인
        $changes = git diff --cached --name-only
        if (-not $changes) {
            Write-Host "✅ 푸시할 변경사항이 없습니다." -ForegroundColor Green
            exit 0
        }

        Write-Host ""
        Write-Host "변경된 파일:" -ForegroundColor Yellow
        git diff --cached --name-only
        Write-Host ""

        $msg = Read-Host "커밋 메시지 (Enter=자동)"
        if ([string]::IsNullOrEmpty($msg)) {
            $msg = "chore: 설정 동기화 $(Get-Date -Format 'yyyy-MM-dd HH:mm')"
        }

        git commit -m $msg
        git push origin main
        Write-Host "✅ 푸시 완료!" -ForegroundColor Green
    }

    "pull" {
        Write-Host "📥 GitHub에서 최신 설정을 가져옵니다..." -ForegroundColor Cyan
        git pull origin main
        Write-Host "✅ 동기화 완료!" -ForegroundColor Green
    }

    "status" {
        Write-Host "📊 현재 상태:" -ForegroundColor Cyan
        git status
        Write-Host ""
        Write-Host "📅 마지막 커밋:" -ForegroundColor Cyan
        git log -1 --oneline
    }
}
