#!/bin/bash
set -e

echo "🔧 Fixing Appointments app symlink..."

# Create a symlink from Appointments-master to appointments in the custom_apps directory
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

echo "✅ Done! The appointments app should now be properly linked and enabled."
echo "   If it's still not visible, check the Nextcloud logs with: docker-compose logs nextcloud"
