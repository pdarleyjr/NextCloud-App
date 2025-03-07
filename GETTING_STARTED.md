# Getting Started with Nextcloud App Development

This guide will help you set up and start developing Nextcloud apps using this development environment.

## Table of Contents

1. [Setting Up the Environment](#setting-up-the-environment)
2. [Creating Your First App](#creating-your-first-app)
3. [Development Workflow](#development-workflow)
4. [Debugging](#debugging)
5. [Common Issues and Solutions](#common-issues-and-solutions)
6. [Resources](#resources)

## Setting Up the Environment

### Option 1: GitHub Codespaces (Recommended for Quick Start)

1. Click the green "Code" button on your GitHub repository
2. Select the "Codespaces" tab
3. Click "Create codespace on main"
4. Wait for the environment to be created (approximately 5-10 minutes)
5. Access Nextcloud at port 8080 (click on the "Ports" tab)
6. Log in with username `admin` and password `admin` (or the values in your secrets directory)

### Option 2: Local Development with Docker

1. Clone this repository:
   ```bash
   git clone https://github.com/pdarleyjr/NextCloud-App.git
   cd NextCloud-App
   ```

2. Set up Docker secrets:
   - On Windows: `./setup-docker-secrets.ps1`
   - On Linux/macOS: `./setup-docker-secrets.sh`

3. Start the Docker containers:
   ```bash
   docker-compose up -d
   ```

4. Access Nextcloud at http://localhost:8080

5. Log in with the credentials from your secrets directory (default: admin/admin)

## Creating Your First App

### Option 1: Using the Nextcloud App Generator

1. Visit the [Nextcloud App Generator](https://apps.nextcloud.com/developer/apps/generate)
2. Fill in the required information:
   - App name (camel case, e.g., "MyApp")
   - App ID (lowercase, e.g., "myapp")
   - Author name and email
   - License (AGPL is recommended)
   - Description

3. Download the generated app archive

4. Extract the archive to the `Repos` directory in your project

5. Enable the app in Nextcloud:
   - Go to Settings > Apps > Disabled apps
   - Find your app and click "Enable"

### Option 2: Creating an App Manually

1. Create a new directory in the `Repos` directory with your app ID (lowercase):
   ```bash
   mkdir -p Repos/myapp/appinfo
   ```

2. Create the basic app structure:
   ```
   myapp/
   ├── appinfo/
   │   ├── info.xml            # App metadata
   │   └── routes.php          # Route definitions
   ├── lib/                    # PHP classes
   ├── templates/              # Templates
   ├── js/                     # JavaScript files
   ├── css/                    # CSS files
   └── README.md               # Documentation
   ```

3. Create a basic `info.xml` file:
   ```xml
   <?xml version="1.0"?>
   <info xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:noNamespaceSchemaLocation="https://apps.nextcloud.com/schema/apps/info.xsd">
       <id>myapp</id>
       <name>My App</name>
       <summary>A brief summary of my app</summary>
       <description>A longer description of my app</description>
       <version>0.1.0</version>
       <licence>agpl</licence>
       <author>Your Name</author>
       <namespace>MyApp</namespace>
       <category>tools</category>
       <dependencies>
           <nextcloud min-version="29" max-version="31"/>
       </dependencies>
   </info>
   ```

4. Create a basic `routes.php` file:
   ```php
   <?php
   return [
       'routes' => [
           ['name' => 'page#index', 'url' => '/', 'verb' => 'GET'],
       ],
   ];
   ```

5. Enable the app in Nextcloud

## Development Workflow

1. **Edit your app files**:
   - Use VS Code to edit files in the `Repos/myapp` directory
   - Changes are immediately reflected in the container

2. **View your app**:
   - Access Nextcloud at port 8080
   - Navigate to your app (usually via the app menu)

3. **Refresh to see changes**:
   - Most changes don't require a restart
   - PHP changes are reflected immediately
   - JavaScript and CSS may require a hard refresh (Ctrl+F5)

4. **Use OCC commands**:
   ```bash
   docker-compose exec -u www-data nextcloud php occ app:list
   docker-compose exec -u www-data nextcloud php occ app:enable myapp
   ```

## Debugging

### PHP Debugging with Xdebug

1. Set breakpoints in your PHP code in VS Code

2. Start the "Listen for Xdebug" debug configuration in VS Code:
   - Click on the Run and Debug icon in the sidebar
   - Select "Listen for Xdebug" from the dropdown
   - Click the green play button

3. Refresh your Nextcloud page to trigger the debugger

### JavaScript Debugging

1. Open your browser's developer tools (F12 or right-click > Inspect)

2. Navigate to the Sources/Debugger tab

3. Find your app's JavaScript files and set breakpoints

### Checking Logs

1. Nextcloud logs:
   ```bash
   docker-compose exec nextcloud cat /var/www/html/data/nextcloud.log
   ```

2. Container logs:
   ```bash
   docker-compose logs nextcloud
   ```

## Common Issues and Solutions

### App Not Appearing in Nextcloud

1. **Check app ID and directory name**:
   - The app ID in `info.xml` must match the directory name (case-sensitive)
   - If using a different name, create a symlink:
     ```bash
     ./fix-app-symlink.sh
     ```

2. **Check Nextcloud version compatibility**:
   - Ensure the `<nextcloud>` version range in `info.xml` includes your Nextcloud version

3. **Check permissions**:
   - Files should be owned by www-data in the container
   - Run:
     ```bash
     docker-compose exec nextcloud chown -R www-data:www-data /var/www/html/custom_apps
     ```

### Database Issues

1. **Access the database**:
   ```bash
   docker-compose exec db mysql -u nextcloud -p nextcloud
   # Enter the password from secrets/mysql_password.txt
   ```

2. **Reset the database**:
   ```bash
   docker-compose down -v # Warning: This deletes all data!
   docker-compose up -d
   ```

## Resources

- [Nextcloud Developer Documentation](https://docs.nextcloud.com/server/latest/developer_manual/)
- [Nextcloud App Tutorial](https://docs.nextcloud.com/server/latest/developer_manual/app_development/tutorial.html)
- [Nextcloud API Documentation](https://docs.nextcloud.com/server/latest/developer_manual/app_development/api/index.html)
- [GitHub Codespaces Documentation](https://docs.github.com/en/codespaces)
- [VS Code Remote Development](https://code.visualstudio.com/docs/remote/remote-overview)
