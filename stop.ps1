# Nextcloud App Development Environment Stop Script for Windows
Write-Host "Stopping Nextcloud App Development Environment..." -ForegroundColor Yellow

# Check if Docker is installed
try {
    docker --version | Out-Null
} catch {
    Write-Host "Error: Docker is not installed. Please install Docker Desktop for Windows first." -ForegroundColor Red
    exit 1
}

# Stop the containers
Write-Host "Stopping Docker containers..." -ForegroundColor Yellow
$composeV2 = $false
try {
    docker compose version | Out-Null
    $composeV2 = $true
} catch {}

if ($composeV2) {
    # Using Docker Compose V2
    docker compose down
} else {
    # Using Docker Compose V1
    docker-compose down
}

Write-Host ""
Write-Host "Nextcloud environment has been stopped." -ForegroundColor Green
Write-Host "To start the environment again, run: .\start.ps1" -ForegroundColor Cyan
