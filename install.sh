#!/bin/bash

# Claude Code Notification Hooks Installer
# Installs audio and TTS notification system for Claude Code

set -e

REPO_URL="https://raw.githubusercontent.com/adslaton/claude-notification-hooks/main"
HOOKS_DIR="$HOME/.claude/hooks"
SETTINGS_FILE="$HOME/.claude/settings.json"
BACKUP_DIR="$HOME/.claude/hooks-backup-$(date +%Y%m%d-%H%M%S)"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_step() {
    echo -e "${BLUE}==>${NC} $1"
}

print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

check_requirements() {
    print_step "Checking system requirements..."
    
    # Check macOS
    if [[ "$OSTYPE" != "darwin"* ]]; then
        print_error "This installer is designed for macOS. Linux support coming soon!"
        exit 1
    fi
    
    # Check afplay
    if ! command -v afplay >/dev/null 2>&1; then
        print_error "afplay command not found. Audio notifications will not work."
        print_warning "This is unusual for macOS. Please check your system."
    else
        print_success "afplay found - audio notifications supported"
    fi
    
    # Check say
    if ! command -v say >/dev/null 2>&1; then
        print_warning "say command not found. Text-to-speech will not work."
        print_warning "This is unusual for macOS. Please check your system."
    else
        print_success "say found - text-to-speech supported"
    fi
    
    # Check curl
    if ! command -v curl >/dev/null 2>&1; then
        print_error "curl not found. Cannot download files."
        exit 1
    fi
}

check_claude_directory() {
    print_step "Checking Claude Code directory..."
    
    if [ ! -d "$HOME/.claude" ]; then
        print_error "Claude Code directory not found at ~/.claude"
        print_error "Please make sure Claude Code is installed and you've run it at least once."
        exit 1
    fi
    
    if [ ! -f "$SETTINGS_FILE" ]; then
        print_warning "Settings file not found. Creating default settings.json..."
        mkdir -p "$HOME/.claude"
        echo '{"$schema": "https://json.schemastore.org/claude-code-settings.json"}' > "$SETTINGS_FILE"
    fi
    
    print_success "Claude Code directory found"
}

backup_existing() {
    if [ -d "$HOOKS_DIR" ]; then
        print_step "Backing up existing hooks..."
        cp -r "$HOOKS_DIR" "$BACKUP_DIR"
        print_success "Backup created at $BACKUP_DIR"
    fi
}

create_hooks_directory() {
    print_step "Creating hooks directory..."
    mkdir -p "$HOOKS_DIR"
    print_success "Hooks directory created"
}

download_files() {
    print_step "Downloading notification files..."
    
    # Download main script
    curl -sSL "$REPO_URL/hooks/audio-notify.sh" -o "$HOOKS_DIR/audio-notify.sh"
    chmod +x "$HOOKS_DIR/audio-notify.sh"
    print_success "Downloaded audio-notify.sh"
    
    # Download configuration template
    curl -sSL "$REPO_URL/hooks/sounds.conf.example" -o "$HOOKS_DIR/sounds.conf.example"
    
    # Create default configuration if it doesn't exist
    if [ ! -f "$HOOKS_DIR/sounds.conf" ]; then
        cp "$HOOKS_DIR/sounds.conf.example" "$HOOKS_DIR/sounds.conf"
        print_success "Created default sounds.conf"
    else
        print_warning "Existing sounds.conf preserved"
    fi
    
    # Download documentation
    curl -sSL "$REPO_URL/hooks/README.md" -o "$HOOKS_DIR/README.md"
    print_success "Downloaded documentation"
}

update_settings() {
    print_step "Updating Claude settings..."
    
    # Create backup of settings
    cp "$SETTINGS_FILE" "$SETTINGS_FILE.backup-$(date +%Y%m%d-%H%M%S)"
    
    # Check if hooks already exist
    if grep -q '"hooks"' "$SETTINGS_FILE"; then
        print_warning "Hooks section already exists in settings.json"
        print_warning "Please manually merge the configuration or remove existing hooks first."
        print_warning "See: $HOOKS_DIR/README.md for configuration details"
        return
    fi
    
    # Add hooks configuration
    python3 -c "
import json
import sys

try:
    with open('$SETTINGS_FILE', 'r') as f:
        settings = json.load(f)
    
    hooks_config = {
        'PostToolUse': [
            {
                'matcher': 'Write',
                'hooks': [{
                    'type': 'command',
                    'command': '~/.claude/hooks/audio-notify.sh write \"File written\" Write'
                }]
            },
            {
                'matcher': 'Edit',
                'hooks': [{
                    'type': 'command',
                    'command': '~/.claude/hooks/audio-notify.sh edit \"File edited\" Edit'
                }]
            },
            {
                'matcher': 'MultiEdit',
                'hooks': [{
                    'type': 'command',
                    'command': '~/.claude/hooks/audio-notify.sh multiedit \"Multiple edits completed\" MultiEdit'
                }]
            },
            {
                'matcher': 'Bash',
                'hooks': [{
                    'type': 'command',
                    'command': '~/.claude/hooks/audio-notify.sh bash \"Command executed\" Bash'
                }]
            },
            {
                'matcher': 'Read',
                'hooks': [{
                    'type': 'command',
                    'command': '~/.claude/hooks/audio-notify.sh read \"File read\" Read'
                }]
            },
            {
                'matcher': 'Glob',
                'hooks': [{
                    'type': 'command',
                    'command': '~/.claude/hooks/audio-notify.sh glob \"Files searched\" Glob'
                }]
            },
            {
                'matcher': 'Grep',
                'hooks': [{
                    'type': 'command',
                    'command': '~/.claude/hooks/audio-notify.sh grep \"Content searched\" Grep'
                }]
            }
        ],
        'PreToolUse': [
            {
                'matcher': 'Bash',
                'hooks': [{
                    'type': 'command',
                    'command': '~/.claude/hooks/audio-notify.sh alert \"Running command\" Bash'
                }]
            }
        ],
        'Stop': [
            {
                'hooks': [{
                    'type': 'command',
                    'command': '~/.claude/hooks/audio-notify.sh awaiting \"Awaiting input\" Stop'
                }]
            }
        ]
    }
    
    settings['hooks'] = hooks_config
    
    with open('$SETTINGS_FILE', 'w') as f:
        json.dump(settings, f, indent=2)
    
    print('Settings updated successfully')
except Exception as e:
    print(f'Error updating settings: {e}', file=sys.stderr)
    sys.exit(1)
" && print_success "Claude settings updated with hooks configuration" || {
        print_error "Failed to update settings automatically"
        print_warning "Please manually add hooks configuration. See README.md for details."
    }
}

test_installation() {
    print_step "Testing installation..."
    
    if [ -f "$HOOKS_DIR/audio-notify.sh" ] && [ -x "$HOOKS_DIR/audio-notify.sh" ]; then
        # Test script execution
        if "$HOOKS_DIR/audio-notify.sh" completed "Installation test" >/dev/null 2>&1; then
            print_success "Hook script is executable and working"
        else
            print_warning "Hook script may have issues. Check permissions and configuration."
        fi
    else
        print_error "Hook script not found or not executable"
    fi
    
    # Test audio
    if command -v afplay >/dev/null 2>&1; then
        print_success "Audio notifications ready"
    fi
    
    # Test TTS
    if command -v say >/dev/null 2>&1; then
        print_success "Text-to-speech ready"
    fi
}

show_completion_message() {
    echo
    echo -e "${GREEN}🎉 Installation completed successfully!${NC}"
    echo
    echo -e "${BLUE}📁 Files installed:${NC}"
    echo "   ~/.claude/hooks/audio-notify.sh"
    echo "   ~/.claude/hooks/sounds.conf"
    echo "   ~/.claude/hooks/README.md"
    echo
    echo -e "${BLUE}🔧 Configuration:${NC}"
    echo "   Edit ~/.claude/hooks/sounds.conf to customize settings"
    echo
    echo -e "${BLUE}🧪 Test your setup:${NC}"
    echo "   ~/.claude/hooks/audio-notify.sh write \"Test notification\""
    echo
    echo -e "${BLUE}📚 Documentation:${NC}"
    echo "   ~/.claude/hooks/README.md"
    echo
    echo -e "${BLUE}🎛️ Quick configs:${NC}"
    echo "   Enable TTS:  echo 'CLAUDE_ENABLE_TTS=true' >> ~/.claude/hooks/sounds.conf"
    echo "   Set voice:   echo 'CLAUDE_TTS_VOICE=Samantha' >> ~/.claude/hooks/sounds.conf"
    echo "   Quiet hours: echo 'CLAUDE_QUIET_HOURS=true' >> ~/.claude/hooks/sounds.conf"
    echo
    if [ -d "$BACKUP_DIR" ]; then
        echo -e "${YELLOW}💾 Backup created: $BACKUP_DIR${NC}"
    fi
    echo
    echo -e "${GREEN}Ready to receive notifications from Claude Code! 🔊${NC}"
}

main() {
    echo -e "${BLUE}Claude Code Notification Hooks Installer${NC}"
    echo -e "${BLUE}==========================================${NC}"
    echo
    
    check_requirements
    check_claude_directory
    backup_existing
    create_hooks_directory
    download_files
    update_settings
    test_installation
    show_completion_message
}

# Handle interruption
trap 'echo -e "\n${RED}Installation interrupted.${NC}"; exit 1' INT TERM

# Run main function
main "$@"