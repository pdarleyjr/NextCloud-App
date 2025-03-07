#!/bin/bash
# Script to fix Docker permissions in WSL securely

# Enable error handling
set -e

# Function to log messages with timestamps
log_message() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1"
}

log_message "Fixing Docker permissions in WSL..."

# Check if running as root
if [ "$EUID" -ne 0 ]; then
  log_message "Please run this script as root (sudo ./fix-docker-permissions.sh)"
  exit 1
fi

# Ensure docker is installed with proper verification
if ! command -v docker &> /dev/null; then
    log_message "Docker not found. Installing Docker..."

    # Create a temporary directory for downloads with secure permissions
    TEMP_DIR=$(mktemp -d)
    chmod 700 "$TEMP_DIR"
    cd "$TEMP_DIR"

    # Install prerequisites
    export DEBIAN_FRONTEND=noninteractive
    apt-get update && apt-get -y install --no-install-recommends apt-transport-https ca-certificates curl gnupg2

    # Download and verify Docker's GPG key
    log_message "Downloading and verifying Docker's GPG key..."
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o docker.gpg
    gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg docker.gpg

    # Add Docker repository with secure configuration
    echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" > /etc/apt/sources.list.d/docker.list

    # Install Docker
    apt-get update && apt-get -y install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

    # Clean up
    cd - > /dev/null
    rm -rf "$TEMP_DIR"

    log_message "Docker installed successfully"
fi

# Create docker group if it doesn't exist
if ! getent group docker > /dev/null; then
    log_message "Creating docker group"
    groupadd docker
fi

# Get current username with validation
CURRENT_USER=$(logname 2>/dev/null || echo "$SUDO_USER")
if [ -z "$CURRENT_USER" ]; then
    log_message "Could not determine current user. Please specify username:"
    read -r CURRENT_USER

    if [ -z "$CURRENT_USER" ]; then
        log_message "No username provided. Exiting."
        exit 1
    fi
fi

# Validate that the user exists
if ! id "$CURRENT_USER" &> /dev/null; then
    log_message "Warning: User $CURRENT_USER does not exist"
    log_message "Would you like to create this user? (y/n)"
    read -r CREATE_USER

    if [ "$CREATE_USER" = "y" ]; then
        log_message "Creating user $CURRENT_USER"
        useradd -m "$CURRENT_USER"
    else
        log_message "User creation skipped. Exiting."
        exit 1
    fi
fi

# Add current user to docker group
log_message "Adding user $CURRENT_USER to docker group..."
usermod -aG docker "$CURRENT_USER"

# Also add devcontainers user if it exists
if id "devcontainers" &>/dev/null; then
    log_message "Adding devcontainers user to docker group..."
    usermod -aG docker devcontainers
fi

# Start docker service if not running
if ! service docker status > /dev/null 2>&1; then
    log_message "Starting Docker service..."
    service docker start

    # Verify Docker service started successfully
    if ! service docker status > /dev/null 2>&1; then
        log_message "Failed to start Docker service. Please check Docker installation."
        exit 1
    fi
fi

log_message "Docker permissions updated!"
log_message "Please log out and log back in for the changes to take effect."
log_message "Alternatively, run: newgrp docker"
log_message ""
log_message "SECURITY NOTE: Adding a user to the docker group grants them root-equivalent"
log_message "permissions for Docker containers. This is necessary for development but has"
log_message "security implications. Use with caution in production environments."
