# Fix Appointments app symlink for Nextcloud

Write-Host "🔧 Fixing Appointments app symlink..." -ForegroundColor Cyan

# Check if Docker is running
if (-not (Get-Process -Name "docker" -ErrorAction SilentlyContinue)) {
    Write-Host "❌ Error: Docker is not running. Please start Docker Desktop and try again." -ForegroundColor Red
    exit 1
}

# Check if the containers are running
try {
    $containersRunning = docker-compose ps --services --filter "status=running" | Select-String "nextcloud"
    if (-not $containersRunning) {
        Write-Host "❌ Error: Nextcloud container is not running. Please start it with 'docker-compose up -d' and try again." -ForegroundColor Red
        exit 1
    }
} catch {
    Write-Host "❌ Error: Failed to check container status. Make sure docker-compose is installed and you're in the correct directory." -ForegroundColor Red
    exit 1
}

# Create a symlink from Appointments-master to appointments in the custom_apps directory
try {
    docker-compose exec -T nextcloud bash -c "
        if [ -d /var/www/html/custom_apps/Appointments-master ]; then
            # Create a symlink with the correct name
            ln -sf /var/www/html/custom_apps/Appointments-master /var/www/html/custom_apps/appointments
            echo '✅ Created symlink from Appointments-master to appointments'

            # Enable the app
            php /var/www/html/occ app:enable appointments
            echo '✅ Enabled appointments app'
            exit 0
        else
            echo '❌ Error: Appointments-master directory not found in custom_apps'
            echo 'Make sure the app is properly mounted in the Docker container'
            exit 1
        fi
    "
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ Done! The appointments app should now be properly linked and enabled." -ForegroundColor Green
    } else {
        Write-Host "❌ Failed to create symlink or enable app." -ForegroundColor Red
        exit 1
    }
} catch {
    Write-Host "❌ Error: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

Write-Host "If the app is still not visible, check the Nextcloud logs with: docker-compose logs nextcloud" -ForegroundColor Yellow
