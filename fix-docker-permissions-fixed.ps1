# PowerShell script to fix Docker permissions in WSL securely

Write-Host "Fixing Docker permissions in WSL..." -ForegroundColor Green

# Check if running with administrator privileges
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Host "This script requires administrator privileges. Please run PowerShell as Administrator and try again." -ForegroundColor Red
    exit 1
}

# Get current Windows username with validation
$currentUser = $env:USERNAME
if ([string]::IsNullOrEmpty($currentUser)) {
    Write-Host "Could not determine current user. Please specify username:" -ForegroundColor Yellow
    $currentUser = Read-Host "Enter username"
    if ([string]::IsNullOrEmpty($currentUser)) {
        Write-Host "No username provided. Exiting." -ForegroundColor Red
        exit 1
    }
}

# Check if WSL is installed
$wslInstalled = Get-Command wsl -ErrorAction SilentlyContinue
if (-not $wslInstalled) {
    Write-Host "WSL is not installed. Please install WSL first." -ForegroundColor Red
    exit 1
}

# Check if Ubuntu is installed in WSL
$ubuntuInstalled = wsl --list | Select-String "Ubuntu"
if (-not $ubuntuInstalled) {
    Write-Host "Ubuntu is not installed in WSL. Please install Ubuntu first." -ForegroundColor Red
    exit 1
}

# Add current user to docker group in WSL with proper error handling
Write-Host "Adding user to docker group..." -ForegroundColor Yellow

# Create a secure script to run in WSL
$dockerPermissionScript = @'
#!/bin/bash
set -e

# Function to log messages
log_message() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1"
}

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    log_message "Docker not found. Installing Docker..."

    # Install prerequisites
    export DEBIAN_FRONTEND=noninteractive
    apt-get update && apt-get -y install --no-install-recommends apt-transport-https ca-certificates curl gnupg2

    # Verify Docker's GPG key
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

    # Add Docker repository
    echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" > /etc/apt/sources.list.d/docker.list

    # Install Docker
    apt-get update && apt-get -y install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

    log_message "Docker installed successfully"
fi

# Create docker group if it doesn't exist
if ! getent group docker > /dev/null; then
    log_message "Creating docker group"
    groupadd docker
fi

# Add specified user to docker group
USERNAME="$1"
if [ -z "$USERNAME" ]; then
    log_message "Error: No username provided"
    exit 1
fi

# Validate that the user exists
if ! id "$USERNAME" &> /dev/null; then
    log_message "Warning: User $USERNAME does not exist in WSL"
    log_message "Creating user $USERNAME"
    useradd -m "$USERNAME"
fi

log_message "Adding user $USERNAME to docker group"
usermod -aG docker "$USERNAME"

# Add devcontainers user to docker group if it exists
if id "devcontainers" &> /dev/null; then
    log_message "Adding devcontainers user to docker group"
    usermod -aG docker devcontainers
fi

# Start docker service if not running
if ! service docker status > /dev/null 2>&1; then
    log_message "Starting Docker service"
    service docker start
fi

log_message "Docker permissions updated successfully"
'@

# Save the script to a temporary file
$tempScriptPath = [System.IO.Path]::GetTempFileName() + ".sh"
$dockerPermissionScript | Out-File -FilePath $tempScriptPath -Encoding ASCII

try {
    # Copy the script to WSL and execute it
    $wslTempPath = "/tmp/fix_docker_permissions.sh"
    wsl -d Ubuntu -u root cp "`$(wslpath -u '$tempScriptPath')" $wslTempPath
    wsl -d Ubuntu -u root chmod +x $wslTempPath
    wsl -d Ubuntu -u root $wslTempPath "$currentUser"

    # Check if the script executed successfully
    if ($LASTEXITCODE -ne 0) {
        Write-Host "Failed to update Docker permissions in WSL. Exit code: $LASTEXITCODE" -ForegroundColor Red
        exit 1
    }
}
catch {
    Write-Host "Error updating Docker permissions: $_" -ForegroundColor Red
    exit 1
}
finally {
    # Clean up the temporary file
    if (Test-Path $tempScriptPath) {
        Remove-Item $tempScriptPath -Force
    }

    # Clean up the WSL temporary file
    wsl -d Ubuntu -u root rm -f $wslTempPath 2>/dev/null
}

# Restart WSL to apply changes
Write-Host "Restarting WSL to apply changes..." -ForegroundColor Yellow
wsl --shutdown
Start-Sleep -Seconds 2

Write-Host "Docker permissions fixed!" -ForegroundColor Green
Write-Host "Please restart VS Code and try running Docker commands again." -ForegroundColor Green
Write-Host "Note: Adding a user to the docker group grants them root-equivalent permissions for Docker containers." -ForegroundColor Yellow
Write-Host "      This is necessary for development but has security implications." -ForegroundColor Yellow
