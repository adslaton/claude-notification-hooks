# Claude Code Notification Hooks

🔊 Add audio alerts and text-to-speech notifications to your Claude Code sessions! Get notified when Claude writes files, runs commands, or encounters errors.

## ✨ Features

- **🎵 Audio Notifications**: System sound alerts for different events
- **🗣️ Text-to-Speech**: Spoken announcements with customizable voices  
- **⚙️ Highly Configurable**: Custom sounds, voices, quiet hours, and more
- **📝 Event Logging**: Track all notifications with timestamps
- **🌙 Quiet Hours**: Automatic silence during specified hours
- **🎛️ Flexible Control**: Enable/disable sounds and TTS independently
- **📝 Contextual Announcements**: File names and commands are spoken for better awareness

## 🎯 Supported Events

| Event | Default Sound | TTS Message | When It Triggers |
|-------|---------------|-------------|------------------|
| **File Write** | Glass.aiff | "Claude created file [filename]" | When Claude creates new files |
| **File Edit** | Glass.aiff | "Claude modified file [filename]" | When Claude modifies existing files |
| **MultiEdit** | Glass.aiff | "Claude has completed multiple file edits" | When Claude makes multiple changes |
| **File Read** | Tink.aiff | "Claude is reading file [filename]" | When Claude reads files |
| **File Search** | Morse.aiff | "Claude is searching for files" | When Claude uses Glob to find files |
| **Content Search** | Morse.aiff | "Claude is searching in file [filename]" | When Claude uses Grep to search content |
| **Bash Execution** | Pop.aiff | "Claude finished running [command]" | After commands finish |
| **Pre-Bash Alert** | Ping.aiff | "Claude is about to run [command]" | Before commands start |
| **Errors** | Basso.aiff | "Claude encountered an error with [context]" | When operations fail |

## 🚀 Quick Install

```bash
curl -sSL https://raw.githubusercontent.com/[username]/claude-notification-hooks/main/install.sh | bash
```

Or download and run manually:
```bash
git clone https://github.com/[username]/claude-notification-hooks.git
cd claude-notification-hooks
chmod +x install.sh
./install.sh
```

## 📋 Requirements

- **macOS** with `afplay` and `say` commands (pre-installed)
- **Claude Code** with hooks support
- **Write permissions** to `~/.claude/` directory

## ⚡ Quick Configuration

After installation, customize your experience:

```bash
# Edit configuration
nano ~/.claude/hooks/sounds.conf

# Test your setup
~/.claude/hooks/audio-notify.sh write "Test notification"
```

### Enable Text-to-Speech
```bash
# Edit ~/.claude/hooks/sounds.conf
CLAUDE_ENABLE_TTS=true
CLAUDE_TTS_VOICE=Samantha
```

### Set Quiet Hours
```bash
# Edit ~/.claude/hooks/sounds.conf  
CLAUDE_QUIET_HOURS=true  # Silence 10 PM - 8 AM
```

## 🎨 Popular Configurations

### Sounds Only (No TTS)
```bash
CLAUDE_ENABLE_TTS=false
CLAUDE_NOTIFICATION_VOLUME=0.7
```

### TTS Only (No Sounds)
```bash
CLAUDE_DISABLE_SOUNDS=true
CLAUDE_ENABLE_TTS=true
CLAUDE_TTS_VOICE=Alex
```

### Custom Voice Setup
```bash
CLAUDE_ENABLE_TTS=true
CLAUDE_TTS_VOICE=Fred          # Fun, quirky voice
CLAUDE_TTS_RATE=200           # Faster speech
```

## 🎙️ Available Voices

Popular macOS voices:
- **Samantha** - Clear female voice (recommended)
- **Alex** - Default male voice
- **Victoria** - British female accent
- **Fred** - Fun, quirky personality
- **Whisper** - Soft, gentle voice

List all voices: `say -v ?`

## 📚 Documentation

- **[Installation Guide](docs/INSTALLATION.md)** - Detailed setup instructions
- **[Configuration Reference](docs/CONFIGURATION.md)** - All options explained
- **[Troubleshooting](docs/TROUBLESHOOTING.md)** - Common issues & solutions
- **[Development](docs/DEVELOPMENT.md)** - Contributing guidelines

## 🧪 Testing

Test your installation:
```bash
# Test sounds
~/.claude/hooks/audio-notify.sh completed "Success!"
~/.claude/hooks/audio-notify.sh error "Error test"

# Test TTS (if enabled)
CLAUDE_ENABLE_TTS=true ~/.claude/hooks/audio-notify.sh write "File written"
```

## 🛠️ Customization Examples

### Custom Sound Files
```bash
# Use your own sounds
get_sound() {
  case "$1" in
    completed) echo "/path/to/success.wav" ;;
    error) echo "/path/to/error.mp3" ;;
    *) echo "/System/Library/Sounds/Tink.aiff" ;;
  esac
}
```

### Time-Based Volume
```bash
# Quieter in the evening
HOUR=$(date +%H)
if [ $HOUR -ge 18 ]; then
  CLAUDE_NOTIFICATION_VOLUME=0.3
else
  CLAUDE_NOTIFICATION_VOLUME=0.7
fi
```

## 🗑️ Uninstall

```bash
curl -sSL https://raw.githubusercontent.com/[username]/claude-notification-hooks/main/uninstall.sh | bash
```

Or manually:
```bash
rm -rf ~/.claude/hooks/
# Remove hooks section from ~/.claude/settings.json
```

## 🤝 Contributing

We welcome contributions! Please see [DEVELOPMENT.md](docs/DEVELOPMENT.md) for guidelines.

## 📄 License

MIT License - see [LICENSE](LICENSE) for details.

## 🙋 Support

- **Issues**: [GitHub Issues](https://github.com/[username]/claude-notification-hooks/issues)
- **Discussions**: [GitHub Discussions](https://github.com/[username]/claude-notification-hooks/discussions)

---

**Made with ❤️ for the Claude Code community**