# Nextcloud App Development Environment Cleanup Script

Write-Host "🚀 Starting Nextcloud App Development Environment cleanup..." -ForegroundColor Cyan

# Check if Git is installed
try {
    git --version | Out-Null
} catch {
    Write-Host "❌ Git is not installed. Please install Git and try again." -ForegroundColor Red
    exit 1
}

# Check if we're in a Git repository
try {
    git rev-parse --is-inside-work-tree | Out-Null
} catch {
    Write-Host "❌ Not in a Git repository. Please run this script from the root of the repository." -ForegroundColor Red
    exit 1
}

# Check if there are uncommitted changes
$hasChanges = git diff-index --quiet HEAD -- 2>$null
if ($LASTEXITCODE -ne 0) {
    Write-Host "⚠️ You have uncommitted changes. It's recommended to commit or stash them before running this script." -ForegroundColor Yellow
    $confirm = Read-Host "Do you want to continue anyway? (y/N)"
    if ($confirm -ne "y" -and $confirm -ne "Y") {
        Write-Host "Operation cancelled."
        exit 0
    }
}

# Create secrets directory if it doesn't exist
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

# Update docker-compose.json to use setup.sh instead of setup-fixed.sh
$devcontainerPath = ".devcontainer/devcontainer.json"
if (Test-Path -Path $devcontainerPath) {
    $devcontainerContent = Get-Content -Path $devcontainerPath -Raw
    if ($devcontainerContent -match "setup-fixed.sh") {
        Write-Host "🔧 Updating devcontainer.json to use setup.sh..." -ForegroundColor Cyan
        $devcontainerContent = $devcontainerContent -replace "setup-fixed.sh", "setup.sh"
        Set-Content -Path $devcontainerPath -Value $devcontainerContent
        Write-Host "✅ Updated devcontainer.json" -ForegroundColor Green
    }
}

# Check if docker-compose.yml is using the fixed version
$dockerComposePath = "docker-compose.yml"
if (Test-Path -Path $dockerComposePath) {
    $dockerComposeContent = Get-Content -Path $dockerComposePath -Raw
    if (-not ($dockerComposeContent -match "MYSQL_PASSWORD_FILE")) {
        Write-Host "🔄 Replacing docker-compose.yml with the secure version..." -ForegroundColor Cyan
        if (Test-Path -Path "docker-compose-fixed.yml") {
            Move-Item -Path "docker-compose-fixed.yml" -Destination $dockerComposePath -Force
            Write-Host "✅ Updated docker-compose.yml" -ForegroundColor Green
        } else {
            Write-Host "⚠️  docker-compose-fixed.yml not found. Please manually update docker-compose.yml." -ForegroundColor Yellow
        }
    }
}

Write-Host "`n✅ Cleanup completed successfully!" -ForegroundColor Green
Write-Host "`n📋 Next steps:" -ForegroundColor Cyan
Write-Host "1. Review the changes: git status"
Write-Host "2. Commit the changes: git commit -am 'Clean up repository'"
Write-Host "3. Start the environment: docker-compose up -d"
Write-Host "4. Access Nextcloud at: http://localhost:8080"
Write-Host "`n📚 For more information, see GETTING_STARTED.md"
