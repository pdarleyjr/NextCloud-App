# PowerShell script to test the Nextcloud Docker environment with the Appointments app securely

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

# Stop any running containers with proper error handling
Write-Host "Stopping any running containers..." -ForegroundColor Yellow
try {
    docker-compose down
    if ($LASTEXITCODE -ne 0) {
        Write-Host "Warning: Failed to stop existing containers. Continuing anyway..." -ForegroundColor Yellow
    }
} catch {
    Write-Host "Error stopping containers: $_" -ForegroundColor Yellow
    Write-Host "Continuing with the test..." -ForegroundColor Yellow
}

# Start the Docker containers with proper error handling
Write-Host "Starting Docker containers..." -ForegroundColor Yellow
try {
    docker-compose up -d
    if ($LASTEXITCODE -ne 0) {
        Write-Host "Failed to start Docker containers. Please check your docker-compose.yml file." -ForegroundColor Red
        exit 1
    }
} catch {
    Write-Host "Error starting Docker containers: $_" -ForegroundColor Red
    exit 1
}

# Wait for Nextcloud to be ready with improved error handling and timeout
Write-Host "Waiting for Nextcloud to be ready..." -ForegroundColor Yellow
$maxRetries = 30
$retryCount = 0
$ready = $false

while (-not $ready -and $retryCount -lt $maxRetries) {
    try {
        $response = Invoke-WebRequest -Uri "http://localhost:8080/status.php" -UseBasicParsing -ErrorAction SilentlyContinue -TimeoutSec 5
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

# Ensure the Appointments app is enabled with proper error handling
Write-Host "Ensuring the Appointments app is enabled..." -ForegroundColor Yellow
try {
    $result = docker-compose exec -u www-data nextcloud php occ app:enable appointments
    if ($LASTEXITCODE -ne 0) {
        Write-Host "Failed to enable Appointments app. Error: $result" -ForegroundColor Red
        Write-Host "This may be because the app is already enabled or there's an issue with the app." -ForegroundColor Yellow
    }
} catch {
    Write-Host "Error enabling Appointments app: $_" -ForegroundColor Red
}

# Run basic tests to verify the environment
Write-Host "Running basic environment tests..." -ForegroundColor Yellow

# Test 1: Verify Nextcloud is responding
try {
    $response = Invoke-WebRequest -Uri "http://localhost:8080/status.php" -UseBasicParsing
    $statusContent = $response.Content | ConvertFrom-Json
    Write-Host "✓ Nextcloud status check passed. Version: $($statusContent.version)" -ForegroundColor Green
} catch {
    Write-Host "✗ Nextcloud status check failed: $_" -ForegroundColor Red
}

# Test 2: Verify database connection
try {
    $dbResult = docker-compose exec -u www-data nextcloud php occ db:status
    if ($dbResult -match "database is working") {
        Write-Host "✓ Database connection test passed" -ForegroundColor Green
    } else {
        Write-Host "✗ Database connection test failed" -ForegroundColor Red
    }
} catch {
    Write-Host "✗ Database connection test failed: $_" -ForegroundColor Red
}

# Display access information with security warning
Write-Host "`nNextcloud is now running!" -ForegroundColor Green
Write-Host "Access Nextcloud at: http://localhost:8080" -ForegroundColor Cyan
Write-Host "Use the default credentials to log in (check your environment documentation)" -ForegroundColor Cyan
Write-Host "WARNING: For security reasons, please change the default password after first login" -ForegroundColor Red
Write-Host "         The default credentials should only be used in development environments" -ForegroundColor Red

Write-Host "`nTo access the Appointments app after logging in:" -ForegroundColor Green
Write-Host "1. Log in to Nextcloud" -ForegroundColor Cyan
Write-Host "2. Click on the Appointments icon in the top navigation bar" -ForegroundColor Cyan
Write-Host "3. You can also access the Therapists section from the navigation menu" -ForegroundColor Cyan
Write-Host "`nTo stop the environment, run: docker-compose down" -ForegroundColor Yellow
