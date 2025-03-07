#!/bin/bash
set -e

echo "🧹 Cleaning up repository..."

# List of files to remove
FILES_TO_REMOVE=(
  ".gitignore-fixed"
  "DOCKER_PERMISSIONS_README-fixed.md"
  "DOCKER_PERMISSIONS_README.md"
  "README-fixed.md"
  "SECURITY_FIXES_SUMMARY.md"
  "docker-compose-fixed.yml"
  "fix-docker-permissions-fixed.ps1"
  "fix-docker-permissions-fixed.sh"
  "fix-docker-permissions.ps1"
  "fix-docker-permissions.sh"
  "fix-insecure-random.ps1"
  "push-to-github-fixed.sh"
  "push-to-github.ps1"
  "push-to-github.sh"
  "setup-wsl-fixed.ps1"
  "setup-wsl.ps1"
  "start-nextcloud-fixed.ps1"
  "start-nextcloud.ps1"
  "test-docker-environment-fixed.ps1"
  "test-docker-environment.ps1"
  ".devcontainer/setup-fixed.sh"
)

# Remove files
for file in "${FILES_TO_REMOVE[@]}"; do
  if [ -f "$file" ]; then
    echo "Removing $file"
    git rm "$file"
  fi
done

# Create secrets directory if it doesn't exist
if [ ! -d "secrets" ]; then
  echo "📁 Creating secrets directory..."
  mkdir -p secrets
  
  # Create default secret files
  echo "nextcloud" > secrets/mysql_root_password.txt
  echo "nextcloud" > secrets/mysql_password.txt
  echo "nextcloud" > secrets/redis_password.txt
  echo "admin" > secrets/nextcloud_admin_user.txt
  echo "admin" > secrets/nextcloud_admin_password.txt
  
  # Add .gitkeep file to ensure the directory is committed
  touch secrets/.gitkeep
  
  # Add to .gitignore
  if ! grep -q "/secrets/*.txt" .gitignore; then
    echo "/secrets/*.txt" >> .gitignore
  fi
  
  echo "✅ Created secrets directory with default values"
  echo "⚠️  WARNING: For production use, please change these default values!"
fi

# Commit changes
echo "💾 Committing changes..."
git add .
git commit -m "Clean up repository and standardize configuration"

echo "✅ Repository cleanup complete!"
