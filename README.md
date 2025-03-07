# Nextcloud Therapy Scheduling App

[![Build and Test](https://github.com/pdarleyjr/NextCloud-App/actions/workflows/build-test.yml/badge.svg)](https://github.com/pdarleyjr/NextCloud-App/actions/workflows/build-test.yml)
[![CodeQL Analysis](https://github.com/pdarleyjr/NextCloud-App/actions/workflows/codeql.yml/badge.svg)](https://github.com/pdarleyjr/NextCloud-App/actions/workflows/codeql.yml)
[![Super-Linter](https://github.com/pdarleyjr/NextCloud-App/actions/workflows/super-linter.yml/badge.svg)](https://github.com/pdarleyjr/NextCloud-App/actions/workflows/super-linter.yml)
[![Dependabot](https://img.shields.io/badge/Dependabot-enabled-brightgreen)](https://github.com/pdarleyjr/NextCloud-App/blob/master/.github/dependabot.yml)

A Nextcloud app for scheduling therapy appointments and managing client information.

## Features

- Schedule and manage therapy appointments
- Integration with Nextcloud Calendar via CalDAV
- Client management and history tracking
- Secure and private data handling

## Requirements

- Nextcloud 26 or 27
- PHP 8.1 or higher
- MySQL/MariaDB database
- Redis (recommended for caching)

## Installation

### From the Nextcloud App Store

1. Navigate to Apps in your Nextcloud instance
2. Search for "Therapy Scheduling"
3. Click Install

### Manual Installation

1. Download the latest release from the [Releases page](https://github.com/pdarleyjr/NextCloud-App/releases)
2. Extract the zip file to your Nextcloud `apps` directory
3. Enable the app in Nextcloud's Apps settings

## Development

### Setup Development Environment

```bash
# Clone the repository
git clone https://github.com/pdarleyjr/NextCloud-App.git
cd NextCloud-App

# Install dependencies
composer install
npm install

# Start the development server with Docker
docker-compose up -d
```

### GitHub Codespaces

This repository is configured for GitHub Codespaces, allowing you to start a fully configured development environment in the cloud:

1. Click the "Code" button on the repository
2. Select the "Codespaces" tab
3. Click "Create codespace on master"

### Running Tests

```bash
# Run PHP unit tests
composer run-script test

# Run linting
composer run-script lint

# Run JavaScript tests
npm test
```

## Continuous Integration

This project uses GitHub Actions for continuous integration:

- **Build and Test**: Runs on every push and pull request to verify the code builds and tests pass
- **CodeQL Analysis**: Scans for security vulnerabilities in PHP and JavaScript code
- **Super-Linter**: Ensures code quality and consistency across all file types
- **Dependabot**: Automatically updates dependencies and creates pull requests

## Contributing

Contributions are welcome! Please see [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

## Security

For security issues, please see our [Security Policy](SECURITY.md).

## License

This project is licensed under the AGPL-3.0 License - see the [LICENSE](LICENSE) file for details.
