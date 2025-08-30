# Claude Code Audio & TTS Notification Hooks

This directory contains the audio and text-to-speech notification system for Claude Code hooks, providing both sound and spoken feedback for various Claude actions.

## Files

- **audio-notify.sh** - Main notification script that plays sounds and speaks messages
- **sounds.conf** - Configuration file for customizing sounds, TTS, and settings
- **notifications.log** - Log file of all notifications (created automatically)
- **README.md** - This documentation file

## How It Works

The notification system uses Claude Code's hook system to trigger audio alerts and text-to-speech announcements when specific tools are used:

### Configured Events

1. **File Operations (PostToolUse)**:
   - **Write**: Plays Glass.aiff when files are written
   - **Edit**: Plays Glass.aiff when files are edited  
   - **MultiEdit**: Plays Glass.aiff when multiple edits are made

2. **Command Execution**:
   - **Bash (PreToolUse)**: Plays Ping.aiff before commands run
   - **Bash (PostToolUse)**: Plays Pop.aiff after commands complete

### Sound Mappings

- **completed/write/edit/multiedit**: Glass.aiff (crystal chime)
- **bash**: Pop.aiff (quick pop sound)
- **alert**: Ping.aiff (classic ping)
- **error**: Basso.aiff (deep error sound)
- **notification**: Ping.aiff (general notifications)
- **default**: Tink.aiff (light metallic sound)

## Configuration

### Basic Settings

Edit `sounds.conf` to customize:

```bash
# ===== SOUND SETTINGS =====
# Set volume (0.1 to 1.0)
CLAUDE_NOTIFICATION_VOLUME=0.7

# Disable sound notifications (keeps TTS if enabled)
CLAUDE_DISABLE_SOUNDS=true

# ===== TEXT-TO-SPEECH SETTINGS =====
# Enable text-to-speech notifications
CLAUDE_ENABLE_TTS=true

# TTS Voice (use 'say -v ?' to list available voices)
CLAUDE_TTS_VOICE=Samantha

# TTS Speaking rate (words per minute)
CLAUDE_TTS_RATE=175

# ===== GENERAL SETTINGS =====
# Enable quiet hours (10 PM to 8 AM)
CLAUDE_QUIET_HOURS=true

# Disable logging
CLAUDE_LOG_NOTIFICATIONS=false
```

### Text-to-Speech Messages

The system speaks different messages for each event:

- **Write**: "File written"
- **Edit**: "File edited" 
- **MultiEdit**: "Multiple edits completed"
- **Bash (completion)**: "Command executed"
- **Bash (alert)**: "Running command"
- **Error**: "Error occurred"
- **Notification**: Uses the provided message

### Custom Sounds

Override default sounds in `sounds.conf`:

```bash
# Use custom sounds
SOUNDS[completed]="/path/to/your/success.aiff"
SOUNDS[error]="/path/to/your/error.wav"
```

### Available System Sounds

macOS includes these system sounds in `/System/Library/Sounds/`:

- Basso.aiff - Deep error sound
- Glass.aiff - Crystal chime (default for completions)
- Hero.aiff - Triumphant chord
- Ping.aiff - Classic ping (default for alerts)
- Pop.aiff - Quick pop (default for bash)
- Sosumi.aiff - Classic Mac sound
- Tink.aiff - Light metallic sound

## Managing Notifications

### Temporarily Disable

Comment out hooks in `~/.claude/settings.json`:

```json
{
  "hooks": {
    "PostToolUse": [
      // {
      //   "matcher": "Write",
      //   "hooks": [{"type": "command", "command": "~/.claude/hooks/audio-notify.sh write 'File written' Write"}]
      // }
    ]
  }
}
```

### View Notification Log

```bash
tail -f ~/.claude/hooks/notifications.log
```

### Available TTS Voices

Popular macOS voices:
- **Alex** - Default male voice
- **Samantha** - Clear female voice  
- **Victoria** - British female voice
- **Fred** - Fun, quirky voice
- **Whisper** - Soft whisper voice
- **Bad News** - Dramatic voice
- **Good News** - Upbeat voice

List all voices: `say -v ?`

### Test Notifications

```bash
# Test different sounds only
~/.claude/hooks/audio-notify.sh completed "Test completion sound"
~/.claude/hooks/audio-notify.sh error "Test error sound"
~/.claude/hooks/audio-notify.sh alert "Test alert sound"

# Test TTS (enable CLAUDE_ENABLE_TTS=true in sounds.conf first)
CLAUDE_ENABLE_TTS=true ~/.claude/hooks/audio-notify.sh write "File written"
CLAUDE_ENABLE_TTS=true CLAUDE_TTS_VOICE=Fred ~/.claude/hooks/audio-notify.sh bash "Command executed"
```

## Troubleshooting

### No Sound Playing

1. Check if `afplay` is available: `which afplay`
2. Test sound file directly: `afplay /System/Library/Sounds/Glass.aiff`
3. Check script permissions: `ls -la ~/.claude/hooks/audio-notify.sh`
4. Verify sound file exists: `ls -la /System/Library/Sounds/Glass.aiff`
5. Check if sounds are disabled: `grep CLAUDE_DISABLE_SOUNDS ~/.claude/hooks/sounds.conf`

### No Text-to-Speech

1. Check if `say` is available: `which say`
2. Test TTS directly: `say "Hello world"`
3. Verify TTS is enabled: `grep CLAUDE_ENABLE_TTS ~/.claude/hooks/sounds.conf`
4. Test with voice: `say -v Samantha "Hello world"`

### Script Not Running

1. Check Claude settings: `cat ~/.claude/settings.json`
2. Verify hook syntax is valid JSON
3. Check script is executable: `chmod +x ~/.claude/hooks/audio-notify.sh`

### Logs Not Creating

1. Check write permissions: `touch ~/.claude/hooks/notifications.log`
2. Verify `CLAUDE_LOG_NOTIFICATIONS` is not set to false

## Customization Examples

### Quiet Hours Only on Weekdays

Edit `audio-notify.sh`:

```bash
# Check for quiet hours (weekdays only)
DAY=$(date +%u)  # 1-7 (Monday-Sunday)
HOUR=$(date +%H)

if [ "$CLAUDE_QUIET_HOURS" = "true" ] && [ $DAY -le 5 ] && ([ $HOUR -ge 22 ] || [ $HOUR -lt 8 ]); then
  exit 0
fi
```

### Different Sounds for Success/Failure

You could extend the script to check command exit codes or add more sophisticated event detection.

### Volume Based on Time of Day

```bash
# Quieter during evening hours
if [ $HOUR -ge 18 ] && [ $HOUR -lt 22 ]; then
  VOLUME_ARG="-v 0.3"
elif [ $HOUR -ge 6 ] && [ $HOUR -lt 18 ]; then
  VOLUME_ARG="-v 0.7"
else
  VOLUME_ARG="-v 0.5"
fi
```

## Security Note

The hook scripts execute with your user permissions. Only modify the configuration files and never add untrusted commands to the hooks configuration.