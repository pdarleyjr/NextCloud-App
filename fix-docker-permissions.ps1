# PowerShell script to fix Docker permissions in WSL

Write-Host "Fixing Docker permissions in WSL..." -ForegroundColor Green

# Get current Windows username
$currentUser = $env:USERNAME

# Add current user to docker group in WSL
Write-Host "Adding user to docker group..." -ForegroundColor Yellow
wsl -d Ubuntu -u root bash -c "
    # Ensure docker is installed
    if ! command -v docker &> /dev/null; then
        echo 'Docker not found. Installing Docker...'
        export DEBIAN_FRONTEND=noninteractive
        apt update && apt -y install --no-install-recommends apt-transport-https ca-certificates curl gnupg2
        curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
        echo 'deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \$(lsb_release -cs) stable' > /etc/apt/sources.list.d/docker.list
        apt update && apt -y install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
    fi

    # Create docker group if it doesn't exist
    getent group docker || groupadd docker

    # Add current user to docker group
    usermod -aG docker $currentUser
    usermod -aG docker devcontainers

    # Start docker service if not running
    if ! service docker status > /dev/null; then
        service docker start
    fi

    echo 'Docker permissions updated!'
"

# Restart WSL to apply changes
Write-Host "Restarting WSL to apply changes..." -ForegroundColor Yellow
wsl --shutdown
Start-Sleep -Seconds 2

Write-Host "Docker permissions fixed!" -ForegroundColor Green
Write-Host "Please restart VS Code and try running Docker commands again." -ForegroundColor Green
