# Docker Permissions and Security Best Practices

This guide addresses Docker permission issues in WSL (Windows Subsystem for Linux) and provides security best practices for the Nextcloud development environment.

## Docker Permission Issues

### The Problem

The "Current user does not have permission to run 'docker'" error occurs when your user account in WSL doesn't have the necessary permissions to interact with the Docker daemon. In Linux systems, Docker requires users to be members of the 'docker' group to run Docker commands without sudo.

### Security Implications

**Important Security Note**: Adding a user to the 'docker' group effectively grants them root-equivalent permissions on the host system. This is because Docker containers can mount host directories and access host resources. In development environments, this is often necessary, but it has security implications that should be understood.

## Solution Options

### Option 1: Using PowerShell Script (Recommended for Windows Users)

1. Open PowerShell as Administrator
2. Navigate to your project directory
3. Run the PowerShell script:
   ```
   .\fix-docker-permissions-fixed.ps1
   ```
4. Restart VS Code

This script will:

- Check if it's running with administrator privileges
- Ensure Docker is installed in your WSL distribution
- Add your Windows user to the docker group in WSL
- Add the 'devcontainers' user to the docker group (if it exists)
- Restart WSL to apply the changes
- Include proper error handling and security validations

### Option 2: Using Bash Script (For Direct WSL Access)

1. Open your WSL terminal
2. Navigate to your project directory
3. Make the script executable:
   ```
   chmod +x fix-docker-permissions-fixed.sh
   ```
4. Run the script with sudo:
   ```
   sudo ./fix-docker-permissions-fixed.sh
   ```
5. Either log out and log back in, or run:
   ```
   newgrp docker
   ```
6. Restart VS Code

## Docker Compose Security Improvements

The updated `docker-compose-fixed.yml` file includes several security improvements:

1. **Secret Management**: Sensitive information like passwords are stored in Docker secrets instead of environment variables
2. **Network Isolation**: The Nextcloud container only binds to localhost (127.0.0.1) instead of all interfaces
3. **Read-Only Mounts**: Configuration files are mounted as read-only
4. **Reduced Trusted Domains**: Only necessary domains are included in the trusted domains list

To set up the secure Docker Compose environment:

1. Run the setup script to create necessary secret files:
   ```
   .\setup-docker-secrets.ps1
   ```
2. Start the environment with the secure configuration:
   ```
   docker-compose -f docker-compose-fixed.yml up -d
   ```

## Additional Security Best Practices

### 1. Use Strong Passwords

The `setup-docker-secrets.ps1` script generates strong random passwords for all services. For production environments, ensure all passwords are:

- At least 16 characters long
- Include a mix of uppercase, lowercase, numbers, and special characters
- Unique for each service

### 2. Keep Software Updated

Regularly update all components:

- Docker Engine and Docker Desktop
- WSL and Ubuntu
- Nextcloud and its dependencies
- MariaDB and Redis

### 3. Limit Network Exposure

- Bind services only to localhost when possible
- Use HTTPS for all external connections
- Consider using a reverse proxy with proper TLS configuration for production

### 4. Secure File Permissions

- Ensure sensitive files are only readable by appropriate users
- Use read-only mounts when possible
- Don't commit secrets to version control

### 5. Regular Backups

- Implement regular backups of your Nextcloud data
- Test restoration procedures periodically
- Store backups securely

## Verifying the Fix

After applying the fix, you can verify it worked by running:

```bash
docker --version
```

If it shows the Docker version without permission errors, the fix was successful.
