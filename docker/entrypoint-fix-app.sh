#!/bin/bash
set -e

echo "🔧 Fixing Appointments app symlink..."

# Wait for Nextcloud to be fully initialized
sleep 10

# Create a symlink from Appointments-master to appointments in the custom_apps directory
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
fi

# Fix permissions
chown -R www-data:www-data /var/www/html/custom_apps/appointments

# Clear cache
php /var/www/html/occ maintenance:repair
php /var/www/html/occ maintenance:update:htaccess
php /var/www/html/occ maintenance:mode --off

echo "✅ Appointments app setup complete!"
