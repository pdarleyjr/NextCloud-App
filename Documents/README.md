# Nextcloud App Development Resources

This directory contains documentation and resources for Nextcloud app development.

## Contents

- **Nextcloud App Development Tutorials**: Guides and tutorials for developing Nextcloud apps
- **Documentation**: Nextcloud documentation and reference materials
- **GitHub Codespaces Resources**: Information about using GitHub Codespaces for development

## Nextcloud App Development

### Key Concepts

1. **App Structure**
   - `appinfo/info.xml`: App metadata, version requirements, and dependencies
   - `appinfo/routes.php`: URL routing configuration
   - `lib/`: PHP classes for business logic
   - `templates/`: Templates for rendering views
   - `js/`: JavaScript files for frontend functionality
   - `css/`: Stylesheets for app appearance

2. **App Integration**
   - Apps are mounted in the `custom_apps` directory
   - App ID must match the directory name (case-sensitive)
   - Apps must be enabled through the Nextcloud admin interface

3. **Development Workflow**
   - Make changes to app files
   - Refresh Nextcloud to see changes (most changes don't require restart)
   - Use browser developer tools and Nextcloud logs for debugging
   - Use Xdebug for PHP debugging

### Common Issues and Solutions

1. **App Not Appearing**
   - Ensure app directory name matches app ID in `info.xml`
   - Check Nextcloud version compatibility in `info.xml`
   - Verify app is properly mounted in the container
   - Check for symlink issues (see `fix-app-symlink.sh`)

2. **Permission Issues**
   - Ensure files are owned by the www-data user inside the container
   - Run `chown -R www-data:www-data /var/www/html` inside the container

3. **Debugging**
   - Check Nextcloud logs: `docker-compose logs nextcloud`
   - Enable debug mode in Nextcloud config.php
   - Use Xdebug with VS Code for step-by-step debugging

## GitHub Codespaces

When using GitHub Codespaces, remember:

1. **File Accessibility**
   - Only files committed to your repository will be available
   - Commit important files before creating a codespace
   - Use Git LFS for large files if needed

2. **Secrets Management**
   - Do not commit sensitive information to your repository
   - Use GitHub Codespaces secrets for sensitive data
   - The `secrets` directory is excluded from Git

3. **Port Forwarding**
   - Nextcloud is available on port 8080
   - Access it by clicking on the "Ports" tab and opening port 8080
   - Other services may be available on different ports

## Resources

- [Nextcloud Developer Documentation](https://docs.nextcloud.com/server/latest/developer_manual/)
- [Nextcloud App Tutorial](https://docs.nextcloud.com/server/latest/developer_manual/app_development/tutorial.html)
- [GitHub Codespaces Documentation](https://docs.github.com/en/codespaces)
- [VS Code Remote Development](https://code.visualstudio.com/docs/remote/remote-overview)
