# PowerShell script to start Nextcloud with the Appointments app securely
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
    Write-Host "Docker permissions issue detected." -ForegroundColor Yellow

    # Ask for confirmation before running the fix script
    $confirmation = Read-Host "Do you want to run the Docker permissions fix script? (y/n)"
    if ($confirmation -eq 'y') {
        # Run the script with proper error handling
        try {
            # Use a more secure approach than ExecutionPolicy Bypass
            # Check if the script exists first
            if (Test-Path "fix-docker-permissions.ps1") {
                & powershell -File fix-docker-permissions.ps1
                if ($LASTEXITCODE -ne 0) {
                    Write-Host "Docker permissions fix script failed with exit code $LASTEXITCODE" -ForegroundColor Red
                    exit 1
                }
            } else {
                Write-Host "Docker permissions fix script not found." -ForegroundColor Red
                exit 1
            }
        } catch {
            Write-Host "Error running Docker permissions fix script: $_" -ForegroundColor Red
            exit 1
        }
    } else {
        Write-Host "Docker permissions fix skipped. You may encounter permission issues." -ForegroundColor Yellow
    }
}

# Start the Docker containers with proper error handling
Write-Host "Starting Docker containers..." -ForegroundColor Yellow
try {
    docker-compose down
    if ($LASTEXITCODE -ne 0) {
        Write-Host "Failed to stop existing containers. Continuing anyway..." -ForegroundColor Yellow
    }

    docker-compose up -d
    if ($LASTEXITCODE -ne 0) {
        Write-Host "Failed to start Docker containers. Please check your docker-compose.yml file." -ForegroundColor Red
        exit 1
    }
} catch {
    Write-Host "Error starting Docker containers: $_" -ForegroundColor Red
    exit 1
}

# Wait for Nextcloud to be ready with improved error handling
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

# Display access information with security warning
Write-Host "`nNextcloud is now running!" -ForegroundColor Green
Write-Host "Access Nextcloud at: http://localhost:8080" -ForegroundColor Cyan
Write-Host "Use the default credentials to log in (check your environment documentation)" -ForegroundColor Cyan
Write-Host "WARNING: For security reasons, please change the default password after first login" -ForegroundColor Red
Write-Host "         The default credentials should only be used in development environments" -ForegroundColor Red

Write-Host "`nTo access the Appointments app after logging in:" -ForegroundColor Green
Write-Host "1. Log in to Nextcloud" -ForegroundColor Cyan
Write-Host "2. Click on the Appointments icon in the top navigation bar" -ForegroundColor Cyan
Write-Host "`nTo stop the environment, run: docker-compose down" -ForegroundColor Yellow
