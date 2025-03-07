# PowerShell script to start Nextcloud with the Appointments app
Write-Host "Starting Nextcloud environment with Appointments app..." -ForegroundColor Green

# Check if Docker is running
$dockerRunning = Get-Process -Name "Docker Desktop" -ErrorAction SilentlyContinue
if (-not $dockerRunning) {
    Write-Host "Docker Desktop is not running. Please start Docker Desktop and try again." -ForegroundColor Red
    exit 1
}

# Check if Docker permissions are set correctly
Write-Host "Checking Docker permissions..." -ForegroundColor Yellow
$permissionsOk = $true
try {
    docker ps > $null
} catch {
    $permissionsOk = $false
}

if (-not $permissionsOk) {
    Write-Host "Docker permissions issue detected. Running fix-docker-permissions.ps1..." -ForegroundColor Yellow
    powershell -ExecutionPolicy Bypass -File fix-docker-permissions.ps1
}

# Start the Docker containers
Write-Host "Starting Docker containers..." -ForegroundColor Yellow
docker-compose down
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
Write-Host "`nTo stop the environment, run: docker-compose down" -ForegroundColor Yellow
