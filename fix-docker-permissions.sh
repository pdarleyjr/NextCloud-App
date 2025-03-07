#!/bin/bash
# Script to fix Docker permissions in WSL

echo "Fixing Docker permissions in WSL..."

# Check if running as root
if [ "$EUID" -ne 0 ]; then
  echo "Please run this script as root (sudo ./fix-docker-permissions.sh)"
  exit 1
fi

# Ensure docker is installed
if ! command -v docker &> /dev/null; then
    echo "Docker not found. Installing Docker..."
    export DEBIAN_FRONTEND=noninteractive
    apt update && apt -y install --no-install-recommends apt-transport-https ca-certificates curl gnupg2
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
    echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" > /etc/apt/sources.list.d/docker.list
    apt update && apt -y install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
fi

# Create docker group if it doesn't exist
getent group docker || groupadd docker

# Get current username
CURRENT_USER=$(logname || echo $SUDO_USER)
if [ -z "$CURRENT_USER" ]; then
    echo "Could not determine current user. Please specify username:"
    read CURRENT_USER
fi

# Add current user to docker group
echo "Adding user $CURRENT_USER to docker group..."
usermod -aG docker $CURRENT_USER

# Also add devcontainers user if it exists
if id "devcontainers" &>/dev/null; then
    echo "Adding devcontainers user to docker group..."
    usermod -aG docker devcontainers
fi

# Start docker service if not running
if ! service docker status > /dev/null; then
    echo "Starting Docker service..."
    service docker start
fi

echo "Docker permissions updated!"
echo "Please log out and log back in for the changes to take effect."
echo "Alternatively, run: newgrp docker"
