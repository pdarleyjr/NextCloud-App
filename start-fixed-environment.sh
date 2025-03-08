#!/bin/bash
set -e

echo "🚀 Starting Nextcloud environment with all fixes applied"

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    echo "❌ Error: Docker is not running. Please start Docker and try again."
    exit 1
fi

# Create secrets directory if it doesn't exist
if [ ! -d "./secrets" ]; then
    echo "📁 Creating secrets directory..."
    mkdir -p ./secrets
    
    # Create default secret files if they don't exist
    echo "Creating default secret files..."
    echo "nextcloud" > ./secrets/mysql_root_password.txt
    echo "nextcloud" > ./secrets/mysql_password.txt
    echo "nextcloud" > ./secrets/redis_password.txt
    echo "admin" > ./secrets/nextcloud_admin_user.txt
    echo "admin" > ./secrets/nextcloud_admin_password.txt
    
    echo "✅ Created default secret files"
    echo "⚠️ Warning: Using default passwords. For production, please change these to secure values."
fi

# Create docker/php directory if it doesn't exist
if [ ! -d "./docker/php" ]; then
    echo "📁 Creating docker/php directory..."
    mkdir -p ./docker/php
    
    # Create default php-custom.ini file
    echo "Creating default php-custom.ini file..."
    cat > ./docker/php/php-custom.ini << 'EOF'
; Custom PHP settings
upload_max_filesize = 512M
post_max_size = 512M
memory_limit = 512M
max_execution_time = 300
max_input_time = 300

; Enable opcache for better performance
opcache.enable = 1
opcache.enable_cli = 1
opcache.memory_consumption = 128
opcache.interned_strings_buffer = 8
opcache.max_accelerated_files = 10000
opcache.revalidate_freq = 1
opcache.save_comments = 1

; Security settings
expose_php = Off
display_errors = Off
log_errors = On
error_reporting = E_ALL & ~E_DEPRECATED & ~E_STRICT
session.use_strict_mode = 1
session.cookie_secure = 1
session.cookie_httponly = 1
session.cookie_samesite = "Lax"
EOF
    
    echo "✅ Created default php-custom.ini file"
fi

# Ensure the docker directory exists for our scripts
if [ ! -d "./docker" ]; then
    echo "📁 Creating docker directory..."
    mkdir -p ./docker
fi

# Start the containers
echo "🐳 Starting Docker containers..."
docker-compose down
docker-compose up -d

echo "⏳ Waiting for Nextcloud to initialize (this may take a minute)..."
sleep 60

# Check if Nextcloud is running
if ! curl -s http://localhost:8080 > /dev/null; then
    echo "❌ Error: Nextcloud is not responding. Check the logs with 'docker-compose logs nextcloud'."
    exit 1
fi

echo ""
echo "✅ Nextcloud environment is now running with all fixes applied!"
echo "🌐 Access Nextcloud at: http://localhost:8080"
echo "👤 Default login: admin / admin"
echo ""
echo "📝 The Appointments app should be properly installed and working."
echo "📋 To view logs: docker-compose logs -f nextcloud"
echo "🛑 To stop the environment: docker-compose down"
