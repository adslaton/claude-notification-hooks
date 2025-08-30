# Development Guide

Guide for contributing to and extending Claude Code Notification Hooks.

## Project Structure

```
claude-notification-hooks/
├── README.md                    # Main documentation
├── LICENSE                      # MIT license
├── install.sh                   # Automated installer
├── uninstall.sh                 # Clean removal script
├── hooks/
│   ├── audio-notify.sh         # Main notification script
│   ├── sounds.conf.example     # Configuration template
│   └── README.md               # Hook-specific docs
├── examples/
│   ├── settings.json.example   # Example Claude settings
│   ├── custom-voices.conf      # Voice configuration examples
│   └── quiet-hours.conf        # Time-based settings
├── docs/
│   ├── INSTALLATION.md         # Setup guide
│   ├── CONFIGURATION.md        # Configuration reference
│   ├── TROUBLESHOOTING.md      # Problem solving
│   └── DEVELOPMENT.md          # This file
└── tests/
    ├── test-notifications.sh   # Test suite
    └── test-sounds/           # Sample audio files
```

## Development Environment

### Prerequisites

- **macOS 10.15+** (primary development platform)
- **bash 3.2+** (macOS default)
- **Python 3.6+** (for JSON manipulation)
- **Git** (for version control)

### Setup

```bash
# Clone repository
git clone https://github.com/[username]/claude-notification-hooks.git
cd claude-notification-hooks

# Install pre-commit hooks (optional)
pip install pre-commit
pre-commit install

# Install development dependencies
brew install shellcheck  # For shell script linting
```

## Core Components

### audio-notify.sh

The main notification script handles:

- **Sound playback** via `afplay`
- **Text-to-speech** via `say`
- **Configuration loading** from `sounds.conf`
- **Event logging** to `notifications.log`
- **Quiet hours** and other filtering

**Key functions:**
- `get_sound()` - Maps event types to sound files
- `get_tts_message()` - Maps event types to spoken messages
- Main execution logic with configuration handling

### Configuration System

The configuration system uses:

- **sounds.conf** - User-editable shell script sourced by main script
- **Environment variables** - CLAUDE_* prefixed settings
- **Function overrides** - Users can redefine functions for customization

### Hook Integration

Claude Code hooks are configured in `~/.claude/settings.json`:

- **PostToolUse** - After tool completion
- **PreToolUse** - Before tool execution  
- **Notification** - General notifications
- **Matchers** - Tool name patterns (Write, Edit, Bash, etc.)

## Development Workflow

### Making Changes

1. **Create feature branch**
```bash
git checkout -b feature/your-feature-name
```

2. **Make changes**
   - Edit scripts in `hooks/`
   - Update documentation as needed
   - Add tests for new functionality

3. **Test changes**
```bash
# Run test suite
./tests/test-notifications.sh

# Manual testing
./hooks/audio-notify.sh write "Test change"
```

4. **Lint code**
```bash
# Check shell scripts
shellcheck hooks/audio-notify.sh install.sh uninstall.sh

# Check documentation
markdown-link-check docs/*.md
```

5. **Commit and push**
```bash
git add .
git commit -m "Add feature: description"
git push origin feature/your-feature-name
```

### Code Style

#### Shell Scripts

- Use **bash** for consistency (not sh)
- **2-space indentation**
- **Meaningful variable names** (uppercase for constants)
- **Error handling** with appropriate exit codes
- **Comments** for complex logic
- **Functions** for reusable code

**Example:**
```bash
#!/bin/bash

# Function description
function_name() {
  local param1="$1"
  local param2="${2:-default_value}"
  
  if [ -z "$param1" ]; then
    print_error "Parameter required"
    return 1
  fi
  
  # Implementation
  echo "Result: $param1"
}
```

#### Configuration Files

- **Comments** for all options
- **Logical grouping** with section headers
- **Examples** for complex settings
- **Backward compatibility** when adding new options

#### Documentation

- **Clear headings** and structure
- **Code examples** for all features
- **Cross-references** between documents
- **Troubleshooting** for common issues

## Testing

### Test Suite

The test suite (`tests/test-notifications.sh`) covers:

- **Installation verification**
- **Configuration loading**
- **Sound playback**
- **TTS functionality**
- **Hook integration**
- **Error handling**

Run tests:
```bash
cd tests
./test-notifications.sh
```

### Manual Testing

Essential manual test cases:

```bash
# Basic functionality
~/.claude/hooks/audio-notify.sh completed "Test"

# Configuration loading
echo "CLAUDE_ENABLE_TTS=true" >> ~/.claude/hooks/sounds.conf
~/.claude/hooks/audio-notify.sh write "TTS Test"

# Quiet hours
HOUR=23 ~/.claude/hooks/audio-notify.sh bash "Quiet test"

# Hook integration (requires Claude)
claude "Write a test file"
```

### Testing New Features

When adding new features:

1. **Unit tests** for individual functions
2. **Integration tests** with Claude Code
3. **Edge case testing** (missing files, permissions, etc.)
4. **Cross-platform testing** (different macOS versions)
5. **Performance testing** (large configurations, many events)

## Adding New Features

### New Event Types

To add support for a new Claude tool:

1. **Add sound mapping** in `get_sound()` function
2. **Add TTS message** in `get_tts_message()` function
3. **Update settings.json.example** with new hook configuration
4. **Document** the new event type
5. **Add test cases**

Example:
```bash
# In audio-notify.sh get_sound() function
"newtool")
  echo "/System/Library/Sounds/NewSound.aiff"
  ;;

# In audio-notify.sh get_tts_message() function  
"newtool")
  echo "New tool executed"
  ;;
```

### New Configuration Options

To add new configuration options:

1. **Add to sounds.conf.example** with comments
2. **Document** in CONFIGURATION.md
3. **Handle** in audio-notify.sh
4. **Test** with various values
5. **Maintain backward compatibility**

Example:
```bash
# In sounds.conf.example
# New feature description
# CLAUDE_NEW_FEATURE=true

# In audio-notify.sh
if [ "$CLAUDE_NEW_FEATURE" = "true" ]; then
  # Feature implementation
fi
```

### New Platform Support

To add support for Linux/Windows:

1. **Detect platform** in scripts
2. **Add platform-specific commands** (e.g., `aplay` instead of `afplay`)
3. **Update installation logic**
4. **Create platform-specific tests**
5. **Update documentation**

Example:
```bash
# Platform detection
case "$OSTYPE" in
  darwin*)
    AUDIO_CMD="afplay"
    TTS_CMD="say"
    ;;
  linux*)
    AUDIO_CMD="aplay"
    TTS_CMD="espeak"
    ;;
esac
```

## Release Process

### Version Management

- **Semantic versioning** (MAJOR.MINOR.PATCH)
- **Git tags** for releases
- **CHANGELOG.md** for release notes

### Creating Releases

1. **Update version** in relevant files
2. **Update CHANGELOG.md** with new features/fixes
3. **Test release** thoroughly
4. **Create git tag**
```bash
git tag -a v1.2.0 -m "Release version 1.2.0"
git push origin v1.2.0
```
5. **Create GitHub release** with release notes

### Distribution

- **GitHub Releases** for download packages
- **Raw file URLs** for install script
- **Documentation updates** on release

## Architecture Decisions

### Why Bash?

- **Universal availability** on macOS/Linux
- **Simple integration** with system commands
- **Easy customization** by users
- **Minimal dependencies**

### Why Function-Based Configuration?

- **Maximum flexibility** for users
- **Easy to extend** without script changes
- **Backward compatibility** with simple variables
- **Power user friendly**

### Why JSON for Claude Settings?

- **Claude Code requirement** (not our choice)
- **Structured data** for complex configurations
- **Standard format** with validation tools

## Security Considerations

### Input Validation

- **Sanitize** all user inputs
- **Validate** file paths and commands
- **Escape** shell arguments properly

### File Permissions

- **Restrictive permissions** on configuration files
- **No world-writable** files
- **Proper ownership** of hook files

### Command Execution

- **Avoid eval** and dynamic command construction
- **Use arrays** for command arguments
- **Validate** external commands before execution

## Contributing Guidelines

### Pull Requests

- **Clear description** of changes
- **Tests included** for new features
- **Documentation updates** as needed
- **No breaking changes** without major version bump

### Issue Reports

- **Detailed description** of problem
- **Steps to reproduce**
- **System information** (macOS version, etc.)
- **Configuration details**

### Code Review

All changes require:
- **Code review** by maintainer
- **Passing tests**
- **Documentation review**
- **Security review** for installation scripts

## Future Roadmap

### Planned Features

- **Linux support** (espeak, aplay)
- **Windows support** (PowerShell, SAPI)
- **Visual notifications** (macOS notifications)
- **Web interface** for configuration
- **Plugin system** for custom integrations
- **More Claude tool support** (as available)

### Performance Improvements

- **Async processing** for faster notifications
- **Caching** for frequently used sounds
- **Configuration validation** at startup
- **Memory usage optimization**

### User Experience

- **GUI configuration** tool
- **Sound preview** in configuration
- **Voice preview** for TTS selection
- **Setup wizard** for first-time users

## Resources

### Documentation

- [Bash Manual](https://www.gnu.org/software/bash/manual/)
- [macOS say command](https://ss64.com/osx/say.html)
- [macOS afplay command](https://ss64.com/osx/afplay.html)
- [JSON Schema](https://json-schema.org/)

### Tools

- [ShellCheck](https://shellcheck.net/) - Shell script linter
- [jq](https://stedolan.github.io/jq/) - JSON processor
- [Homebrew](https://brew.sh/) - macOS package manager

### Testing

- [BATS](https://github.com/bats-core/bats-core) - Bash testing framework
- [pre-commit](https://pre-commit.com/) - Git hooks framework

## Support

For development questions:

- **GitHub Discussions** - General questions
- **GitHub Issues** - Bug reports and feature requests
- **Code Review** - Pull request discussions