#!/bin/bash

set -e

# Nextcloud App Development Environment Stop Script
echo "Stopping Nextcloud App Development Environment..."

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo "Error: Docker is not installed. Please install Docker and Docker Compose first."
    exit 1
fi

# Stop the containers
echo "Stopping Docker containers..."
if docker compose version &> /dev/null; then
    # Using Docker Compose V2
    docker compose down
else
    # Using Docker Compose V1
    docker-compose down
fi

echo ""
echo "Nextcloud environment has been stopped."
echo "To start the environment again, run: ./start.sh"
