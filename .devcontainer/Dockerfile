FROM mcr.microsoft.com/vscode/devcontainers/php:7.4

# Install Node.js
RUN curl -sL https://deb.nodesource.com/setup_14.x | bash - \
    && apt-get install -y nodejs

# Install Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Install additional dependencies
RUN apt-get update && apt-get install -y \
    git \
    unzip \
    && apt-get clean

# Set up Nextcloud development environment
WORKDIR /workspace