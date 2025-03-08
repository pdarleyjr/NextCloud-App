# PowerShell script to start Nextcloud environment with all fixes applied

Write-Host "🚀 Starting Nextcloud environment with all fixes applied" -ForegroundColor Green

# Check if Docker is running
try {
    docker info | Out-Null
} catch {
    Write-Host "❌ Error: Docker is not running. Please start Docker and try again." -ForegroundColor Red
    exit 1
}

# Create secrets directory if it doesn't exist
if (-not (Test-Path -Path "./secrets")) {
    Write-Host "📁 Creating secrets directory..." -ForegroundColor Yellow
    New-Item -Path "./secrets" -ItemType Directory | Out-Null
    
    # Create default secret files if they don't exist
    Write-Host "Creating default secret files..." -ForegroundColor Cyan
    "nextcloud" | Out-File -FilePath "./secrets/mysql_root_password.txt" -NoNewline
    "nextcloud" | Out-File -FilePath "./secrets/mysql_password.txt" -NoNewline
    "nextcloud" | Out-File -FilePath "./secrets/redis_password.txt" -NoNewline
    "admin" | Out-File -FilePath "./secrets/nextcloud_admin_user.txt" -NoNewline
    "admin" | Out-File -FilePath "./secrets/nextcloud_admin_password.txt" -NoNewline
    
    Write-Host "✅ Created default secret files" -ForegroundColor Green
    Write-Host "⚠️ Warning: Using default passwords. For production, please change these to secure values." -ForegroundColor Yellow
}

# Create docker/php directory if it doesn't exist
if (-not (Test-Path -Path "./docker/php")) {
    Write-Host "📁 Creating docker/php directory..." -ForegroundColor Yellow
    New-Item -Path "./docker/php" -ItemType Directory -Force | Out-Null
    
    # Create default php-custom.ini file
    Write-Host "Creating default php-custom.ini file..." -ForegroundColor Cyan
    $phpIniContent = @"
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
"@
    
    $phpIniContent | Out-File -FilePath "./docker/php/php-custom.ini" -Encoding utf8
    Write-Host "✅ Created default php-custom.ini file" -ForegroundColor Green
}

# Ensure the docker directory exists for our scripts
if (-not (Test-Path -Path "./docker")) {
    Write-Host "📁 Creating docker directory..." -ForegroundColor Yellow
    New-Item -Path "./docker" -ItemType Directory -Force | Out-Null
}

# Start the containers
Write-Host "🐳 Starting Docker containers..." -ForegroundColor Yellow
docker-compose down
docker-compose up -d

Write-Host "⏳ Waiting for Nextcloud to initialize (this may take a minute)..." -ForegroundColor Cyan
Start-Sleep -Seconds 60

# Check if Nextcloud is running
try {
    Invoke-WebRequest -Uri "http://localhost:8080" -UseBasicParsing -ErrorAction Stop | Out-Null
} catch {
    Write-Host "❌ Error: Nextcloud is not responding. Check the logs with 'docker-compose logs nextcloud'." -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "✅ Nextcloud environment is now running with all fixes applied!" -ForegroundColor Green
Write-Host "🌐 Access Nextcloud at: http://localhost:8080" -ForegroundColor Cyan
Write-Host "👤 Default login: admin / admin" -ForegroundColor Cyan
Write-Host ""
Write-Host "📝 The Appointments app should be properly installed and working." -ForegroundColor Green
Write-Host "📋 To view logs: docker-compose logs -f nextcloud" -ForegroundColor Cyan
Write-Host "🛑 To stop the environment: docker-compose down" -ForegroundColor Cyan
