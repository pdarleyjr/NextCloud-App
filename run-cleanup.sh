#!/bin/bash
set -e

echo "🚀 Starting Nextcloud App Development Environment cleanup..."

# Check if Git is installed
if ! command -v git &> /dev/null; then
    echo "❌ Git is not installed. Please install Git and try again."
    exit 1
fi

# Check if we're in a Git repository
if ! git rev-parse --is-inside-work-tree &> /dev/null; then
    echo "❌ Not in a Git repository. Please run this script from the root of the repository."
    exit 1
fi

# Check if there are uncommitted changes
if ! git diff-index --quiet HEAD --; then
    echo "⚠️ You have uncommitted changes. It's recommended to commit or stash them before running this script."
    read -p "Do you want to continue anyway? (y/N): " confirm
    if [[ "$confirm" != [yY] ]]; then
        echo "Operation cancelled."
        exit 0
    fi
fi

# Create secrets directory if it doesn't exist
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
    echo "⚠️  WARNING: For production use, please change these default values!"
fi

# Update .gitignore to exclude secret files
if ! grep -q "/secrets/*.txt" .gitignore 2>/dev/null; then
    echo "
# Secrets directory
/secrets/*.txt" >> .gitignore
    echo "✅ Updated .gitignore to exclude secret files"
fi

# Update docker-compose.json to use setup.sh instead of setup-fixed.sh
if grep -q "setup-fixed.sh" .devcontainer/devcontainer.json; then
    echo "🔧 Updating devcontainer.json to use setup.sh..."
    sed -i 's/setup-fixed.sh/setup.sh/g' .devcontainer/devcontainer.json
    echo "✅ Updated devcontainer.json"
fi

# Check if docker-compose.yml is using the fixed version
if ! grep -q "MYSQL_PASSWORD_FILE" docker-compose.yml; then
    echo "🔄 Replacing docker-compose.yml with the secure version..."
    if [ -f "docker-compose-fixed.yml" ]; then
        mv docker-compose-fixed.yml docker-compose.yml
        echo "✅ Updated docker-compose.yml"
    else
        echo "⚠️  docker-compose-fixed.yml not found. Please manually update docker-compose.yml."
    fi
fi

echo "\n✅ Cleanup completed successfully!"
echo "\n📋 Next steps:"
echo "1. Review the changes: git status"
echo "2. Commit the changes: git commit -am 'Clean up repository'"
echo "3. Start the environment: docker-compose up -d"
echo "4. Access Nextcloud at: http://localhost:8080"
echo "\n📚 For more information, see GETTING_STARTED.md"
