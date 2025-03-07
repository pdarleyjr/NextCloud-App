# Docker Permissions Fix for WSL

This guide addresses the "Current user does not have permission to run 'docker'" error in Visual Studio Code when using Docker with WSL (Windows Subsystem for Linux).

## The Problem

This error occurs when your user account in WSL doesn't have the necessary permissions to interact with the Docker daemon. In Linux systems, Docker requires users to be members of the 'docker' group to run Docker commands without sudo.

## Solution Options

### Option 1: Using PowerShell Script (Recommended for Windows Users)

1. Open PowerShell as Administrator
2. Navigate to your project directory
3. Run the PowerShell script:
   ```
   .\fix-docker-permissions.ps1
   ```
4. Restart VS Code

This script will:

- Ensure Docker is installed in your WSL distribution
- Add your Windows user to the docker group in WSL
- Add the 'devcontainers' user to the docker group (if it exists)
- Restart WSL to apply the changes

### Option 2: Using Bash Script (For Direct WSL Access)

1. Open your WSL terminal
2. Navigate to your project directory
3. Make the script executable:
   ```
   chmod +x fix-docker-permissions.sh
   ```
4. Run the script with sudo:
   ```
   sudo ./fix-docker-permissions.sh
   ```
5. Either log out and log back in, or run:
   ```
   newgrp docker
   ```
6. Restart VS Code

## Manual Fix

If the scripts don't work, you can manually fix the issue:

1. Open your WSL terminal
2. Run these commands:

   ```bash
   # Install Docker if not already installed
   sudo apt update
   sudo apt install -y docker.io

   # Add your user to the docker group
   sudo usermod -aG docker $USER

   # Start Docker service
   sudo service docker start

   # Apply group changes without logging out
   newgrp docker
   ```

3. Restart VS Code

## Verifying the Fix

After applying the fix, you can verify it worked by running:

```bash
docker --version
```

If it shows the Docker version without permission errors, the fix was successful.
