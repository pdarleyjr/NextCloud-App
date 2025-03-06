# 🚀 Nextcloud App Development Environment

This repository contains an optimized development environment for Nextcloud app development, configured to work seamlessly with GitHub Codespaces and local Docker setups.

## 📋 Features

- **Complete Nextcloud Stack**: Nextcloud, MariaDB, and Redis
- **Development Tools**: PHP, Composer, Node.js, npm, and Git
- **Debugging**: Xdebug configured for VS Code
- **Performance**: Redis caching for faster development
- **VS Code Integration**: Pre-configured extensions and settings
- **Remote Development**: Works with GitHub Codespaces and local Docker

## 🌐 Using GitHub Codespaces

GitHub Codespaces provides a complete cloud-based development environment with everything pre-installed. You don't need to install Docker, WSL, or any other tools locally.

1. Click the green "Code" button on your GitHub repository
2. Select the "Codespaces" tab
3. Click "Create codespace on main"

The environment will be created and configured automatically. When it's ready:

1. The Nextcloud instance will be available on port 8080
2. You can access it by clicking on the "Ports" tab and opening port 8080
3. Log in with username `admin` and password `admin`

### 🔄 Stopping and Starting a Codespace

To stop your codespace:

1. Go to https://github.com/codespaces
2. Find your codespace in the list
3. Click the three dots menu and select "Stop codespace"

To restart it later, simply click on the codespace name in the same list.

## 💻 Local Development

If you prefer to develop locally, you can use the same configuration with Docker Desktop and VS Code:

### Prerequisites

- [Docker Desktop](https://www.docker.com/products/docker-desktop)
- [Visual Studio Code](https://code.visualstudio.com/)
- [Remote - Containers extension](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers)

### Setup

1. Clone this repository
2. Open the folder in VS Code
3. When prompted, click "Reopen in Container"
4. Alternatively, press F1, type "Remote-Containers: Open Folder in Container" and select the repository folder

If you're on Windows, you can use the included `setup-wsl.ps1` script to configure WSL properly:

```powershell
powershell -ExecutionPolicy Bypass -File setup-wsl.ps1
```

## 📁 Project Structure

```
.
├── .devcontainer/          # Dev container configuration
├── .vscode/                # VS Code settings
├── docker/                 # Docker configuration files
│   ├── db/                 # Database initialization scripts
│   └── php/                # PHP configuration
├── Repos/                  # Your Nextcloud apps (mounted as custom_apps)
└── docker-compose.yml      # Docker Compose configuration
```

## 🧩 Developing Nextcloud Apps

Your Nextcloud apps should be placed in the `Repos` directory, which is mounted as `custom_apps` in the Nextcloud container.

### Creating a New App

1. Navigate to the `Repos` directory
2. Create a new directory for your app (e.g., `myapp`)
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

## 📂 File Accessibility in GitHub Codespaces

GitHub Codespaces only has access to files that are committed to your Git repository. To ensure files are accessible in your Codespace:

1. **Commit Important Files**: Any files you need in your Codespace must be committed to your repository.

2. **Directory Structure**:

   - `Repos/`: Place your Nextcloud apps here
   - `Documents/`: Place documentation and other files here

3. **Automatic Setup**:

   - The environment is configured to mount both `Repos/` and `Documents/` directories
   - Empty directories will be created in the Codespace if they don't exist in the repository

4. **For Local Development**:
   - Both directories will be mounted from your local machine
   - For Codespaces, only the files committed to the repository will be available
   - Consider using Git LFS for large files if needed

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
- Password: `nextcloud`

A test database `nextcloud_test` is also available with the same credentials for running tests.

## 📚 Resources

- [Nextcloud Developer Documentation](https://docs.nextcloud.com/server/latest/developer_manual/)
- [Nextcloud App Tutorial](https://docs.nextcloud.com/server/latest/developer_manual/app_development/tutorial.html)
- [GitHub Codespaces Documentation](https://docs.github.com/en/codespaces)
- [VS Code Remote Development](https://code.visualstudio.com/docs/remote/remote-overview)

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## 📄 License

This project is licensed under the AGPL v3 License - see the LICENSE file for details.
