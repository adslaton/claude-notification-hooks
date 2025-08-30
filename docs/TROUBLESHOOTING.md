# Troubleshooting Guide

Common issues and solutions for Claude Code Notification Hooks.

## Installation Issues

### ❌ Error: "Claude directory not found"

**Symptoms:** Installer fails with message about missing `~/.claude` directory.

**Cause:** Claude Code hasn't been run yet or isn't properly installed.

**Solutions:**
```bash
# Verify Claude Code installation
claude --version

# Run Claude Code once to create directory
claude "Hello world"

# Manually create directory if needed
mkdir -p ~/.claude
echo '{"$schema": "https://json.schemastore.org/claude-code-settings.json"}' > ~/.claude/settings.json
```

### ❌ Error: "Permission denied"

**Symptoms:** Cannot execute installation script or audio-notify.sh.

**Cause:** File doesn't have execute permissions.

**Solutions:**
```bash
# Make installer executable
chmod +x install.sh

# Make notification script executable
chmod +x ~/.claude/hooks/audio-notify.sh

# Fix all permissions
chmod -R 755 ~/.claude/hooks/
```

### ❌ Error: "curl: command not found"

**Symptoms:** Installation fails because curl is missing.

**Cause:** curl is not installed (rare on macOS).

**Solutions:**
```bash
# Install curl via Homebrew
brew install curl

# Or use built-in download method
/usr/bin/curl -O [URL]

# Alternative: download manually via browser
```

### ❌ Error: "Python not found"

**Symptoms:** JSON configuration update fails.

**Cause:** Python 3 is not available or not in PATH.

**Solutions:**
```bash
# Check Python availability
which python3 python

# Install Python 3 via Homebrew
brew install python3

# Use system Python (if available)
# Edit installer and replace 'python3' with 'python'

# Manual JSON editing alternative
# Edit ~/.claude/settings.json manually instead
```

## Audio Issues

### 🔇 No Sound Playing

**Symptoms:** Notifications are logged but no sound is heard.

**Diagnostic Steps:**
```bash
# Test system audio
afplay /System/Library/Sounds/Glass.aiff

# Check if afplay exists
which afplay

# Test script directly
~/.claude/hooks/audio-notify.sh completed "Test sound"

# Check volume setting
system_profiler SPAudioDataType
```

**Common Causes & Solutions:**

**System volume is muted:**
```bash
# Check and adjust system volume in System Preferences > Sound
# Or use keyboard volume keys
```

**Sound file doesn't exist:**
```bash
# Verify sound files exist
ls -la /System/Library/Sounds/Glass.aiff
ls -la /System/Library/Sounds/

# Use different sound file
echo 'get_sound() { echo "/System/Library/Sounds/Ping.aiff"; }' >> ~/.claude/hooks/sounds.conf
```

**Volume setting too low:**
```bash
# Check configuration
grep VOLUME ~/.claude/hooks/sounds.conf

# Increase volume
echo "CLAUDE_NOTIFICATION_VOLUME=0.8" >> ~/.claude/hooks/sounds.conf
```

**Sounds disabled:**
```bash
# Check if sounds are disabled
grep DISABLE_SOUNDS ~/.claude/hooks/sounds.conf

# Enable sounds
sed -i '' 's/CLAUDE_DISABLE_SOUNDS=true/#CLAUDE_DISABLE_SOUNDS=true/' ~/.claude/hooks/sounds.conf
```

### 🔊 Sound Too Loud/Quiet

**Symptoms:** Notification volume is inappropriate.

**Solutions:**
```bash
# Adjust volume in configuration
echo "CLAUDE_NOTIFICATION_VOLUME=0.5" >> ~/.claude/hooks/sounds.conf

# Test different volumes
CLAUDE_NOTIFICATION_VOLUME=0.3 ~/.claude/hooks/audio-notify.sh test "Quiet test"
CLAUDE_NOTIFICATION_VOLUME=0.8 ~/.claude/hooks/audio-notify.sh test "Loud test"
```

### 🎵 Wrong Sound Playing

**Symptoms:** Different sound plays than expected.

**Diagnostic:**
```bash
# Check which sound file is being used
~/.claude/hooks/audio-notify.sh completed "Debug test" 2>&1

# List available sounds
ls /System/Library/Sounds/

# Test specific sound
afplay /System/Library/Sounds/Glass.aiff
```

**Solutions:**
```bash
# Override sound mapping in sounds.conf
get_sound() {
  case "$1" in
    completed) echo "/System/Library/Sounds/Hero.aiff" ;;
    *) echo "/System/Library/Sounds/Tink.aiff" ;;
  esac
}
```

## Text-to-Speech Issues

### 🤐 No Voice/TTS Not Working

**Symptoms:** TTS is enabled but no speech is heard.

**Diagnostic Steps:**
```bash
# Test system TTS
say "Hello world"

# Check if say command exists
which say

# Test script with TTS
CLAUDE_ENABLE_TTS=true ~/.claude/hooks/audio-notify.sh write "TTS test"

# Check configuration
grep TTS ~/.claude/hooks/sounds.conf
```

**Common Solutions:**

**TTS not enabled:**
```bash
# Enable TTS in configuration
echo "CLAUDE_ENABLE_TTS=true" >> ~/.claude/hooks/sounds.conf
```

**Voice not available:**
```bash
# List available voices
say -v ?

# Use default voice
echo "CLAUDE_TTS_VOICE=Alex" >> ~/.claude/hooks/sounds.conf

# Test specific voice
say -v Samantha "Testing voice"
```

**System accessibility issues:**
```bash
# Check System Preferences > Security & Privacy > Privacy > Accessibility
# Ensure Terminal or Claude has accessibility permissions
```

### 🗣️ Wrong Voice or Garbled Speech

**Symptoms:** TTS uses wrong voice or speech is unclear.

**Solutions:**
```bash
# Set specific voice
echo "CLAUDE_TTS_VOICE=Samantha" >> ~/.claude/hooks/sounds.conf

# Adjust speaking rate
echo "CLAUDE_TTS_RATE=165" >> ~/.claude/hooks/sounds.conf

# Test different voices
say -v Alex "Testing Alex voice"
say -v Samantha "Testing Samantha voice"
say -v Victoria "Testing Victoria voice"
```

### 🏃 Speech Too Fast/Slow

**Symptoms:** Speaking rate is uncomfortable.

**Solutions:**
```bash
# Slower speech (words per minute)
echo "CLAUDE_TTS_RATE=150" >> ~/.claude/hooks/sounds.conf

# Faster speech
echo "CLAUDE_TTS_RATE=200" >> ~/.claude/hooks/sounds.conf

# Test rates
say -r 150 "This is slower speech"
say -r 200 "This is faster speech"
```

## Hook Integration Issues

### 🪝 Hooks Not Triggering

**Symptoms:** No notifications when using Claude tools.

**Diagnostic Steps:**
```bash
# Check if hooks are configured
grep -A 10 '"hooks"' ~/.claude/settings.json

# Verify settings.json syntax
python3 -m json.tool ~/.claude/settings.json

# Test script manually
~/.claude/hooks/audio-notify.sh write "Manual test"

# Check Claude Code version
claude --version
```

**Common Causes & Solutions:**

**Invalid JSON syntax:**
```bash
# Validate and fix JSON
python3 -m json.tool ~/.claude/settings.json

# Common issues:
# - Missing commas
# - Extra commas
# - Unmatched brackets
# - Invalid escaping
```

**Script not executable:**
```bash
# Fix permissions
chmod +x ~/.claude/hooks/audio-notify.sh

# Verify permissions
ls -la ~/.claude/hooks/audio-notify.sh
# Should show: -rwxr-xr-x
```

**Script path incorrect:**
```bash
# Use absolute path in settings.json
# Replace with full path:
"command": "/Users/yourusername/.claude/hooks/audio-notify.sh write 'File written' Write"
```

**Hook configuration missing:**
```bash
# Re-run installer to restore hooks
curl -sSL https://raw.githubusercontent.com/[username]/claude-notification-hooks/main/install.sh | bash

# Or manually add hooks configuration (see CONFIGURATION.md)
```

### 🔄 Hooks Triggering Multiple Times

**Symptoms:** Same notification plays repeatedly for one action.

**Causes:**
- Duplicate hook configurations
- Script calling itself recursively
- Multiple matchers for same event

**Solutions:**
```bash
# Check for duplicate hooks
grep -n "audio-notify.sh" ~/.claude/settings.json

# Remove duplicate entries from settings.json
# Edit file to have only one hook per event type
```

### ⚠️ Error Messages in Logs

**Symptoms:** Hook works but error messages appear.

**Check logs:**
```bash
# Check notification log
tail ~/.claude/hooks/notifications.log

# Check system logs (if available)
log show --predicate 'process == "claude"' --last 1h

# Check script errors
bash -x ~/.claude/hooks/audio-notify.sh test "Debug test"
```

## Configuration Issues

### 📝 Configuration Not Loading

**Symptoms:** Changes to sounds.conf don't take effect.

**Solutions:**
```bash
# Verify configuration file location
ls -la ~/.claude/hooks/sounds.conf

# Check for syntax errors
bash -n ~/.claude/hooks/sounds.conf

# Test configuration loading
source ~/.claude/hooks/sounds.conf && echo "Config loaded successfully"

# Check for conflicting settings
grep -v '^#' ~/.claude/hooks/sounds.conf | grep -v '^$'
```

### 🕐 Quiet Hours Not Working

**Symptoms:** Notifications play during configured quiet hours.

**Diagnostic:**
```bash
# Test quiet hours manually
HOUR=23 ~/.claude/hooks/audio-notify.sh test "Quiet hours test"

# Check current hour format
date +%H

# Verify quiet hours setting
grep QUIET_HOURS ~/.claude/hooks/sounds.conf
```

**Solutions:**
```bash
# Enable quiet hours
echo "CLAUDE_QUIET_HOURS=true" >> ~/.claude/hooks/sounds.conf

# Test time comparison logic
# The script uses 24-hour format (00-23)
```

### 📊 Logging Issues

**Symptoms:** Notifications work but aren't logged.

**Solutions:**
```bash
# Check log file permissions
ls -la ~/.claude/hooks/notifications.log

# Create log file if missing
touch ~/.claude/hooks/notifications.log

# Enable logging
echo "CLAUDE_LOG_NOTIFICATIONS=true" >> ~/.claude/hooks/sounds.conf

# Check disk space
df -h ~/.claude/hooks/
```

## Performance Issues

### 🐌 Slow Notifications

**Symptoms:** Delay between Claude action and notification.

**Causes & Solutions:**

**Large audio files:**
```bash
# Use smaller/faster audio files
# System sounds are optimized for quick playback
echo 'get_sound() { echo "/System/Library/Sounds/Tink.aiff"; }' >> ~/.claude/hooks/sounds.conf
```

**TTS processing delay:**
```bash
# Use faster speaking rate
echo "CLAUDE_TTS_RATE=200" >> ~/.claude/hooks/sounds.conf

# Use simpler voice
echo "CLAUDE_TTS_VOICE=Alex" >> ~/.claude/hooks/sounds.conf
```

**Script complexity:**
```bash
# Simplify custom functions in sounds.conf
# Remove unnecessary processing
```

### 💾 High CPU Usage

**Symptoms:** Notifications cause high system load.

**Solutions:**
```bash
# Check for infinite loops in custom functions
bash -x ~/.claude/hooks/audio-notify.sh test "CPU test"

# Ensure background processes (&) are used correctly
# Audio should play in background: afplay file &
```

## Recovery Procedures

### 🔄 Reset to Default Configuration

```bash
# Backup current config
cp ~/.claude/hooks/sounds.conf ~/.claude/hooks/sounds.conf.backup

# Reset to defaults
cp ~/.claude/hooks/sounds.conf.example ~/.claude/hooks/sounds.conf

# Or re-run installer
curl -sSL https://raw.githubusercontent.com/[username]/claude-notification-hooks/main/install.sh | bash
```

### 🗑️ Complete Removal and Reinstall

```bash
# Uninstall completely
curl -sSL https://raw.githubusercontent.com/[username]/claude-notification-hooks/main/uninstall.sh | bash

# Clean reinstall
curl -sSL https://raw.githubusercontent.com/[username]/claude-notification-hooks/main/install.sh | bash
```

### 💾 Restore from Backup

```bash
# Find backup directory (created during install/uninstall)
ls -la ~/.claude/*backup*

# Restore from backup
cp ~/.claude/hooks-backup-*/sounds.conf ~/.claude/hooks/sounds.conf
cp ~/.claude/hooks-backup-*/audio-notify.sh ~/.claude/hooks/audio-notify.sh
```

## Getting Help

### 📊 Collect Diagnostic Information

Before reporting issues, collect this information:

```bash
# System information
echo "macOS Version: $(sw_vers -productVersion)"
echo "Claude Version: $(claude --version 2>/dev/null || echo 'Not available')"

# File status
echo "Hook files:"
ls -la ~/.claude/hooks/

echo "Settings file:"
ls -la ~/.claude/settings.json

# Test commands
echo "Audio test:"
afplay /System/Library/Sounds/Ping.aiff 2>&1 || echo "Audio failed"

echo "TTS test:"
say "test" 2>&1 || echo "TTS failed"

echo "Script test:"
~/.claude/hooks/audio-notify.sh test "Diagnostic test" 2>&1
```

### 🔍 Debug Mode

Enable verbose logging for debugging:

```bash
# Run script with debug output
bash -x ~/.claude/hooks/audio-notify.sh write "Debug test"

# Add debug logging to script temporarily
# Edit audio-notify.sh and add: set -x at the top
```

### 📝 Report Issues

When reporting issues, please include:

1. **System Information**: macOS version, Claude version
2. **Error Messages**: Exact error text
3. **Steps to Reproduce**: What you did before the issue
4. **Configuration**: Your sounds.conf settings
5. **Diagnostic Output**: Results from diagnostic commands above

**Where to Report:**
- GitHub Issues: [Repository Issues Page]
- GitHub Discussions: [Repository Discussions Page]

### 🆘 Emergency Disable

If notifications are causing problems:

```bash
# Quick disable all notifications
echo "CLAUDE_DISABLE_SOUNDS=true" >> ~/.claude/hooks/sounds.conf
echo "CLAUDE_ENABLE_TTS=false" >> ~/.claude/hooks/sounds.conf

# Or remove hooks completely
mv ~/.claude/settings.json ~/.claude/settings.json.backup
echo '{"$schema": "https://json.schemastore.org/claude-code-settings.json"}' > ~/.claude/settings.json
```