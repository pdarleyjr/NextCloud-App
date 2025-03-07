# Contributing to NextCloud-App

Thank you for your interest in contributing to the NextCloud-App development environment! This document provides guidelines and instructions for contributing to this project.

## Getting Started

1. **Fork the repository** on GitHub
2. **Clone your fork** to your local machine
3. **Create a new branch** for your feature or bugfix
4. **Make your changes** following the coding standards
5. **Test your changes** thoroughly
6. **Commit your changes** with clear, descriptive commit messages
7. **Push to your fork** and submit a pull request

## Development Environment

This project provides a complete development environment for Nextcloud app development. To set it up:

1. Follow the instructions in the [README.md](README.md) file
2. Use the provided Docker Compose configuration to start the environment
3. Access Nextcloud at http://localhost:8080

## Coding Standards

### PHP

- Follow the [PSR-12](https://www.php-fig.org/psr/psr-12/) coding standard
- Use type hints and return type declarations where possible
- Document your code with PHPDoc comments

### JavaScript

- Follow the [Airbnb JavaScript Style Guide](https://github.com/airbnb/javascript)
- Use ES6+ features where appropriate
- Document your code with JSDoc comments

### Shell Scripts

- Include a shebang line (`#!/bin/bash` or `#!/bin/sh`)
- Use `set -e` to exit on error
- Include helpful echo statements for user feedback
- Validate input and handle errors gracefully

## Pull Request Process

1. Ensure your code follows the coding standards
2. Update the README.md with details of changes if appropriate
3. The PR should work for both GitHub Codespaces and local Docker environments
4. Include tests for new functionality if applicable
5. Update documentation to reflect any changes

## Security Considerations

- Never commit sensitive information (passwords, tokens, etc.)
- Use Docker secrets for sensitive information
- Follow the principle of least privilege
- Validate user input and sanitize data

## Documentation

- Keep documentation up-to-date
- Document new features and changes
- Use clear, concise language
- Include examples where appropriate

## Community

- Be respectful and inclusive in all communications
- Help others who have questions
- Provide constructive feedback
- Acknowledge the contributions of others

## License

By contributing to this project, you agree that your contributions will be licensed under the project's license (AGPL v3).
