# Nextcloud App Development Environment Startup Script for Windows
Write-Host "Starting Nextcloud App Development Environment..." -ForegroundColor Green

# Check if Docker is installed
try {
    docker --version | Out-Null
} catch {
    Write-Host "Error: Docker is not installed. Please install Docker Desktop for Windows first." -ForegroundColor Red
    exit 1
}

# Check if Docker Compose is installed
$composeV2 = $false
try {
    docker compose version | Out-Null
    $composeV2 = $true
} catch {
    try {
        docker-compose --version | Out-Null
    } catch {
        Write-Host "Error: Docker Compose is not installed. Please install Docker Compose first." -ForegroundColor Red
        exit 1
    }
}

# Check if secrets directory exists, if not create it
if (-not (Test-Path -Path "./secrets")) {
    Write-Host "Creating secrets directory..." -ForegroundColor Yellow
    New-Item -Path "./secrets" -ItemType Directory | Out-Null
    
    # Generate random passwords for services
    Write-Host "Generating random passwords for services..." -ForegroundColor Yellow
    $mysqlRootPassword = -join ((65..90) + (97..122) + (48..57) | Get-Random -Count 32 | ForEach-Object {[char]$_})
    $mysqlPassword = -join ((65..90) + (97..122) + (48..57) | Get-Random -Count 32 | ForEach-Object {[char]$_})
    $redisPassword = -join ((65..90) + (97..122) + (48..57) | Get-Random -Count 32 | ForEach-Object {[char]$_})
    $adminPassword = -join ((65..90) + (97..122) + (48..57) | Get-Random -Count 16 | ForEach-Object {[char]$_})
    
    # Save passwords to files
    $mysqlRootPassword | Out-File -FilePath "./secrets/mysql_root_password.txt" -NoNewline
    $mysqlPassword | Out-File -FilePath "./secrets/mysql_password.txt" -NoNewline
    $redisPassword | Out-File -FilePath "./secrets/redis_password.txt" -NoNewline
    "admin" | Out-File -FilePath "./secrets/nextcloud_admin_user.txt" -NoNewline
    $adminPassword | Out-File -FilePath "./secrets/nextcloud_admin_password.txt" -NoNewline
    
    Write-Host "Default admin username: admin" -ForegroundColor Cyan
    Write-Host "Default admin password: $adminPassword" -ForegroundColor Cyan
    Write-Host "These credentials are stored in the secrets directory." -ForegroundColor Cyan
}

# Start the containers
Write-Host "Starting Docker containers..." -ForegroundColor Yellow
if ($composeV2) {
    # Using Docker Compose V2
    docker compose up -d
} else {
    # Using Docker Compose V1
    docker-compose up -d
}

# Wait for Nextcloud to be ready
Write-Host "Waiting for Nextcloud to be ready..." -ForegroundColor Yellow
Start-Sleep -Seconds 10

# Display access information
Write-Host ""
Write-Host "Nextcloud is now running!" -ForegroundColor Green
Write-Host "Access your Nextcloud instance at: http://localhost:8080" -ForegroundColor Cyan
Write-Host "Admin username: $(Get-Content -Path ./secrets/nextcloud_admin_user.txt -Raw)" -ForegroundColor Cyan
Write-Host "Admin password: $(Get-Content -Path ./secrets/nextcloud_admin_password.txt -Raw)" -ForegroundColor Cyan
Write-Host ""
Write-Host "To stop the environment, run: .\stop.ps1" -ForegroundColor Yellow
