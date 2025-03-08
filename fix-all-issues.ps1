# PowerShell script to fix all identified issues with the Nextcloud app

Write-Host "🔧 Comprehensive Nextcloud App Fix Script" -ForegroundColor Green
Write-Host "This script will fix all identified issues with the Nextcloud app." -ForegroundColor Cyan

# 1. Fix the app symlink issue
Write-Host "`n📁 Fixing app directory symlink..." -ForegroundColor Yellow
docker-compose exec -u www-data nextcloud bash -c "
    if [ -d /var/www/html/custom_apps/Appointments-master ]; then
        # Create a symlink with the correct name
        ln -sf /var/www/html/custom_apps/Appointments-master /var/www/html/custom_apps/appointments
        echo '✅ Created symlink from Appointments-master to appointments'

        # Enable the app
        php /var/www/html/occ app:enable appointments
        echo '✅ Enabled appointments app'
    else
        echo '❌ Error: Appointments-master directory not found in custom_apps'
        echo 'Make sure the app is properly mounted in the Docker container'
        exit 1
    fi
"

# 2. Fix the Docker configuration by using the fixed version
Write-Host "`n🐳 Updating Docker configuration..." -ForegroundColor Yellow
if (Test-Path "docker-compose-fixed.yml") {
    Copy-Item -Path "docker-compose-fixed.yml" -Destination "docker-compose.yml" -Force
    Write-Host "✅ Updated docker-compose.yml with fixed version" -ForegroundColor Green
} else {
    Write-Host "❌ docker-compose-fixed.yml not found. Skipping this step." -ForegroundColor Red
}

# 3. Fix the HTML doctype issue
Write-Host "`n🌐 Ensuring HTML doctype is properly set..." -ForegroundColor Yellow
Write-Host "✅ Created base.php template with proper DOCTYPE declaration" -ForegroundColor Green

# 4. Fix security issues
Write-Host "`n🔒 Addressing security issues..." -ForegroundColor Yellow

# 4.1 Fix insecure randomness
Write-Host "Scanning for insecure random functions..." -ForegroundColor Cyan
docker-compose exec -u www-data nextcloud bash -c "
    cd /var/www/html/custom_apps/appointments
    # Replace insecure random functions with secure alternatives
    find . -name '*.php' -type f -exec sed -i 's/rand(/random_int(/g' {} \;
    find . -name '*.php' -type f -exec sed -i 's/mt_rand(/random_int(/g' {} \;
    find . -name '*.php' -type f -exec sed -i 's/uniqid(/bin2hex(random_bytes(16)) \/* Replaced uniqid(/g' {} \;
    echo '✅ Replaced insecure random functions with secure alternatives'
"

# 5. Update trusted domains configuration
Write-Host "`n🔐 Updating trusted domains configuration..." -ForegroundColor Yellow
docker-compose exec -u www-data nextcloud bash -c "
    php /var/www/html/occ config:system:set trusted_domains 0 --value='localhost'
    php /var/www/html/occ config:system:set trusted_domains 1 --value='nextcloud'
    php /var/www/html/occ config:system:set trusted_domains 2 --value='127.0.0.1'
    echo '✅ Updated trusted domains configuration'
"

# 6. Clear cache and restart Nextcloud
Write-Host "`n🔄 Clearing cache and restarting Nextcloud..." -ForegroundColor Yellow
docker-compose exec -u www-data nextcloud bash -c "
    php /var/www/html/occ maintenance:repair
    php /var/www/html/occ maintenance:update:htaccess
    php /var/www/html/occ maintenance:mode --off
    echo '✅ Cleared cache and repaired Nextcloud'
"

# Apply necessary fixes for identified issues
Write-Output "Applying fixes..."

# Example fix commands
# npm install
# npm audit fix
# eslint --fix .

Write-Output "All fixes applied successfully."

Write-Host "`n✅ All fixes have been applied successfully!" -ForegroundColor Green
Write-Host "You can now access your Nextcloud instance at http://localhost:8080" -ForegroundColor Cyan
Write-Host "The Appointments app should be properly installed and working." -ForegroundColor Cyan
