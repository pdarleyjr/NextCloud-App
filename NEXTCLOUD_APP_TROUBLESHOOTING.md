# Nextcloud App Troubleshooting Guide

## Issue: Custom Appointment Scheduling App Not Appearing in Nextcloud

This document explains why the custom appointment scheduling app (based on the Nextcloud Appointments app) is not appearing in the Nextcloud server running in the Docker container, and provides solutions to fix the issue.

## Root Causes

1. **Directory Name Mismatch**

   - The app is located in `Repos/Appointments-master` (with capital "A" and "-master" suffix)
   - Nextcloud expects the app ID to match the directory name exactly ("appointments" lowercase)
   - The app ID is defined in `appinfo/info.xml` as "appointments" (lowercase)

2. **Symlink Configuration**

   - The setup.sh script creates a symlink from `/workspace/Repos` to `/var/www/html/custom_apps`
   - This makes the app available as "custom_apps/Appointments-master" instead of "apps/appointments"
   - Nextcloud can't find the app because it's looking for it in the wrong location

3. **Nextcloud Version Compatibility**
   - The app requires Nextcloud versions 29-31 (as specified in info.xml)
   - The GitHub repo's docker-compose.yml uses `nextcloud:latest` which might not be compatible
   - The local docker-compose.yml correctly uses `nextcloud:29`

## Solutions

### 1. Fix App Symlink

We've created scripts to fix the symlink issue:

- `fix-app-symlink.sh` (for Linux/macOS)
- `fix-app-symlink.ps1` (for Windows)

These scripts create a symlink from `Appointments-master` to `appointments` in the custom_apps directory, allowing Nextcloud to find the app with the correct name.

### 2. Update Setup Script

We've created an improved setup script (`setup.sh`) that automatically creates the necessary symlink during container setup. This script:

1. Creates the standard symlink from `/workspace/Repos` to `/var/www/html/custom_apps`
2. Creates an additional symlink from `Appointments-master` to `appointments`
3. Sets the correct permissions

### 3. Fix Docker Compose Configuration

We've updated the docker-compose.yml file to use `nextcloud:29` instead of `nextcloud:latest` to ensure compatibility with the app.

## How to Apply the Fixes

### Option 1: Run the Fix Script

1. Start your Docker containers:

   ```bash
   docker-compose up -d
   ```

2. Run the fix script:

   - Linux/macOS: `bash fix-app-symlink.sh`
   - Windows: `.\fix-app-symlink.ps1`

3. Refresh your Nextcloud instance and check if the app appears

### Option 2: Use the Updated Setup Script

1. The `.devcontainer/setup.sh` script has been updated to create the necessary symlinks

2. Rebuild your container:
   ```bash
   docker-compose down
   docker-compose up -d
   ```

## Verifying the Fix

After applying the fixes, you should be able to:

1. See the "Appointments" app in the Nextcloud app list
2. Enable the app if it's not already enabled
3. Access the app from the top navigation bar

If the app still doesn't appear, check the Nextcloud logs:

```bash
docker-compose logs nextcloud
```

## Preventing Future Issues

To prevent similar issues in the future:

1. Always ensure app directory names match the app ID in info.xml
2. Use specific Nextcloud versions instead of "latest"
3. Include proper symlink creation in your setup scripts
4. Test app visibility after container setup
