# 🚀 Nextcloud App Development Environment

This repository provides an optimized and secure development environment for Nextcloud app development, configured to work seamlessly with GitHub Codespaces and local Docker setups.

## 📋 Features

- **Complete Nextcloud Stack**: Nextcloud, MariaDB, and Redis
- **Development Tools**: PHP, Composer, Node.js, npm, and Git
- **Debugging**: Xdebug configured for VS Code
- **Performance**: Redis caching for faster development
- **VS Code Integration**: Pre-configured extensions and settings
- **Remote Development**: Works with GitHub Codespaces and local Docker
- **Enhanced Security**: Secret management, secure configurations, and best practices

## 🌐 Quick Start

### Option 1: GitHub Codespaces

1. Click the green "Code" button on your GitHub repository
2. Select the "Codespaces" tab
3. Click "Create codespace on main"
4. Wait for the environment to be created (approximately 5-10 minutes)
5. Access Nextcloud at port 8080 (click on the "Ports" tab)
6. Log in with username `admin` and password `admin`

### Option 2: Local Development with Docker

1. Clone this repository:
   ```bash
   git clone https://github.com/pdarleyjr/NextCloud-App.git
   cd NextCloud-App
   ```

2. Run the cleanup script to ensure proper configuration:
   ```bash
   # On Linux/macOS
   bash cleanup-repository.sh
   
   # On Windows
   ./run-cleanup.ps1
   ```

3. Start the Docker containers:
   ```bash
   docker-compose up -d
   ```

4. Access Nextcloud at http://localhost:8080

5. Log in with username `admin` and password `admin`

## 📁 Project Structure

```
.
├── .devcontainer/          # Dev container configuration
├── .github/                # GitHub workflows and configuration
├── Documents/              # Documentation and resources
├── Repos/                  # Nextcloud apps (mounted as custom_apps)
│   ├── Appointments-master/  # Appointment scheduling app
│   └── calendar-main/        # Calendar app
├── docker/                 # Docker configuration files
│   ├── db/                 # Database initialization scripts
│   └── php/                # PHP configuration
├── secrets/                # Docker secrets (not committed to Git)
├── docker-compose.yml      # Docker Compose configuration
├── fix-app-symlink.sh      # Script to fix app symlinks
├── fix-app-symlink.ps1     # Windows version of symlink fix
└── GETTING_STARTED.md      # Detailed getting started guide
```

## 🧩 Developing Nextcloud Apps

Your Nextcloud apps should be placed in the `Repos` directory, which is mounted as `custom_apps` in the Nextcloud container.

### Creating a New App

1. Navigate to the `Repos` directory
2. Create a new directory with your app's ID (lowercase, e.g., `myapp`)
3. Initialize your app structure

Example app structure:

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

### Enabling Your App

1. Access Nextcloud at port 8080
2. Log in as admin
3. Go to Apps → Disabled apps
4. Find your app and click "Enable"

## 🛠️ Development Tools

### Debugging with Xdebug

Xdebug is pre-configured and ready to use with VS Code:

1. Set breakpoints in your code
2. Start the "Listen for Xdebug" debug configuration in VS Code
3. Refresh your Nextcloud page to trigger the debugger

### Database Access

You can access the MariaDB database using these credentials:

- Host: `db`
- Database: `nextcloud`
- Username: `nextcloud`
- Password: `nextcloud` (or the value in `secrets/mysql_password.txt`)

## 🔐 Security

This environment includes several security enhancements:

1. **Secret Management**: Sensitive information is stored in Docker secrets
2. **Network Isolation**: Services bind only to localhost when possible
3. **Secure Configurations**: Docker and Nextcloud are configured with security in mind

## 📚 Additional Resources

- [GETTING_STARTED.md](GETTING_STARTED.md): Detailed guide for getting started with Nextcloud app development
- [CONTRIBUTING.md](CONTRIBUTING.md): Guidelines for contributing to this project
- [Nextcloud Developer Documentation](https://docs.nextcloud.com/server/latest/developer_manual/)
- [Nextcloud App Tutorial](https://docs.nextcloud.com/server/latest/developer_manual/app_development/tutorial.html)

## 🤝 Contributing

Contributions are welcome! Please see [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

## 📄 License

This project is licensed under the AGPL v3 License - see the LICENSE file for details.
