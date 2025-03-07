# Nextcloud App Development Environment Cleanup Script

Write-Host "🧹 Cleaning up NextCloud-App repository..." -ForegroundColor Cyan

# Files to remove (redundant or fixed versions that have been integrated)
$filesToRemove = @(
    ".gitignore-fixed",
    "DOCKER_PERMISSIONS_README-fixed.md",
    "DOCKER_PERMISSIONS_README.md",
    "README-fixed.md",
    "docker-compose-fixed.yml",
    "fix-docker-permissions-fixed.ps1",
    "fix-docker-permissions-fixed.sh",
    "fix-docker-permissions.ps1",
    "fix-docker-permissions.sh",
    "fix-insecure-random.ps1",
    "push-to-github-fixed.sh",
    "push-to-github.ps1",
    "push-to-github.sh",
    "setup-wsl-fixed.ps1",
    "setup-wsl.ps1",
    "start-nextcloud-fixed.ps1",
    "start-nextcloud.ps1",
    "test-docker-environment-fixed.ps1",
    "test-docker-environment.ps1",
    ".devcontainer/setup-fixed.sh",
    "SECURITY_FIXES_SUMMARY.md",
    "cleanup-repo.sh"
)

# Remove files
foreach ($file in $filesToRemove) {
    if (Test-Path -Path $file) {
        Write-Host "Removing $file" -ForegroundColor Yellow
        Remove-Item -Path $file -Force
    }
}

# Ensure secrets directory exists with proper structure
if (-not (Test-Path -Path "secrets")) {
    Write-Host "📁 Creating secrets directory..." -ForegroundColor Cyan
    New-Item -ItemType Directory -Path "secrets" | Out-Null
    
    # Create default secret files
    "nextcloud" | Out-File -FilePath "secrets/mysql_root_password.txt" -NoNewline
    "nextcloud" | Out-File -FilePath "secrets/mysql_password.txt" -NoNewline
    "nextcloud" | Out-File -FilePath "secrets/redis_password.txt" -NoNewline
    "admin" | Out-File -FilePath "secrets/nextcloud_admin_user.txt" -NoNewline
    "admin" | Out-File -FilePath "secrets/nextcloud_admin_password.txt" -NoNewline
    
    # Add .gitkeep file to ensure the directory is committed
    New-Item -ItemType File -Path "secrets/.gitkeep" -Force | Out-Null
    
    Write-Host "✅ Created secrets directory with default values" -ForegroundColor Green
    Write-Host "⚠️  WARNING: For production use, please change these default values!" -ForegroundColor Yellow
}

# Update .gitignore to exclude secret files
$gitignoreContent = Get-Content -Path ".gitignore" -ErrorAction SilentlyContinue
if (-not ($gitignoreContent -match "/secrets/\*.txt")) {
    "`n# Secrets directory`n/secrets/*.txt" | Add-Content -Path ".gitignore"
    Write-Host "✅ Updated .gitignore to exclude secret files" -ForegroundColor Green
}

Write-Host "`n✅ Repository cleanup completed!" -ForegroundColor Green
Write-Host "`n📋 Next steps:" -ForegroundColor Cyan
Write-Host "1. Review the changes"
Write-Host "2. Run 'docker-compose up -d' to start the environment"
Write-Host "3. Access Nextcloud at http://localhost:8080"
