# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- Awaiting-input notification that plays when Claude finishes responding
- New "Stop" hook support for end-of-interaction notifications
- Additional tool support for Read, Glob, and Grep operations
- Comprehensive GitHub Actions quality checks workflow
- Enhanced audio notification system with Submarine.aiff sound
- CI/CD pipeline with shellcheck, syntax validation, and documentation checks

### Changed
- Updated README with new notification type documentation
- Improved hook system configuration in install script

### Fixed
- Missing newline at end of GitHub Actions workflow file
- Enhanced CI performance with caching

## [1.0.0] - Initial Release

### Added
- Initial audio notification hook system
- Support for Write, Edit, Bash tool notifications
- Configurable quiet hours functionality
- Multiple sound options for different operations
- Text-to-speech integration
- Installation and uninstall scripts