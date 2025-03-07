# Contributing to Nextcloud App

Thank you for your interest in contributing to our Nextcloud App! This document provides guidelines and instructions for contributing.

## Code of Conduct

By participating in this project, you agree to maintain a respectful and inclusive environment for everyone. Please be kind and constructive in your communications.

## How Can I Contribute?

### Reporting Bugs

Bugs are tracked as GitHub issues. Before creating a bug report, please check if the issue already exists. When you create a bug report, please include as many details as possible by filling out the bug report template.

### Suggesting Enhancements

Enhancement suggestions are also tracked as GitHub issues. Before creating an enhancement suggestion, please check if the suggestion already exists. When you create an enhancement suggestion, please include as many details as possible by filling out the feature request template.

### Pull Requests

1. Fork the repository
2. Create a new branch for your feature or bugfix (`git checkout -b feature/your-feature-name`)
3. Make your changes
4. Run tests to ensure your changes don't break existing functionality
5. Commit your changes (`git commit -m 'Add some feature'`)
6. Push to the branch (`git push origin feature/your-feature-name`)
7. Open a Pull Request

## Development Setup

### Prerequisites

- PHP 8.1 or higher
- Composer
- Docker and Docker Compose (for local development)
- Nextcloud development environment

### Setting Up the Development Environment

1. Clone the repository
2. Follow the instructions in the README.md file to set up the development environment

## Coding Standards

### PHP

- Follow PSR-12 coding standards
- Use type hints where possible
- Document your code with PHPDoc comments

### JavaScript

- Follow ESLint rules defined in the project
- Use modern JavaScript features (ES6+)
- Document complex functions

### CSS/SCSS

- Follow the Nextcloud design guidelines
- Use SCSS variables for colors and spacing

## Testing

- Write unit tests for PHP code using PHPUnit
- Write JavaScript tests where applicable
- Manually test your changes in different browsers

## Documentation

- Update the README.md file if necessary
- Document new features or changes in behavior
- Update inline documentation

## Commit Messages

Use clear and meaningful commit messages that explain what changes were made and why. Follow the conventional commits format:

```
<type>(<scope>): <description>

[optional body]

[optional footer]
```

Types include:
- feat: A new feature
- fix: A bug fix
- docs: Documentation changes
- style: Changes that don't affect the code's meaning (formatting, etc.)
- refactor: Code changes that neither fix a bug nor add a feature
- perf: Performance improvements
- test: Adding or correcting tests
- chore: Changes to the build process or auxiliary tools

## Release Process

Releases are managed by the maintainers. We use semantic versioning (MAJOR.MINOR.PATCH).

## Questions?

If you have any questions about contributing, please open an issue or contact the maintainers directly.

Thank you for contributing to make this project better!
