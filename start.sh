#!/bin/bash

set -e

# Nextcloud App Development Environment Startup Script
echo "Starting Nextcloud App Development Environment..."

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo "Error: Docker is not installed. Please install Docker and Docker Compose first."
    exit 1
fi

# Check if Docker Compose is installed
if ! command -v docker-compose &> /dev/null && ! docker compose version &> /dev/null; then
    echo "Error: Docker Compose is not installed. Please install Docker Compose first."
    exit 1
fi

# Check if secrets directory exists, if not create it
if [ ! -d "./secrets" ]; then
    echo "Creating secrets directory..."
    mkdir -p ./secrets
    
    # Generate random passwords for services
    echo "Generating random passwords for services..."
    openssl rand -base64 32 | tr -d '\n' > ./secrets/mysql_root_password.txt
    openssl rand -base64 32 | tr -d '\n' > ./secrets/mysql_password.txt
    openssl rand -base64 32 | tr -d '\n' > ./secrets/redis_password.txt
    
    # Set default admin credentials
    echo "admin" > ./secrets/nextcloud_admin_user.txt
    openssl rand -base64 16 | tr -d '\n' > ./secrets/nextcloud_admin_password.txt
    echo "Default admin username: admin"
    echo "Default admin password: $(cat ./secrets/nextcloud_admin_password.txt)"
    echo "These credentials are stored in the secrets directory."
fi

# Start the containers
echo "Starting Docker containers..."
if docker compose version &> /dev/null; then
    # Using Docker Compose V2
    docker compose up -d
else
    # Using Docker Compose V1
    docker-compose up -d
fi

# Wait for Nextcloud to be ready
echo "Waiting for Nextcloud to be ready..."
sleep 10

# Display access information
echo ""
echo "Nextcloud is now running!"
echo "Access your Nextcloud instance at: http://localhost:8080"
echo "Admin username: $(cat ./secrets/nextcloud_admin_user.txt)"
echo "Admin password: $(cat ./secrets/nextcloud_admin_password.txt)"
echo ""
echo "To stop the environment, run: ./stop.sh"
