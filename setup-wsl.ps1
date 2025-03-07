# PowerShell script to properly set up WSL for dev containers

Write-Host "Setting up WSL for dev containers..." -ForegroundColor Green

# Check if WSL is installed
$wslInstalled = Get-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux

if ($wslInstalled.State -ne "Enabled") {
    Write-Host "Installing WSL..." -ForegroundColor Yellow
    Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux -NoRestart
    Enable-WindowsOptionalFeature -Online -FeatureName VirtualMachinePlatform -NoRestart
    Write-Host "Please restart your computer and run this script again." -ForegroundColor Red
    exit
}

# Check if WSL 2 is set as default
$wslVersion = wsl --status | Select-String "Default Version"
if (-not ($wslVersion -match "2")) {
    Write-Host "Setting WSL 2 as default..." -ForegroundColor Yellow
    wsl --set-default-version 2
}

# Check if Ubuntu is installed
$ubuntuInstalled = wsl -l -v | Select-String "Ubuntu"
if (-not $ubuntuInstalled) {
    Write-Host "Installing Ubuntu..." -ForegroundColor Yellow
    wsl --install -d Ubuntu
}

# Copy wsl.conf to Ubuntu
Write-Host "Configuring WSL..." -ForegroundColor Yellow
$wslConfPath = ".devcontainer/wsl.conf"

# Get current script directory instead of hardcoding the path
$currentDir = $PSScriptRoot
$wslCurrentDir = "/mnt/" + $currentDir.ToLower().Replace(":", "").Replace("\", "/")

if (Test-Path $wslConfPath) {
    wsl -d Ubuntu -u root cp "$wslCurrentDir/.devcontainer/wsl.conf" /etc/wsl.conf
    Write-Host "WSL configuration file copied." -ForegroundColor Green
} else {
    Write-Host "WSL configuration file not found at $wslConfPath" -ForegroundColor Red
}

# Restart WSL to apply changes
Write-Host "Restarting WSL to apply changes..." -ForegroundColor Yellow
wsl --shutdown
Start-Sleep -Seconds 2

# Check Docker installation in WSL
Write-Host "Checking Docker installation in WSL..." -ForegroundColor Yellow
$dockerInstalled = wsl -d Ubuntu -u root docker --version 2>$null
if (-not $dockerInstalled) {
    Write-Host "Docker not found in WSL. Installing Docker..." -ForegroundColor Yellow
    wsl -d Ubuntu -u root -e bash -c "
        export DEBIAN_FRONTEND=noninteractive
        apt update && apt -y install --no-install-recommends apt-transport-https ca-certificates curl gnupg2
        curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
        echo 'deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable' > /etc/apt/sources.list.d/docker.list
        apt update && apt -y install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
        usermod -aG docker devcontainers
    "
}

Write-Host "WSL setup complete!" -ForegroundColor Green
Write-Host "You can now open VS Code and use the 'Remote-Containers: Open Folder in Container' command." -ForegroundColor Green
