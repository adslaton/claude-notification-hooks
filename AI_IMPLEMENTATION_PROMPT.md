# AI Implementation Prompt: Claude Code Notification Hooks

This document provides a comprehensive prompt template for AI models to implement the Claude Code Notification Hooks system from scratch.

## System Overview

You are implementing an audio and text-to-speech notification system for Claude Code hooks. This system provides:

- **Audio notifications** using system sounds when Claude performs actions
- **Text-to-speech announcements** with customizable voices and messages
- **Configurable settings** for sounds, voices, quiet hours, and logging
- **Hook integration** with Claude Code's event system

## Implementation Requirements

### Target Platform
- **Primary**: macOS (using `afplay` and `say` commands)
- **System**: Claude Code with hooks support
- **Shell**: Bash-compatible scripting

### Core Components Required

1. **Main notification script** (`~/.claude/hooks/audio-notify.sh`)
2. **Configuration file** (`~/.claude/hooks/sounds.conf`)
3. **Claude settings integration** (update `~/.claude/settings.json`)
4. **Documentation** (`~/.claude/hooks/README.md`)

## Step-by-Step Implementation Guide

### Step 1: Create Directory Structure

```bash
# Create hooks directory
mkdir -p ~/.claude/hooks
```

### Step 2: Main Notification Script

Create `~/.claude/hooks/audio-notify.sh` with the following specifications:

**Script Header:**
```bash
#!/bin/bash
# Audio notification script for Claude Code hooks
# Usage: audio-notify.sh <event_type> [message] [tool_name]
```

**Required Parameters:**
- `$1` (EVENT_TYPE): Event type (write, edit, bash, error, etc.)
- `$2` (MESSAGE): Optional message to log/speak
- `$3` (TOOL_NAME): Optional tool name for context

**Required Functions:**

1. **Sound Mapping Function:**
```bash
get_sound() {
  case "$1" in
    completed|write|edit|multiedit)
      echo "/System/Library/Sounds/Glass.aiff"
      ;;
    error)
      echo "/System/Library/Sounds/Basso.aiff"
      ;;
    alert|notification)
      echo "/System/Library/Sounds/Ping.aiff"
      ;;
    bash)
      echo "/System/Library/Sounds/Pop.aiff"
      ;;
    *)
      echo "/System/Library/Sounds/Tink.aiff"
      ;;
  esac
}
```

2. **TTS Message Function:**
```bash
get_tts_message() {
  local event_type="$1"
  local message="$2"
  local tool_name="$3"
  
  case "$event_type" in
    completed|write)
      echo "File written"
      ;;
    edit)
      echo "File edited"
      ;;
    multiedit)
      echo "Multiple edits completed"
      ;;
    bash)
      echo "Command executed"
      ;;
    alert)
      echo "Running command"
      ;;
    error)
      echo "Error occurred"
      ;;
    notification)
      echo "$message"
      ;;
    *)
      echo "Claude notification"
      ;;
  esac
}
```

**Required Configuration Loading:**
```bash
# Configuration
SCRIPT_DIR="$(dirname "$0")"
CONFIG_FILE="$SCRIPT_DIR/sounds.conf"
LOG_FILE="$SCRIPT_DIR/notifications.log"

# Load custom configuration if it exists
if [ -f "$CONFIG_FILE" ]; then
  source "$CONFIG_FILE"
fi
```

**Required Quiet Hours Check:**
```bash
# Check for quiet hours (22:00 - 08:00)
HOUR=$(date +%H)
if [ "$CLAUDE_QUIET_HOURS" = "true" ] && ([ $HOUR -ge 22 ] || [ $HOUR -lt 8 ]); then
  exit 0
fi
```

**Required Audio Playback:**
```bash
# Play sound if enabled and file exists
if [ "$CLAUDE_DISABLE_SOUNDS" != "true" ] && command -v afplay >/dev/null 2>&1 && [ -f "$SOUND_FILE" ]; then
  VOLUME_ARG=""
  if [ -n "$CLAUDE_NOTIFICATION_VOLUME" ]; then
    VOLUME_ARG="-v $CLAUDE_NOTIFICATION_VOLUME"
  fi
  afplay $VOLUME_ARG "$SOUND_FILE" &
fi
```

**Required Text-to-Speech:**
```bash
# Text-to-speech notification
if [ "$CLAUDE_ENABLE_TTS" = "true" ] && command -v say >/dev/null 2>&1; then
  TTS_MESSAGE="$(get_tts_message "$EVENT_TYPE" "$MESSAGE" "$TOOL_NAME")"
  
  VOICE_ARG=""
  if [ -n "$CLAUDE_TTS_VOICE" ]; then
    VOICE_ARG="-v $CLAUDE_TTS_VOICE"
  fi
  
  RATE_ARG=""
  if [ -n "$CLAUDE_TTS_RATE" ]; then
    RATE_ARG="-r $CLAUDE_TTS_RATE"
  fi
  
  say $VOICE_ARG $RATE_ARG "$TTS_MESSAGE" &
fi
```

**Required Logging:**
```bash
# Log the event if logging is enabled
if [ "$CLAUDE_LOG_NOTIFICATIONS" != "false" ]; then
  TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')
  TOOL_INFO=""
  if [ -n "$TOOL_NAME" ]; then
    TOOL_INFO=" [$TOOL_NAME]"
  fi
  echo "[$TIMESTAMP] $EVENT_TYPE$TOOL_INFO: $MESSAGE" >> "$LOG_FILE"
fi
```

**Make script executable:**
```bash
chmod +x ~/.claude/hooks/audio-notify.sh
```

### Step 3: Configuration File

Create `~/.claude/hooks/sounds.conf` with these default settings:

```bash
# Claude Code Audio Notification Configuration
# This file allows you to customize sound and text-to-speech settings for notifications

# ===== SOUND SETTINGS =====
# Volume setting (0.1 to 1.0, where 1.0 is max volume)
# CLAUDE_NOTIFICATION_VOLUME=0.7

# Disable sound notifications (keeps TTS if enabled)
# CLAUDE_DISABLE_SOUNDS=true

# ===== TEXT-TO-SPEECH SETTINGS =====
# Enable text-to-speech notifications
# CLAUDE_ENABLE_TTS=true

# TTS Voice (use 'say -v ?' to list available voices)
# CLAUDE_TTS_VOICE=Samantha

# TTS Speaking rate (words per minute, default is around 175)
# CLAUDE_TTS_RATE=175

# ===== GENERAL SETTINGS =====
# Quiet hours - disable notifications between 10 PM and 8 AM
# CLAUDE_QUIET_HOURS=true

# Logging - set to false to disable notification logging
# CLAUDE_LOG_NOTIFICATIONS=true
```

### Step 4: Claude Settings Integration

Update `~/.claude/settings.json` to include hooks configuration. Add this to the JSON structure:

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Write",
        "hooks": [
          {
            "type": "command",
            "command": "~/.claude/hooks/audio-notify.sh write 'File written' Write"
          }
        ]
      },
      {
        "matcher": "Edit",
        "hooks": [
          {
            "type": "command",
            "command": "~/.claude/hooks/audio-notify.sh edit 'File edited' Edit"
          }
        ]
      },
      {
        "matcher": "MultiEdit",
        "hooks": [
          {
            "type": "command",
            "command": "~/.claude/hooks/audio-notify.sh multiedit 'Multiple edits completed' MultiEdit"
          }
        ]
      },
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "command",
            "command": "~/.claude/hooks/audio-notify.sh bash 'Command executed' Bash"
          }
        ]
      }
    ],
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "command",
            "command": "~/.claude/hooks/audio-notify.sh alert 'Running command' Bash"
          }
        ]
      }
    ]
  }
}
```

**IMPORTANT:** Ensure the JSON remains valid by properly merging with existing content.

### Step 5: Documentation

Create `~/.claude/hooks/README.md` with basic usage instructions:

```markdown
# Claude Code Audio & TTS Notification Hooks

This directory contains the audio and text-to-speech notification system for Claude Code hooks.

## Configuration

Edit `sounds.conf` to customize:

- `CLAUDE_ENABLE_TTS=true` - Enable text-to-speech
- `CLAUDE_TTS_VOICE=Samantha` - Set voice
- `CLAUDE_NOTIFICATION_VOLUME=0.7` - Set sound volume
- `CLAUDE_QUIET_HOURS=true` - Enable quiet hours (10 PM - 8 AM)

## Testing

Test your setup:
```bash
~/.claude/hooks/audio-notify.sh completed "Test notification"
```

## Logs

Check notification history:
```bash
tail ~/.claude/hooks/notifications.log
```
```

## Validation Steps

After implementation, verify the system works:

### Test 1: Basic Execution
```bash
~/.claude/hooks/audio-notify.sh test "Implementation test"
```
**Expected:** Sound plays and event is logged

### Test 2: TTS Functionality  
```bash
echo "CLAUDE_ENABLE_TTS=true" >> ~/.claude/hooks/sounds.conf
~/.claude/hooks/audio-notify.sh write "TTS test"
```
**Expected:** Sound plays AND voice speaks "File written"

### Test 3: Event Types
```bash
~/.claude/hooks/audio-notify.sh write "Write test"
~/.claude/hooks/audio-notify.sh edit "Edit test"  
~/.claude/hooks/audio-notify.sh bash "Bash test"
~/.claude/hooks/audio-notify.sh error "Error test"
```
**Expected:** Different sounds for each event type

### Test 4: Configuration Loading
```bash
echo "CLAUDE_NOTIFICATION_VOLUME=0.3" >> ~/.claude/hooks/sounds.conf
~/.claude/hooks/audio-notify.sh completed "Volume test"
```
**Expected:** Quieter sound

### Test 5: Quiet Hours
```bash
echo "CLAUDE_QUIET_HOURS=true" >> ~/.claude/hooks/sounds.conf
HOUR=23 ~/.claude/hooks/audio-notify.sh bash "Quiet test"
```
**Expected:** No sound, no log entry

### Test 6: Claude Integration
Create a test file using Claude to verify hooks trigger automatically:
```bash
# This should trigger the Write hook
claude "Create a simple hello.txt file"
```
**Expected:** Notification when Claude writes the file

## Error Handling Requirements

The implementation must handle these error conditions gracefully:

1. **Missing commands:** Check `afplay` and `say` availability
2. **Missing files:** Verify sound files exist before playing
3. **Configuration errors:** Handle malformed configuration files
4. **Permission errors:** Ensure proper file permissions
5. **Audio system issues:** Graceful failure if audio unavailable

## Common Issues and Solutions

### Issue: No sound playing
**Solution:** 
- Check system volume
- Verify `afplay` command works: `afplay /System/Library/Sounds/Glass.aiff`
- Check sound file paths in `get_sound()` function

### Issue: No text-to-speech
**Solution:**
- Verify `CLAUDE_ENABLE_TTS=true` in configuration
- Test `say` command directly: `say "test"`
- Check voice availability: `say -v ?`

### Issue: Hooks not triggering
**Solution:**
- Verify `~/.claude/settings.json` syntax with: `python3 -m json.tool ~/.claude/settings.json`
- Check script permissions: `chmod +x ~/.claude/hooks/audio-notify.sh`
- Verify file paths in hooks configuration

## Advanced Customization Options

Users can extend the system by:

1. **Custom sound files:** Override `get_sound()` function in `sounds.conf`
2. **Custom TTS messages:** Override `get_tts_message()` function
3. **Advanced quiet hours:** Custom time logic in configuration
4. **Context-aware notifications:** Check system state before notification

## Security Considerations

- Scripts should not execute arbitrary commands
- Configuration files should have restrictive permissions  
- Input validation for all parameters
- No sensitive data in logs

## Success Criteria

The implementation is successful when:

1. ✅ All test cases pass
2. ✅ Audio notifications play for Claude actions
3. ✅ Text-to-speech works with different voices
4. ✅ Configuration changes take effect
5. ✅ Quiet hours and logging work correctly
6. ✅ System integrates seamlessly with Claude Code

## Reference Implementation

For complete reference, see: https://github.com/[username]/claude-notification-hooks

This prompt provides everything needed to implement the Claude Code Notification Hooks system from scratch. Follow the specifications exactly to ensure compatibility and functionality.