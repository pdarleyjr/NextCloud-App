#!/bin/bash
set -e

echo "🧹 Cleaning up NextCloud-App repository..."

# Files to remove (redundant or fixed versions that have been integrated)
FILES_TO_REMOVE=(
  ".gitignore-fixed"
  "DOCKER_PERMISSIONS_README-fixed.md"
  "DOCKER_PERMISSIONS_README.md"
  "README-fixed.md"
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
  "SECURITY_FIXES_SUMMARY.md"
  "cleanup-repo.sh"
)

# Remove files
for file in "${FILES_TO_REMOVE[@]}"; do
  if [ -f "$file" ]; then
    echo "Removing $file"
    rm "$file"
  fi
done

# Ensure secrets directory exists with proper structure
if [ ! -d "secrets" ]; then
  echo "📁 Creating secrets directory..."
  mkdir -p secrets
  
  # Create default secret files
  echo -n "nextcloud" > secrets/mysql_root_password.txt
  echo -n "nextcloud" > secrets/mysql_password.txt
  echo -n "nextcloud" > secrets/redis_password.txt
  echo -n "admin" > secrets/nextcloud_admin_user.txt
  echo -n "admin" > secrets/nextcloud_admin_password.txt
  
  # Add .gitkeep file to ensure the directory is committed
  touch secrets/.gitkeep
  
  # Set proper permissions
  chmod 700 secrets
  chmod 600 secrets/*.txt
  
  echo "✅ Created secrets directory with default values"
fi

# Update .gitignore to exclude secret files
if ! grep -q "/secrets/*.txt" .gitignore 2>/dev/null; then
  echo "
# Secrets directory
/secrets/*.txt" >> .gitignore
  echo "✅ Updated .gitignore to exclude secret files"
fi

echo "✅ Repository cleanup completed!"
echo "📋 Next steps:"
echo "1. Review the changes"
echo "2. Run 'docker-compose up -d' to start the environment"
echo "3. Access Nextcloud at http://localhost:8080"
