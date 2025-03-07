# PowerShell script to test the Nextcloud Docker environment with the Appointments app

Write-Host "Testing Nextcloud Docker environment with Appointments app..." -ForegroundColor Green

# Check if Docker is running
$dockerRunning = Get-Process -Name "Docker Desktop" -ErrorAction SilentlyContinue
if (-not $dockerRunning) {
    Write-Host "Docker Desktop is not running. Please start Docker Desktop and try again." -ForegroundColor Red
    exit 1
}

# Check if docker-compose.yml exists
if (-not (Test-Path "docker-compose.yml")) {
    Write-Host "docker-compose.yml not found. Please run this script from the Nextcloud App directory." -ForegroundColor Red
    exit 1
}

# Check if the Appointments app exists
if (-not (Test-Path "Repos/Appointments-master")) {
    Write-Host "Appointments app not found in Repos directory. Please ensure it's in the correct location." -ForegroundColor Red
    exit 1
}

# Stop any running containers
Write-Host "Stopping any running containers..." -ForegroundColor Yellow
docker-compose down

# Start the Docker containers
Write-Host "Starting Docker containers..." -ForegroundColor Yellow
docker-compose up -d

# Wait for Nextcloud to be ready
Write-Host "Waiting for Nextcloud to be ready..." -ForegroundColor Yellow
$maxRetries = 30
$retryCount = 0
$ready = $false

while (-not $ready -and $retryCount -lt $maxRetries) {
    try {
        $response = Invoke-WebRequest -Uri "http://localhost:8080/status.php" -UseBasicParsing -ErrorAction SilentlyContinue
        if ($response.StatusCode -eq 200) {
            $ready = $true
        }
    } catch {
        Start-Sleep -Seconds 5
        $retryCount++
        Write-Host "Waiting for Nextcloud to start... ($retryCount/$maxRetries)" -ForegroundColor Yellow
    }
}

if (-not $ready) {
    Write-Host "Nextcloud did not start properly. Please check the Docker logs." -ForegroundColor Red
    Write-Host "You can view logs with: docker-compose logs" -ForegroundColor Yellow
    exit 1
}

# Ensure the Appointments app is enabled
Write-Host "Ensuring the Appointments app is enabled..." -ForegroundColor Yellow
docker-compose exec -u www-data nextcloud php occ app:enable appointments

# Display access information
Write-Host "`nNextcloud is now running!" -ForegroundColor Green
Write-Host "Access Nextcloud at: http://localhost:8080" -ForegroundColor Cyan
Write-Host "Use the default credentials to log in (check your environment documentation)" -ForegroundColor Cyan
Write-Host "Note: For security reasons, please change the default password after first login" -ForegroundColor Yellow

Write-Host "`nTo access the Appointments app after logging in:" -ForegroundColor Green
Write-Host "1. Log in to Nextcloud" -ForegroundColor Cyan
Write-Host "2. Click on the Appointments icon in the top navigation bar" -ForegroundColor Cyan
Write-Host "3. You can also access the Therapists section from the navigation menu" -ForegroundColor Cyan
Write-Host "`nTo stop the environment, run: docker-compose down" -ForegroundColor Yellow
