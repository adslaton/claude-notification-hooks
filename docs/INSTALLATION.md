# Installation Guide

This guide provides detailed instructions for installing Claude Code Notification Hooks.

## Prerequisites

### System Requirements

- **macOS 10.15+** (Catalina or later)
- **Claude Code** installed and configured
- **Terminal** access with standard user permissions

### Required Commands

These commands are pre-installed on macOS:
- `afplay` - For audio notifications
- `say` - For text-to-speech
- `curl` - For downloading files
- `python3` - For JSON manipulation

Verify they're available:
```bash
which afplay say curl python3
```

### Claude Code Setup

Ensure Claude Code is properly installed:
1. Run `claude --version` to verify installation
2. Check that `~/.claude/` directory exists
3. Verify you can create/edit files with Claude

## Installation Methods

### Method 1: One-Command Install (Recommended)

```bash
curl -sSL https://raw.githubusercontent.com/[username]/claude-notification-hooks/main/install.sh | bash
```

This will:
- Check system requirements
- Download and install all hook files
- Configure Claude Code settings
- Create default configuration
- Test the installation

### Method 2: Download and Run

```bash
# Download the installer
curl -O https://raw.githubusercontent.com/[username]/claude-notification-hooks/main/install.sh

# Make it executable
chmod +x install.sh

# Review the script (recommended)
less install.sh

# Run the installer
./install.sh
```

### Method 3: Git Clone

```bash
# Clone the repository
git clone https://github.com/[username]/claude-notification-hooks.git
cd claude-notification-hooks

# Run the installer
chmod +x install.sh
./install.sh
```

### Method 4: Manual Installation

If you prefer to install manually or need to customize the process:

#### Step 1: Create Directory Structure
```bash
mkdir -p ~/.claude/hooks
```

#### Step 2: Download Files
```bash
cd ~/.claude/hooks

# Download main script
curl -O https://raw.githubusercontent.com/[username]/claude-notification-hooks/main/hooks/audio-notify.sh
chmod +x audio-notify.sh

# Download configuration template
curl -O https://raw.githubusercontent.com/[username]/claude-notification-hooks/main/hooks/sounds.conf.example
cp sounds.conf.example sounds.conf

# Download documentation
curl -O https://raw.githubusercontent.com/[username]/claude-notification-hooks/main/hooks/README.md
```

#### Step 3: Configure Claude Settings

Edit `~/.claude/settings.json` to add the hooks configuration:

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Write",
        "hooks": [{"type": "command", "command": "~/.claude/hooks/audio-notify.sh write 'File written' Write"}]
      },
      {
        "matcher": "Edit", 
        "hooks": [{"type": "command", "command": "~/.claude/hooks/audio-notify.sh edit 'File edited' Edit"}]
      },
      {
        "matcher": "MultiEdit",
        "hooks": [{"type": "command", "command": "~/.claude/hooks/audio-notify.sh multiedit 'Multiple edits completed' MultiEdit"}]
      },
      {
        "matcher": "Bash",
        "hooks": [{"type": "command", "command": "~/.claude/hooks/audio-notify.sh bash 'Command executed' Bash"}]
      }
    ],
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [{"type": "command", "command": "~/.claude/hooks/audio-notify.sh alert 'Running command' Bash"}]
      }
    ]
  }
}
```

## Verification

After installation, verify everything is working:

### Test Audio Notifications
```bash
~/.claude/hooks/audio-notify.sh completed "Test sound"
~/.claude/hooks/audio-notify.sh error "Test error"
```

### Test Text-to-Speech
```bash
# Enable TTS first
echo "CLAUDE_ENABLE_TTS=true" >> ~/.claude/hooks/sounds.conf

# Test TTS
~/.claude/hooks/audio-notify.sh write "Test voice"
```

### Test with Claude
Create a test file using Claude to verify hooks are working:
```bash
claude "Write a simple hello world script to test.py"
```

You should hear notifications when Claude writes the file.

## Initial Configuration

### Enable Text-to-Speech
```bash
# Edit configuration
nano ~/.claude/hooks/sounds.conf

# Add these lines:
CLAUDE_ENABLE_TTS=true
CLAUDE_TTS_VOICE=Samantha
```

### Set Volume
```bash
# Add to sounds.conf
CLAUDE_NOTIFICATION_VOLUME=0.7
```

### Enable Quiet Hours
```bash
# Add to sounds.conf  
CLAUDE_QUIET_HOURS=true
```

## File Locations

After installation, you'll have:

```
~/.claude/
├── settings.json              # Claude settings with hooks config
└── hooks/
    ├── audio-notify.sh       # Main notification script
    ├── sounds.conf           # Your configuration
    ├── sounds.conf.example   # Configuration template
    ├── notifications.log     # Event log (created automatically)
    └── README.md            # Hook documentation
```

## Troubleshooting

### Installation Fails

**Error: Claude directory not found**
```bash
# Ensure Claude Code is installed
claude --version

# Create directory if needed
mkdir -p ~/.claude
echo '{"$schema": "https://json.schemastore.org/claude-code-settings.json"}' > ~/.claude/settings.json
```

**Error: Permission denied**
```bash
# Fix permissions
chmod +x ~/.claude/hooks/audio-notify.sh
```

**Error: Python not found**
```bash
# Install Python 3 via Homebrew
brew install python3

# Or use python (if available)
# Edit install.sh and replace 'python3' with 'python'
```

### No Audio

**Test system audio**
```bash
afplay /System/Library/Sounds/Glass.aiff
```

**Check volume settings**
```bash
# Increase system volume
# Check sounds.conf volume setting
grep VOLUME ~/.claude/hooks/sounds.conf
```

### Hooks Not Triggering

**Verify settings.json syntax**
```bash
python3 -m json.tool ~/.claude/settings.json
```

**Check file permissions**
```bash
ls -la ~/.claude/hooks/audio-notify.sh
# Should show: -rwxr-xr-x
```

**Test script directly**
```bash
~/.claude/hooks/audio-notify.sh write "Direct test"
```

## Updates

To update to the latest version:

```bash
# Re-run the installer (will backup existing config)
curl -sSL https://raw.githubusercontent.com/[username]/claude-notification-hooks/main/install.sh | bash
```

Or update manually:
```bash
# Backup your config
cp ~/.claude/hooks/sounds.conf ~/.claude/hooks/sounds.conf.backup

# Download latest files
cd ~/.claude/hooks
curl -O https://raw.githubusercontent.com/[username]/claude-notification-hooks/main/hooks/audio-notify.sh
curl -O https://raw.githubusercontent.com/[username]/claude-notification-hooks/main/hooks/README.md

# Make executable
chmod +x audio-notify.sh
```

## Uninstallation

To completely remove the notification hooks:

```bash
curl -sSL https://raw.githubusercontent.com/[username]/claude-notification-hooks/main/uninstall.sh | bash
```

This will:
- Create a backup of your configuration
- Remove all hook files
- Clean up Claude settings
- Provide restore instructions

## Next Steps

- **[Configuration Guide](CONFIGURATION.md)** - Customize your notifications
- **[Troubleshooting](TROUBLESHOOTING.md)** - Fix common issues
- **[Examples](../examples/)** - Pre-configured setups