#!/bin/bash
echo "Setting up Nextcloud environment..."
apt-get update && apt-get install -y \
    apache2 mariadb-server libapache2-mod-php \
    php php-cli php-mysql php-json php-curl php-gd php-mbstring \
    php-intl php-imagick php-xml php-zip unzip curl git \
    && a2enmod rewrite \
    && systemctl enable apache2 mariadb \
    && systemctl start apache2 mariadb