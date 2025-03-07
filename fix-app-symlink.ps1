# PowerShell script to fix Appointments app symlink
Write-Host "🔧 Fixing Appointments app symlink..." -ForegroundColor Green

# Check if Docker is running
$dockerRunning = Get-Process -Name "Docker Desktop" -ErrorAction SilentlyContinue
if (-not $dockerRunning) {
    Write-Host "Docker Desktop is not running. Please start Docker Desktop and try again." -ForegroundColor Red
    exit 1
}

# Create a symlink from Appointments-master to appointments in the custom_apps directory
Write-Host "Creating symlink from Appointments-master to appointments..." -ForegroundColor Yellow
try {
    $result = docker-compose exec -u www-data nextcloud bash -c "
        if [ -d /var/www/html/custom_apps/Appointments-master ]; then
            # Create a symlink with the correct name
            ln -sf /var/www/html/custom_apps/Appointments-master /var/www/html/custom_apps/appointments
            echo 'Created symlink from Appointments-master to appointments'

            # Enable the app
            php /var/www/html/occ app:enable appointments
            echo 'Enabled appointments app'
            exit 0
        else
            echo 'Error: Appointments-master directory not found in custom_apps'
            echo 'Make sure the app is properly mounted in the Docker container'
            exit 1
        fi
    "

    if ($LASTEXITCODE -ne 0) {
        Write-Host "Failed to create symlink. Error: $result" -ForegroundColor Red
        Write-Host "Make sure the app is properly mounted in the Docker container." -ForegroundColor Yellow
        exit 1
    }

    Write-Host "✅ Successfully created symlink and enabled the app." -ForegroundColor Green
} catch {
    Write-Host "Error creating symlink: $_" -ForegroundColor Red
    exit 1
}

Write-Host "`nDone! The appointments app should now be properly linked and enabled." -ForegroundColor Green
Write-Host "If it's still not visible, check the Nextcloud logs with: docker-compose logs nextcloud" -ForegroundColor Cyan
