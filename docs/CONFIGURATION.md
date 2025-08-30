# Configuration Guide

Comprehensive guide to configuring Claude Code Notification Hooks for your specific needs.

## Configuration File

The main configuration file is located at `~/.claude/hooks/sounds.conf`.

### Default Configuration

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

## Audio Settings

### Volume Control

Control the volume of audio notifications:

```bash
# Set volume to 70%
CLAUDE_NOTIFICATION_VOLUME=0.7

# Quiet volume for late night
CLAUDE_NOTIFICATION_VOLUME=0.3

# Maximum volume
CLAUDE_NOTIFICATION_VOLUME=1.0
```

### Disable Sounds

Keep text-to-speech but disable sound effects:

```bash
CLAUDE_DISABLE_SOUNDS=true
CLAUDE_ENABLE_TTS=true
```

### Custom Sound Files

Override default system sounds with your own:

```bash
# Add custom sound function to sounds.conf
get_sound() {
  case "$1" in
    completed|write|edit|multiedit)
      echo "/Users/yourname/sounds/success.wav"
      ;;
    error)
      echo "/Users/yourname/sounds/error.mp3"
      ;;
    bash)
      echo "/Users/yourname/sounds/command.aiff"
      ;;
    *)
      echo "/System/Library/Sounds/Tink.aiff"
      ;;
  esac
}
```

## Text-to-Speech Settings

### Enable TTS

```bash
CLAUDE_ENABLE_TTS=true
```

### Voice Selection

List available voices:
```bash
say -v ?
```

Popular voice options:
```bash
# Clear female voice (recommended)
CLAUDE_TTS_VOICE=Samantha

# Default male voice
CLAUDE_TTS_VOICE=Alex

# British female accent
CLAUDE_TTS_VOICE=Victoria

# Fun, quirky voice
CLAUDE_TTS_VOICE=Fred

# Gentle whisper
CLAUDE_TTS_VOICE=Whisper

# Dramatic voices
CLAUDE_TTS_VOICE="Bad News"
CLAUDE_TTS_VOICE="Good News"
```

### Speaking Rate

Adjust how fast the voice speaks (words per minute):

```bash
# Slower for easier understanding
CLAUDE_TTS_RATE=150

# Default speed
CLAUDE_TTS_RATE=175

# Faster for efficiency
CLAUDE_TTS_RATE=220

# Maximum speed
CLAUDE_TTS_RATE=300
```

### Custom TTS Messages

Override default messages with your own:

```bash
# Add to sounds.conf
get_tts_message() {
  local event_type="$1"
  local message="$2"
  local tool_name="$3"
  
  case "$event_type" in
    completed|write)
      echo "File saved successfully!"
      ;;
    edit)
      echo "Your edits are complete!"
      ;;
    multiedit)
      echo "Multiple changes applied!"
      ;;
    bash)
      echo "Command finished!"
      ;;
    alert)
      echo "About to run command!"
      ;;
    error)
      echo "Something went wrong!"
      ;;
    *)
      echo "Claude notification"
      ;;
  esac
}
```

## Quiet Hours

### Basic Quiet Hours

Disable all notifications from 10 PM to 8 AM:

```bash
CLAUDE_QUIET_HOURS=true
```

### Custom Quiet Hours

```bash
# Add custom function to sounds.conf
custom_quiet_hours_check() {
  local hour=$(date +%H)
  local day=$(date +%u)  # 1=Monday, 7=Sunday
  
  # Extended quiet hours (9 PM to 9 AM)
  if [ $hour -ge 21 ] || [ $hour -lt 9 ]; then
    return 0  # In quiet hours
  fi
  
  # Weekend sleep-in (until 10 AM)
  if [ $day -ge 6 ] && [ $hour -lt 10 ]; then
    return 0
  fi
  
  return 1  # Not in quiet hours
}
```

### Gradual Volume Control

Instead of complete silence, reduce volume during quiet hours:

```bash
get_quiet_hours_volume() {
  local hour=$(date +%H)
  
  if [ $hour -ge 22 ] || [ $hour -lt 8 ]; then
    echo "0.2"  # 20% volume during night
  elif [ $hour -ge 8 ] && [ $hour -lt 10 ]; then
    echo "0.5"  # 50% volume during morning
  elif [ $hour -ge 20 ] && [ $hour -lt 22 ]; then
    echo "0.5"  # 50% volume during evening
  else
    echo "0.8"  # 80% volume during active hours
  fi
}

CLAUDE_NOTIFICATION_VOLUME=$(get_quiet_hours_volume)
```

## Logging Configuration

### Enable/Disable Logging

```bash
# Disable logging
CLAUDE_LOG_NOTIFICATIONS=false

# Enable logging (default)
CLAUDE_LOG_NOTIFICATIONS=true
```

### Custom Log Location

```bash
# Override in audio-notify.sh
LOG_FILE="/Users/yourname/claude-notifications.log"
```

### Log Format Customization

Edit the logging section in `audio-notify.sh`:

```bash
# Custom log format
echo "$(date '+%Y-%m-%d %H:%M:%S') | $EVENT_TYPE | $TOOL_NAME | $MESSAGE" >> "$LOG_FILE"
```

## Hook Configuration

The hooks are configured in `~/.claude/settings.json`. You can modify which events trigger notifications:

### Event Types

- **PostToolUse**: After a tool completes successfully
- **PreToolUse**: Before a tool starts
- **Notification**: General Claude notifications
- **Error**: When tools fail (if implemented)

### Tool Matchers

- **Write**: File creation
- **Edit**: File modification
- **MultiEdit**: Multiple file changes
- **Bash**: Command execution
- **Read**: File reading (if desired)
- **Glob**: File searching (if desired)

### Custom Hook Example

Add notifications for Read operations:

```json
{
  "matcher": "Read",
  "hooks": [
    {
      "type": "command",
      "command": "~/.claude/hooks/audio-notify.sh read 'File read' Read"
    }
  ]
}
```

## Advanced Configuration

### Time-Based Voice Switching

Different voices for different times of day:

```bash
get_time_based_voice() {
  local hour=$(date +%H)
  
  if [ $hour -ge 6 ] && [ $hour -lt 12 ]; then
    echo "Good News"  # Upbeat morning
  elif [ $hour -ge 12 ] && [ $hour -lt 18 ]; then
    echo "Alex"       # Professional work hours
  elif [ $hour -ge 18 ] && [ $hour -lt 22 ]; then
    echo "Samantha"   # Friendly evening
  else
    echo "Whisper"    # Quiet late night
  fi
}

CLAUDE_TTS_VOICE=$(get_time_based_voice)
```

### Context-Aware Notifications

Check system state for intelligent notifications:

```bash
is_user_busy() {
  # Check if in a video call
  if pgrep -x "Zoom" > /dev/null || pgrep -x "Teams" > /dev/null; then
    return 0  # User is busy
  fi
  
  # Check system load
  local load=$(uptime | awk -F'load average:' '{ print $2 }' | cut -d, -f1 | sed 's/ //g' | cut -d. -f1)
  if [ "$load" -gt 5 ]; then
    return 0  # System is busy
  fi
  
  return 1  # User is available
}

# Use in audio-notify.sh
if is_user_busy; then
  # Reduce volume or skip non-critical notifications
  CLAUDE_NOTIFICATION_VOLUME=0.2
fi
```

### Event Priority System

Different notification styles based on importance:

```bash
get_priority_settings() {
  local event_type="$1"
  
  case "$event_type" in
    error)
      echo "PRIORITY=HIGH VOLUME=1.0 VOICE=Bad_News RATE=150"
      ;;
    write|edit)
      echo "PRIORITY=MEDIUM VOLUME=0.7 VOICE=Samantha RATE=175"
      ;;
    bash)
      echo "PRIORITY=LOW VOLUME=0.5 VOICE=Alex RATE=200"
      ;;
  esac
}
```

## Configuration Profiles

### Profile: Minimal (Sounds Only)

```bash
# Sounds only, no TTS
CLAUDE_ENABLE_TTS=false
CLAUDE_NOTIFICATION_VOLUME=0.5
CLAUDE_LOG_NOTIFICATIONS=false
```

### Profile: TTS Only

```bash
# Voice only, no sounds
CLAUDE_DISABLE_SOUNDS=true
CLAUDE_ENABLE_TTS=true
CLAUDE_TTS_VOICE=Samantha
CLAUDE_TTS_RATE=175
```

### Profile: Full Experience

```bash
# Both sounds and TTS
CLAUDE_ENABLE_TTS=true
CLAUDE_TTS_VOICE=Samantha
CLAUDE_TTS_RATE=165
CLAUDE_NOTIFICATION_VOLUME=0.7
CLAUDE_QUIET_HOURS=true
```

### Profile: Development Focus

```bash
# Minimal interruption during coding
CLAUDE_ENABLE_TTS=false
CLAUDE_NOTIFICATION_VOLUME=0.3
CLAUDE_QUIET_HOURS=true
# Only notify on errors and completions
```

## Testing Your Configuration

After making changes, test your configuration:

```bash
# Test sound volume
~/.claude/hooks/audio-notify.sh completed "Volume test"

# Test TTS voice
~/.claude/hooks/audio-notify.sh write "Voice test"

# Test quiet hours (temporarily set time)
HOUR=23 ~/.claude/hooks/audio-notify.sh bash "Quiet hours test"

# Test different event types
~/.claude/hooks/audio-notify.sh error "Error test"
~/.claude/hooks/audio-notify.sh alert "Alert test"
```

## Backup and Restore

### Backup Configuration

```bash
cp ~/.claude/hooks/sounds.conf ~/.claude/hooks/sounds.conf.backup
cp ~/.claude/settings.json ~/.claude/settings.json.backup
```

### Restore Configuration

```bash
cp ~/.claude/hooks/sounds.conf.backup ~/.claude/hooks/sounds.conf
cp ~/.claude/settings.json.backup ~/.claude/settings.json
```

## Troubleshooting Configuration

### Validate Settings

```bash
# Check JSON syntax
python3 -m json.tool ~/.claude/settings.json

# Check bash syntax
bash -n ~/.claude/hooks/audio-notify.sh

# Check configuration sourcing
source ~/.claude/hooks/sounds.conf && echo "Configuration valid"
```

### Reset to Defaults

```bash
# Reset sounds.conf to defaults
cp ~/.claude/hooks/sounds.conf.example ~/.claude/hooks/sounds.conf

# Or re-run installer
curl -sSL https://raw.githubusercontent.com/[username]/claude-notification-hooks/main/install.sh | bash
```