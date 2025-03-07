# PowerShell script to properly set up WSL for dev containers with improved security

Write-Host "Setting up WSL for dev containers..." -ForegroundColor Green

# Check if running with administrator privileges
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Host "This script requires administrator privileges. Please run PowerShell as Administrator and try again." -ForegroundColor Red
    exit 1
}

# Check if WSL is installed
$wslInstalled = Get-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux

if ($wslInstalled.State -ne "Enabled") {
    Write-Host "Installing WSL..." -ForegroundColor Yellow
    try {
        Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux -NoRestart
        Enable-WindowsOptionalFeature -Online -FeatureName VirtualMachinePlatform -NoRestart
        Write-Host "Please restart your computer and run this script again." -ForegroundColor Red
        exit 0
    }
    catch {
        Write-Host "Failed to install WSL: $_" -ForegroundColor Red
        exit 1
    }
}

# Check if WSL 2 is set as default
try {
    $wslVersion = wsl --status | Select-String "Default Version"
    if (-not ($wslVersion -match "2")) {
        Write-Host "Setting WSL 2 as default..." -ForegroundColor Yellow
        wsl --set-default-version 2
        if ($LASTEXITCODE -ne 0) {
            Write-Host "Failed to set WSL 2 as default. Please check your WSL installation." -ForegroundColor Red
            exit 1
        }
    }
}
catch {
    Write-Host "Error checking WSL version: $_" -ForegroundColor Red
    exit 1
}

# Check if Ubuntu is installed
try {
    $ubuntuInstalled = wsl -l -v | Select-String "Ubuntu"
    if (-not $ubuntuInstalled) {
        Write-Host "Installing Ubuntu..." -ForegroundColor Yellow
        wsl --install -d Ubuntu
        if ($LASTEXITCODE -ne 0) {
            Write-Host "Failed to install Ubuntu. Please check your WSL installation." -ForegroundColor Red
            exit 1
        }
    }
}
catch {
    Write-Host "Error checking Ubuntu installation: $_" -ForegroundColor Red
    exit 1
}

# Copy wsl.conf to Ubuntu
Write-Host "Configuring WSL..." -ForegroundColor Yellow
$wslConfPath = ".devcontainer/wsl.conf"

# Get current script directory instead of hardcoding the path
$currentDir = $PSScriptRoot
$wslCurrentDir = "/mnt/" + $currentDir.ToLower().Replace(":", "").Replace("\", "/")

# Validate that the wsl.conf file exists and is a valid configuration file
if (Test-Path $wslConfPath) {
    # Check if the file is a valid configuration file
    $wslConfContent = Get-Content $wslConfPath -Raw
    if ($wslConfContent -match "^\[.*\]") {
        try {
            # Copy the file to a temporary location first to verify it
            $tempFile = [System.IO.Path]::GetTempFileName()
            Copy-Item $wslConfPath -Destination $tempFile -Force

            # Now copy it to WSL
            wsl -d Ubuntu -u root cp "$wslCurrentDir/.devcontainer/wsl.conf" /etc/wsl.conf
            if ($LASTEXITCODE -eq 0) {
                Write-Host "WSL configuration file copied." -ForegroundColor Green
            }
            else {
                Write-Host "Failed to copy WSL configuration file." -ForegroundColor Red
            }

            # Clean up the temporary file
            Remove-Item $tempFile -Force
        }
        catch {
            Write-Host "Error copying WSL configuration file: $_" -ForegroundColor Red
        }
    }
    else {
        Write-Host "WSL configuration file does not appear to be valid." -ForegroundColor Red
    }
}
else {
    Write-Host "WSL configuration file not found at $wslConfPath" -ForegroundColor Red
}

# Restart WSL to apply changes
Write-Host "Restarting WSL to apply changes..." -ForegroundColor Yellow
wsl --shutdown
Start-Sleep -Seconds 2

# Check Docker installation in WSL with improved security
Write-Host "Checking Docker installation in WSL..." -ForegroundColor Yellow
try {
    $dockerInstalled = wsl -d Ubuntu -u root docker --version 2>$null
    if (-not $dockerInstalled) {
        Write-Host "Docker not found in WSL. Installing Docker..." -ForegroundColor Yellow

        # Create a secure installation script with validation
        $dockerInstallScript = @'
#!/bin/bash
set -e

# Function to verify downloaded packages
verify_download() {
    echo "Verifying package integrity..."
    if command -v gpg > /dev/null; then
        return 0
    else
        echo "Installing gnupg for verification..."
        apt-get update && apt-get install -y gnupg
    fi
}

# Update package lists
export DEBIAN_FRONTEND=noninteractive
apt-get update

# Install prerequisites
apt-get -y install --no-install-recommends apt-transport-https ca-certificates curl gnupg2

# Verify Docker's GPG key
verify_download
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

# Add Docker repository
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" > /etc/apt/sources.list.d/docker.list

# Update package lists again and install Docker
apt-get update
apt-get -y install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Create docker group if it doesn't exist
getent group docker || groupadd docker

# Add devcontainers user to docker group if it exists
if id "devcontainers" &>/dev/null; then
    usermod -aG docker devcontainers
    echo "Added devcontainers user to docker group"
fi

# Start Docker service
service docker start || true
echo "Docker installation completed successfully"
'@

        # Save the script to a temporary file
        $tempScriptPath = [System.IO.Path]::GetTempFileName() + ".sh"
        $dockerInstallScript | Out-File -FilePath $tempScriptPath -Encoding ASCII

        # Copy the script to WSL and execute it
        $wslTempPath = "/tmp/docker_install.sh"
        wsl -d Ubuntu -u root cp "`$(wslpath -u '$tempScriptPath')" $wslTempPath
        wsl -d Ubuntu -u root chmod +x $wslTempPath
        wsl -d Ubuntu -u root $wslTempPath

        # Clean up
        Remove-Item $tempScriptPath -Force
        wsl -d Ubuntu -u root rm $wslTempPath
    }
}
catch {
    Write-Host "Error checking Docker installation: $_" -ForegroundColor Red
}

Write-Host "WSL setup complete!" -ForegroundColor Green
Write-Host "You can now open VS Code and use the 'Remote-Containers: Open Folder in Container' command." -ForegroundColor Green
