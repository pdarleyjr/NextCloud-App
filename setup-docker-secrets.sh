#!/bin/bash
set -e

echo "🔐 Setting up Docker secrets for Nextcloud..."

# Create secrets directory if it doesn't exist
if [ ! -d "./secrets" ]; then
    mkdir -p "./secrets"
    echo "Created secrets directory"
fi

# Function to generate a random password
generate_random_password() {
    local length=${1:-16}
    local charset="A-Za-z0-9!@#$%^&*()-_=+"
    tr -dc "$charset" < /dev/urandom | head -c "$length"
}

# Function to create a secret file
create_secret_file() {
    local name=$1
    local default_value=$2
    local generate_random=${3:-false}
    local random_length=${4:-16}
    
    local file_path="./secrets/${name}.txt"
    
    if [ -f "$file_path" ]; then
        echo "Secret file $name already exists"
        return
    fi
    
    local value
    if [ "$generate_random" = true ]; then
        value=$(generate_random_password "$random_length")
    else
        read -p "Enter value for $name (leave empty for default: $default_value): " user_input
        value=${user_input:-$default_value}
    fi
    
    echo -n "$value" > "$file_path"
    echo "Created secret file for $name"
}

# Create secret files
echo "Setting up Docker secrets for Nextcloud..."

# Database secrets
create_secret_file "mysql_root_password" "nextcloud" true 16
create_secret_file "mysql_password" "nextcloud" true 16

# Redis secret
create_secret_file "redis_password" "nextcloud" true 16

# Nextcloud admin credentials
create_secret_file "nextcloud_admin_user" "admin" false
create_secret_file "nextcloud_admin_password" "admin" true 12

# Set proper permissions on secrets directory
echo "Setting proper permissions on secrets directory..."
chmod 700 "./secrets"
chmod 600 ./secrets/*.txt

# Add .gitignore entry for secrets directory if not already present
if ! grep -q "/secrets/*.txt" .gitignore 2>/dev/null; then
    echo "
# Secrets directory
/secrets/*.txt" >> .gitignore
    echo "Added secrets directory to .gitignore"
fi

echo -e "\n✅ Docker secrets setup complete!"
echo -e "⚠️  IMPORTANT: Never commit the secrets directory contents to version control!\n"
echo "You can now start your Nextcloud environment with: docker-compose up -d"
