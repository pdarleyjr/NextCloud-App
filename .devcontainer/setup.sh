#!/bin/bash
set -e

echo "🚀 Setting up Nextcloud app development environment in Codespaces..."

# Create necessary directories
echo "📁 Creating workspace directories..."
mkdir -p /workspace/apps
mkdir -p /workspace/custom_apps
mkdir -p /workspace/Documents

# Create symlinks for app development
echo "🔗 Creating symlinks for app development..."
if [ -d /workspace/Repos ]; then
    ln -sf /workspace/Repos /var/www/html/custom_apps
    echo "✅ Linked /workspace/Repos to /var/www/html/custom_apps"

    # Create symlink for the Appointments app with the correct name
    if [ -d /workspace/Repos/Appointments-master ]; then
        ln -sf /var/www/html/custom_apps/Appointments-master /var/www/html/custom_apps/appointments
        echo "✅ Created symlink from Appointments-master to appointments"
    fi
else
    ln -sf /workspace/custom_apps /var/www/html/custom_apps
    echo "✅ Linked /workspace/custom_apps to /var/www/html/custom_apps"
fi

# Set correct permissions
echo "🔒 Setting correct permissions..."
chown -R www-data:www-data /var/www/html

# Install additional PHP extensions and development tools
echo "📦 Installing additional PHP extensions and development tools..."
apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y \
    php-xdebug \
    php-imagick \
    php-redis \
    php-zip \
    php-xml \
    php-mbstring \
    php-gd \
    php-curl \
    php-intl \
    php-bcmath \
    unzip \
    curl \
    git \
    nodejs \
    npm \
    sqlite3 \
    vim \
    wget

# Configure Xdebug
echo "🐞 Configuring Xdebug for debugging..."
cat > /usr/local/etc/php/conf.d/xdebug.ini << EOF
zend_extension=xdebug.so
xdebug.mode = debug,develop,coverage
xdebug.start_with_request = yes
xdebug.client_host = host.docker.internal
xdebug.client_port = 9003
xdebug.log = /tmp/xdebug.log
xdebug.idekey = VSCODE
EOF

# Install Composer globally
echo "🎵 Installing Composer..."
curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Install Nextcloud CLI tools
echo "🔧 Installing Nextcloud CLI tools..."
curl -sL https://raw.githubusercontent.com/nextcloud/occ/master/occ -o /usr/local/bin/occ
chmod +x /usr/local/bin/occ

# Install Node.js tools
echo "📦 Installing Node.js tools..."
npm install -g npm@latest
npm install -g yarn

# Create a welcome message
cat > /workspace/WELCOME.md << EOF
# Welcome to your Nextcloud App Development Environment!

Your development environment is now ready.

## Accessing Nextcloud
Your development environment is now ready. Here are some useful commands:
- Access Nextcloud: Open port 8080 in your browser
- Run OCC commands: \`occ [command]\`
- Debug with Xdebug: Port 9003 is configured for debugging

## Directory Structure
- \`/workspace/Repos\`: Contains your Nextcloud apps (mounted as custom_apps in Nextcloud)
- \`/workspace/Documents\`: Additional files and documentation

## Important Note for GitHub Codespaces
When using GitHub Codespaces, only files committed to your repository will be available. If you need additional files in your Codespaces environment, make sure to commit them to your repository before creating a codespace.

Happy coding!
EOF

# Create a README in the Documents directory if it doesn't exist
if [ ! -f /workspace/Documents/README.md ]; then
    echo "📝 Creating README in Documents directory..."
    echo "# Documents Directory\n\nThis directory is mounted from your local machine's Documents folder when running locally.\nIn GitHub Codespaces, this directory is created but initially empty." > /workspace/Documents/README.md
    chown -R www-data:www-data /workspace/Documents
fi

echo "✅ Setup complete! Your Nextcloud app development environment is ready."
echo "📝 See /workspace/WELCOME.md for more information."
