# Nextcloud App

This is a Nextcloud application being developed to extend Nextcloud functionality.

## Development Setup

### Prerequisites

- PHP 7.4 or higher
- Composer
- Node.js and npm
- Nextcloud server instance for testing

### Installation

1. Clone this repository into the Nextcloud apps directory:
   ```bash
   git clone https://github.com/pdarleyjr/NextCloud-App.git /path/to/nextcloud/apps/nextcloudapp
   ```

2. Install dependencies:
   ```bash
   cd /path/to/nextcloud/apps/nextcloudapp
   composer install
   npm install
   ```

3. Build the app:
   ```bash
   npm run build
   ```

4. Enable the app in Nextcloud:
   ```bash
   cd /path/to/nextcloud
   php occ app:enable nextcloudapp
   ```

## GitHub Codespaces

This repository is configured for development with GitHub Codespaces, allowing you to work on the app from anywhere without setting up a local development environment.

To start a new codespace:

1. Go to the GitHub repository
2. Click on the "Code" button
3. Select the "Codespaces" tab
4. Click "Create codespace on main"

## License

This app is licensed under the AGPL v3 License. See the [COPYING](COPYING) file for details.