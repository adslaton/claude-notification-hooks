#!/bin/bash

# Claude Code Notification Hooks Uninstaller
# Removes all notification hooks and configurations

set -e

HOOKS_DIR="$HOME/.claude/hooks"
SETTINGS_FILE="$HOME/.claude/settings.json"
BACKUP_DIR="$HOME/.claude/uninstall-backup-$(date +%Y%m%d-%H%M%S)"

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

confirm_uninstall() {
    echo -e "${YELLOW}⚠ This will remove all Claude Code notification hooks.${NC}"
    echo
    echo "Files to be removed:"
    if [ -d "$HOOKS_DIR" ]; then
        echo "  - $HOOKS_DIR/ (entire directory)"
    fi
    if [ -f "$SETTINGS_FILE" ] && grep -q '"hooks"' "$SETTINGS_FILE" 2>/dev/null; then
        echo "  - hooks section from $SETTINGS_FILE"
    fi
    echo
    read -p "Continue with uninstallation? [y/N] " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Uninstallation cancelled."
        exit 0
    fi
}

create_backup() {
    print_step "Creating backup..."
    
    mkdir -p "$BACKUP_DIR"
    
    # Backup hooks directory
    if [ -d "$HOOKS_DIR" ]; then
        cp -r "$HOOKS_DIR" "$BACKUP_DIR/hooks"
        print_success "Backed up hooks directory"
    fi
    
    # Backup settings file
    if [ -f "$SETTINGS_FILE" ]; then
        cp "$SETTINGS_FILE" "$BACKUP_DIR/settings.json"
        print_success "Backed up settings.json"
    fi
    
    print_success "Backup created at $BACKUP_DIR"
}

remove_hooks_directory() {
    print_step "Removing hooks directory..."
    
    if [ -d "$HOOKS_DIR" ]; then
        rm -rf "$HOOKS_DIR"
        print_success "Hooks directory removed"
    else
        print_warning "Hooks directory not found"
    fi
}

remove_settings_configuration() {
    print_step "Removing hooks configuration from settings..."
    
    if [ ! -f "$SETTINGS_FILE" ]; then
        print_warning "Settings file not found"
        return
    fi
    
    if ! grep -q '"hooks"' "$SETTINGS_FILE"; then
        print_warning "No hooks configuration found in settings"
        return
    fi
    
    # Remove hooks configuration using Python
    python3 -c "
import json
import sys

try:
    with open('$SETTINGS_FILE', 'r') as f:
        settings = json.load(f)
    
    if 'hooks' in settings:
        del settings['hooks']
        
        with open('$SETTINGS_FILE', 'w') as f:
            json.dump(settings, f, indent=2)
        
        print('Hooks configuration removed from settings.json')
    else:
        print('No hooks configuration found')
        
except Exception as e:
    print(f'Error updating settings: {e}', file=sys.stderr)
    sys.exit(1)
" && print_success "Hooks configuration removed from settings.json" || {
        print_error "Failed to automatically remove hooks configuration"
        print_warning "Please manually remove the 'hooks' section from $SETTINGS_FILE"
    }
}

cleanup_logs() {
    print_step "Cleaning up notification logs..."
    
    # Remove any notification logs that might be in other locations
    find "$HOME/.claude" -name "notifications.log" -type f -delete 2>/dev/null || true
    print_success "Notification logs cleaned up"
}

verify_removal() {
    print_step "Verifying removal..."
    
    local issues=0
    
    if [ -d "$HOOKS_DIR" ]; then
        print_error "Hooks directory still exists"
        issues=$((issues + 1))
    else
        print_success "Hooks directory removed"
    fi
    
    if [ -f "$SETTINGS_FILE" ] && grep -q '"hooks"' "$SETTINGS_FILE" 2>/dev/null; then
        print_error "Hooks configuration still exists in settings"
        issues=$((issues + 1))
    else
        print_success "Hooks configuration removed from settings"
    fi
    
    if [ $issues -gt 0 ]; then
        print_warning "Some components may not have been fully removed"
        print_warning "Check the backup at $BACKUP_DIR for manual cleanup"
    else
        print_success "All components successfully removed"
    fi
}

show_completion_message() {
    echo
    echo -e "${GREEN}🗑️  Uninstallation completed!${NC}"
    echo
    echo -e "${BLUE}📁 Backup created:${NC}"
    echo "   $BACKUP_DIR"
    echo
    echo -e "${BLUE}🔧 What was removed:${NC}"
    echo "   ✓ ~/.claude/hooks/ directory"
    echo "   ✓ Hooks configuration from settings.json"
    echo "   ✓ Notification logs"
    echo
    echo -e "${BLUE}📋 Manual steps (if needed):${NC}"
    echo "   - Review settings.json for any remaining hook references"
    echo "   - Clear any custom CLAUDE.md references to the notification system"
    echo
    echo -e "${BLUE}🔄 To reinstall later:${NC}"
    echo '   curl -sSL https://raw.githubusercontent.com/[username]/claude-notification-hooks/main/install.sh | bash'
    echo
    echo -e "${GREEN}Claude Code notifications have been disabled. 🔇${NC}"
}

show_help() {
    echo "Claude Code Notification Hooks Uninstaller"
    echo
    echo "Usage: $0 [OPTIONS]"
    echo
    echo "Options:"
    echo "  -h, --help     Show this help message"
    echo "  -y, --yes      Skip confirmation prompt"
    echo "  --keep-backup  Don't remove backup after successful uninstall"
    echo
    echo "Examples:"
    echo "  $0              # Interactive uninstall"
    echo "  $0 -y           # Uninstall without confirmation"
    echo "  $0 --help       # Show this help"
}

main() {
    local skip_confirm=false
    local keep_backup=false
    
    # Parse command line arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                show_help
                exit 0
                ;;
            -y|--yes)
                skip_confirm=true
                shift
                ;;
            --keep-backup)
                keep_backup=true
                shift
                ;;
            *)
                print_error "Unknown option: $1"
                echo "Use --help for usage information"
                exit 1
                ;;
        esac
    done
    
    echo -e "${BLUE}Claude Code Notification Hooks Uninstaller${NC}"
    echo -e "${BLUE}===========================================${NC}"
    echo
    
    if [ "$skip_confirm" = false ]; then
        confirm_uninstall
    fi
    
    create_backup
    remove_hooks_directory
    remove_settings_configuration
    cleanup_logs
    verify_removal
    show_completion_message
    
    if [ "$keep_backup" = false ]; then
        echo -e "${YELLOW}💡 Tip: You can safely remove the backup directory when you're sure everything is working correctly.${NC}"
    fi
}

# Handle interruption
trap 'echo -e "\n${RED}Uninstallation interrupted.${NC}"; exit 1' INT TERM

# Run main function
main "$@"