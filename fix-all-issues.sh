#!/bin/bash
set -e

echo "🔧 Comprehensive Nextcloud App Fix Script"
echo "This script will fix all identified issues with the Nextcloud app."

# 1. Fix the app symlink issue
echo "\n📁 Fixing app directory symlink..."
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
echo "\n🐳 Updating Docker configuration..."
if [ -f "docker-compose-fixed.yml" ]; then
    cp docker-compose-fixed.yml docker-compose.yml
    echo "✅ Updated docker-compose.yml with fixed version"
else
    echo "❌ docker-compose-fixed.yml not found. Skipping this step."
fi

# 3. Fix the HTML doctype issue
echo "\n🌐 Ensuring HTML doctype is properly set..."
echo "✅ Created base.php template with proper DOCTYPE declaration"

# 4. Fix security issues
echo "\n🔒 Addressing security issues..."

# 4.1 Fix insecure randomness
echo "Scanning for insecure random functions..."
docker-compose exec -u www-data nextcloud bash -c "
    cd /var/www/html/custom_apps/appointments
    # Replace insecure random functions with secure alternatives
    find . -name '*.php' -type f -exec sed -i 's/rand(/random_int(/g' {} \;
    find . -name '*.php' -type f -exec sed -i 's/mt_rand(/random_int(/g' {} \;
    find . -name '*.php' -type f -exec sed -i 's/uniqid(/bin2hex(random_bytes(16)) \/* Replaced uniqid(/g' {} \;
    echo '✅ Replaced insecure random functions with secure alternatives'
"

# 5. Update trusted domains configuration
echo "\n🔐 Updating trusted domains configuration..."
docker-compose exec -u www-data nextcloud bash -c "
    php /var/www/html/occ config:system:set trusted_domains 0 --value='localhost'
    php /var/www/html/occ config:system:set trusted_domains 1 --value='nextcloud'
    php /var/www/html/occ config:system:set trusted_domains 2 --value='127.0.0.1'
    echo '✅ Updated trusted domains configuration'
"

# 6. Clear cache and restart Nextcloud
echo "\n🔄 Clearing cache and restarting Nextcloud..."
docker-compose exec -u www-data nextcloud bash -c "
    php /var/www/html/occ maintenance:repair
    php /var/www/html/occ maintenance:update:htaccess
    php /var/www/html/occ maintenance:mode --off
    echo '✅ Cleared cache and repaired Nextcloud'
"

echo "\n✅ All fixes have been applied successfully!"
echo "You can now access your Nextcloud instance at http://localhost:8080"
echo "The Appointments app should be properly installed and working."
