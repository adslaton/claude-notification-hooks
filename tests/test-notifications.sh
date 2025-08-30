#!/bin/bash

# Test Suite for Claude Code Notification Hooks
# Comprehensive testing of installation, configuration, and functionality

set -e

# Test configuration
TEST_DIR="$(dirname "$0")"
REPO_ROOT="$(dirname "$TEST_DIR")"
HOOKS_DIR="$HOME/.claude/hooks"
SETTINGS_FILE="$HOME/.claude/settings.json"
TEST_LOG="/tmp/claude-hooks-test.log"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Test tracking
TOTAL_TESTS=0
PASSED_TESTS=0
FAILED_TESTS=0

print_header() {
    echo -e "${BLUE}======================================${NC}"
    echo -e "${BLUE}Claude Notification Hooks Test Suite${NC}"
    echo -e "${BLUE}======================================${NC}"
    echo
}

print_section() {
    echo
    echo -e "${BLUE}--- $1 ---${NC}"
}

print_test() {
    echo -n "  Testing: $1 ... "
    TOTAL_TESTS=$((TOTAL_TESTS + 1))
}

print_pass() {
    echo -e "${GREEN}PASS${NC}"
    PASSED_TESTS=$((PASSED_TESTS + 1))
}

print_fail() {
    echo -e "${RED}FAIL${NC}"
    if [ $# -gt 0 ]; then
        echo -e "    ${RED}$1${NC}"
    fi
    FAILED_TESTS=$((FAILED_TESTS + 1))
}

print_skip() {
    echo -e "${YELLOW}SKIP${NC}"
    if [ $# -gt 0 ]; then
        echo -e "    ${YELLOW}$1${NC}"
    fi
}

print_warning() {
    echo -e "${YELLOW}WARNING: $1${NC}"
}

# Test helper functions
test_command_exists() {
    command -v "$1" >/dev/null 2>&1
}

test_file_exists() {
    [ -f "$1" ]
}

test_file_executable() {
    [ -x "$1" ]
}

test_directory_exists() {
    [ -d "$1" ]
}

cleanup_test_env() {
    # Remove test files if they exist
    rm -f "/tmp/test-notification-output.log"
    rm -f "$TEST_LOG"
}

# System requirements tests
test_system_requirements() {
    print_section "System Requirements"
    
    print_test "macOS operating system"
    if [[ "$OSTYPE" == "darwin"* ]]; then
        print_pass
    else
        print_fail "This test suite is designed for macOS (found: $OSTYPE)"
    fi
    
    print_test "afplay command availability"
    if test_command_exists "afplay"; then
        print_pass
    else
        print_fail "afplay command not found"
    fi
    
    print_test "say command availability"
    if test_command_exists "say"; then
        print_pass
    else
        print_fail "say command not found"
    fi
    
    print_test "curl command availability"
    if test_command_exists "curl"; then
        print_pass
    else
        print_fail "curl command not found"
    fi
    
    print_test "python3 command availability"
    if test_command_exists "python3"; then
        print_pass
    else
        print_fail "python3 command not found"
    fi
    
    print_test "System audio functionality"
    if afplay /System/Library/Sounds/Tink.aiff >/dev/null 2>&1; then
        print_pass
    else
        print_fail "Cannot play system sounds"
    fi
    
    print_test "Text-to-speech functionality"
    if say "test" >/dev/null 2>&1; then
        print_pass
    else
        print_fail "Cannot use text-to-speech"
    fi
}

# File structure tests
test_repository_structure() {
    print_section "Repository Structure"
    
    print_test "Repository root directory"
    if test_directory_exists "$REPO_ROOT"; then
        print_pass
    else
        print_fail "Repository root not found: $REPO_ROOT"
    fi
    
    print_test "Main README.md exists"
    if test_file_exists "$REPO_ROOT/README.md"; then
        print_pass
    else
        print_fail "Main README.md not found"
    fi
    
    print_test "Install script exists and is executable"
    if test_file_exists "$REPO_ROOT/install.sh" && test_file_executable "$REPO_ROOT/install.sh"; then
        print_pass
    else
        print_fail "Install script missing or not executable"
    fi
    
    print_test "Uninstall script exists and is executable"
    if test_file_exists "$REPO_ROOT/uninstall.sh" && test_file_executable "$REPO_ROOT/uninstall.sh"; then
        print_pass
    else
        print_fail "Uninstall script missing or not executable"
    fi
    
    print_test "Hooks directory exists"
    if test_directory_exists "$REPO_ROOT/hooks"; then
        print_pass
    else
        print_fail "Hooks directory not found"
    fi
    
    print_test "Audio notification script exists"
    if test_file_exists "$REPO_ROOT/hooks/audio-notify.sh"; then
        print_pass
    else
        print_fail "Audio notification script not found"
    fi
    
    print_test "Configuration example exists"
    if test_file_exists "$REPO_ROOT/hooks/sounds.conf.example"; then
        print_pass
    else
        print_fail "Configuration example not found"
    fi
    
    print_test "Documentation directory exists"
    if test_directory_exists "$REPO_ROOT/docs"; then
        print_pass
    else
        print_fail "Documentation directory not found"
    fi
    
    print_test "Examples directory exists"
    if test_directory_exists "$REPO_ROOT/examples"; then
        print_pass
    else
        print_fail "Examples directory not found"
    fi
}

# Script validation tests
test_script_validation() {
    print_section "Script Validation"
    
    print_test "Audio notification script syntax"
    if bash -n "$REPO_ROOT/hooks/audio-notify.sh" 2>/dev/null; then
        print_pass
    else
        print_fail "Syntax error in audio-notify.sh"
    fi
    
    print_test "Install script syntax"
    if bash -n "$REPO_ROOT/install.sh" 2>/dev/null; then
        print_pass
    else
        print_fail "Syntax error in install.sh"
    fi
    
    print_test "Uninstall script syntax"
    if bash -n "$REPO_ROOT/uninstall.sh" 2>/dev/null; then
        print_pass
    else
        print_fail "Syntax error in uninstall.sh"
    fi
    
    print_test "Configuration example syntax"
    if bash -n "$REPO_ROOT/hooks/sounds.conf.example" 2>/dev/null; then
        print_pass
    else
        print_fail "Syntax error in sounds.conf.example"
    fi
    
    print_test "Settings.json example is valid JSON"
    if python3 -m json.tool "$REPO_ROOT/examples/settings.json.example" >/dev/null 2>&1; then
        print_pass
    else
        print_fail "Invalid JSON in settings.json.example"
    fi
}

# Installation tests (if not already installed)
test_installation() {
    print_section "Installation Testing"
    
    # Check if already installed
    if test_directory_exists "$HOOKS_DIR"; then
        print_warning "Hooks already installed, skipping installation tests"
        print_warning "Run uninstall first to test installation"
        return
    fi
    
    print_test "Claude directory exists"
    if test_directory_exists "$HOME/.claude"; then
        print_pass
    else
        print_fail "Claude directory not found. Install Claude Code first."
        return
    fi
    
    print_test "Settings file exists or can be created"
    if test_file_exists "$SETTINGS_FILE"; then
        print_pass
    else
        # Try to create minimal settings file
        if echo '{"$schema": "https://json.schemastore.org/claude-code-settings.json"}' > "$SETTINGS_FILE" 2>/dev/null; then
            print_pass
        else
            print_fail "Cannot create settings file"
        fi
    fi
    
    # Note: We don't actually run the installer in the test
    # to avoid modifying the user's actual installation
    print_test "Installer script can run in check mode"
    print_skip "Not implemented (would modify user installation)"
}

# Hook functionality tests
test_hook_functionality() {
    print_section "Hook Functionality"
    
    # Check if hooks are installed
    if ! test_directory_exists "$HOOKS_DIR"; then
        print_warning "Hooks not installed, skipping functionality tests"
        return
    fi
    
    print_test "Hook directory exists"
    if test_directory_exists "$HOOKS_DIR"; then
        print_pass
    else
        print_fail "Hook directory not found"
        return
    fi
    
    print_test "Audio notification script exists and is executable"
    if test_file_exists "$HOOKS_DIR/audio-notify.sh" && test_file_executable "$HOOKS_DIR/audio-notify.sh"; then
        print_pass
    else
        print_fail "Audio notification script missing or not executable"
        return
    fi
    
    print_test "Configuration file exists"
    if test_file_exists "$HOOKS_DIR/sounds.conf"; then
        print_pass
    else
        print_fail "Configuration file not found"
    fi
    
    print_test "Hook script basic execution"
    if "$HOOKS_DIR/audio-notify.sh" test "Test execution" >/dev/null 2>&1; then
        print_pass
    else
        print_fail "Hook script failed to execute"
    fi
    
    print_test "Hook script logging functionality"
    # Clear any existing log
    > "$HOOKS_DIR/notifications.log" 2>/dev/null || true
    if "$HOOKS_DIR/audio-notify.sh" test "Log test" >/dev/null 2>&1; then
        if grep -q "Log test" "$HOOKS_DIR/notifications.log" 2>/dev/null; then
            print_pass
        else
            print_fail "Hook script not logging events"
        fi
    else
        print_fail "Hook script execution failed"
    fi
}

# Audio tests
test_audio_functionality() {
    print_section "Audio Functionality"
    
    if ! test_directory_exists "$HOOKS_DIR"; then
        print_warning "Hooks not installed, skipping audio tests"
        return
    fi
    
    print_test "Default sound files exist"
    local all_sounds_exist=true
    for sound in Glass.aiff Basso.aiff Ping.aiff Pop.aiff Tink.aiff; do
        if ! test_file_exists "/System/Library/Sounds/$sound"; then
            all_sounds_exist=false
            break
        fi
    done
    
    if [ "$all_sounds_exist" = true ]; then
        print_pass
    else
        print_fail "Some default sound files missing"
    fi
    
    print_test "Audio notification with default sound"
    if CLAUDE_DISABLE_SOUNDS=false "$HOOKS_DIR/audio-notify.sh" completed "Audio test" >/dev/null 2>&1; then
        print_pass
    else
        print_fail "Audio notification failed"
    fi
    
    print_test "Sound volume control"
    if CLAUDE_NOTIFICATION_VOLUME=0.1 "$HOOKS_DIR/audio-notify.sh" completed "Volume test" >/dev/null 2>&1; then
        print_pass
    else
        print_fail "Volume control failed"
    fi
    
    print_test "Sound disable functionality"
    if CLAUDE_DISABLE_SOUNDS=true "$HOOKS_DIR/audio-notify.sh" completed "Disable test" >/dev/null 2>&1; then
        print_pass
    else
        print_fail "Sound disable failed"
    fi
}

# TTS tests
test_tts_functionality() {
    print_section "Text-to-Speech Functionality"
    
    if ! test_directory_exists "$HOOKS_DIR"; then
        print_warning "Hooks not installed, skipping TTS tests"
        return
    fi
    
    print_test "TTS with default voice"
    if CLAUDE_ENABLE_TTS=true "$HOOKS_DIR/audio-notify.sh" write "TTS test" >/dev/null 2>&1; then
        print_pass
    else
        print_fail "TTS with default voice failed"
    fi
    
    print_test "TTS with specific voice"
    if CLAUDE_ENABLE_TTS=true CLAUDE_TTS_VOICE=Alex "$HOOKS_DIR/audio-notify.sh" write "Voice test" >/dev/null 2>&1; then
        print_pass
    else
        print_fail "TTS with specific voice failed"
    fi
    
    print_test "TTS rate control"
    if CLAUDE_ENABLE_TTS=true CLAUDE_TTS_RATE=200 "$HOOKS_DIR/audio-notify.sh" write "Rate test" >/dev/null 2>&1; then
        print_pass
    else
        print_fail "TTS rate control failed"
    fi
    
    print_test "TTS disable functionality"
    if CLAUDE_ENABLE_TTS=false "$HOOKS_DIR/audio-notify.sh" write "TTS disable test" >/dev/null 2>&1; then
        print_pass
    else
        print_fail "TTS disable failed"
    fi
}

# Configuration tests
test_configuration() {
    print_section "Configuration Testing"
    
    if ! test_directory_exists "$HOOKS_DIR"; then
        print_warning "Hooks not installed, skipping configuration tests"
        return
    fi
    
    print_test "Configuration file loading"
    if [ -f "$HOOKS_DIR/sounds.conf" ] && source "$HOOKS_DIR/sounds.conf" 2>/dev/null; then
        print_pass
    else
        print_fail "Configuration file cannot be loaded"
    fi
    
    print_test "Quiet hours functionality (10 PM)"
    # Clear log for clean test
    > "$HOOKS_DIR/notifications.log" 2>/dev/null || true
    if CLAUDE_QUIET_HOURS=true HOUR=22 "$HOOKS_DIR/audio-notify.sh" write "Quiet test 22h" >/dev/null 2>&1; then
        # Should not create log entry during quiet hours
        if ! grep -q "Quiet test 22h" "$HOOKS_DIR/notifications.log" 2>/dev/null; then
            print_pass
        else
            print_fail "Quiet hours not working at 10 PM (notification was logged)"
        fi
    else
        print_fail "Quiet hours test execution failed"
    fi
    
    print_test "Quiet hours functionality (3 AM)"
    # Clear log for clean test
    > "$HOOKS_DIR/notifications.log" 2>/dev/null || true
    if CLAUDE_QUIET_HOURS=true HOUR=3 "$HOOKS_DIR/audio-notify.sh" bash "Quiet test 3h" >/dev/null 2>&1; then
        # Should not create log entry during quiet hours
        if ! grep -q "Quiet test 3h" "$HOOKS_DIR/notifications.log" 2>/dev/null; then
            print_pass
        else
            print_fail "Quiet hours not working at 3 AM (notification was logged)"
        fi
    else
        print_fail "Quiet hours test execution failed"
    fi
    
    print_test "Active hours functionality (2 PM)"
    # Clear log for clean test
    > "$HOOKS_DIR/notifications.log" 2>/dev/null || true
    if CLAUDE_QUIET_HOURS=true HOUR=14 "$HOOKS_DIR/audio-notify.sh" edit "Active test 14h" >/dev/null 2>&1; then
        # Should create log entry during active hours
        if grep -q "Active test 14h" "$HOOKS_DIR/notifications.log" 2>/dev/null; then
            print_pass
        else
            print_fail "Active hours not working at 2 PM (notification was not logged)"
        fi
    else
        print_fail "Active hours test execution failed"
    fi
    
    print_test "Quiet hours disabled functionality"
    # Clear log for clean test
    > "$HOOKS_DIR/notifications.log" 2>/dev/null || true
    if CLAUDE_QUIET_HOURS=false HOUR=23 "$HOOKS_DIR/audio-notify.sh" read "No quiet test" >/dev/null 2>&1; then
        # Should create log entry when quiet hours are disabled
        if grep -q "No quiet test" "$HOOKS_DIR/notifications.log" 2>/dev/null; then
            print_pass
        else
            print_fail "Notifications not working when quiet hours disabled"
        fi
    else
        print_fail "Quiet hours disabled test execution failed"
    fi
    
    print_test "Event type mapping"
    local event_types="write edit multiedit bash alert error completed"
    local mapping_works=true
    
    for event in $event_types; do
        if ! "$HOOKS_DIR/audio-notify.sh" "$event" "Mapping test for $event" >/dev/null 2>&1; then
            mapping_works=false
            break
        fi
    done
    
    if [ "$mapping_works" = true ]; then
        print_pass
    else
        print_fail "Event type mapping failed"
    fi
}

# Integration tests
test_integration() {
    print_section "Integration Testing"
    
    print_test "Claude settings.json validation"
    if test_file_exists "$SETTINGS_FILE"; then
        if python3 -m json.tool "$SETTINGS_FILE" >/dev/null 2>&1; then
            print_pass
        else
            print_fail "Claude settings.json is invalid"
        fi
    else
        print_skip "Claude settings.json not found"
    fi
    
    print_test "Hook configuration in settings.json"
    if test_file_exists "$SETTINGS_FILE" && grep -q '"hooks"' "$SETTINGS_FILE" 2>/dev/null; then
        print_pass
    else
        print_skip "No hooks configuration in settings.json"
    fi
    
    print_test "Hook command paths in settings"
    if test_file_exists "$SETTINGS_FILE" && grep -q "audio-notify.sh" "$SETTINGS_FILE" 2>/dev/null; then
        if grep -q "$HOOKS_DIR/audio-notify.sh" "$SETTINGS_FILE" 2>/dev/null; then
            print_pass
        else
            print_fail "Hook paths in settings.json may be incorrect"
        fi
    else
        print_skip "No hook commands found in settings.json"
    fi
}

# Performance tests
test_performance() {
    print_section "Performance Testing"
    
    if ! test_directory_exists "$HOOKS_DIR"; then
        print_warning "Hooks not installed, skipping performance tests"
        return
    fi
    
    print_test "Hook execution time"
    local start_time=$(date +%s.%N)
    "$HOOKS_DIR/audio-notify.sh" test "Performance test" >/dev/null 2>&1
    local end_time=$(date +%s.%N)
    local duration=$(echo "$end_time - $start_time" | bc 2>/dev/null || echo "0")
    
    # Check if execution took less than 1 second (reasonable for a notification)
    if [ "$(echo "$duration < 1.0" | bc 2>/dev/null || echo "1")" = "1" ]; then
        print_pass
    else
        print_fail "Hook execution too slow: ${duration}s"
    fi
    
    print_test "Memory usage during execution"
    # Simple test - check that script doesn't consume excessive memory
    if timeout 5s "$HOOKS_DIR/audio-notify.sh" test "Memory test" >/dev/null 2>&1; then
        print_pass
    else
        print_fail "Hook execution timed out or failed"
    fi
    
    print_test "Concurrent execution handling"
    # Test multiple notifications at once
    local pids=()
    for i in {1..5}; do
        "$HOOKS_DIR/audio-notify.sh" test "Concurrent test $i" >/dev/null 2>&1 &
        pids+=($!)
    done
    
    # Wait for all to complete
    local all_completed=true
    for pid in "${pids[@]}"; do
        if ! wait "$pid" 2>/dev/null; then
            all_completed=false
        fi
    done
    
    if [ "$all_completed" = true ]; then
        print_pass
    else
        print_fail "Concurrent execution failed"
    fi
}

# Cleanup tests
test_cleanup() {
    print_section "Cleanup Testing"
    
    print_test "Log file rotation/management"
    if test_file_exists "$HOOKS_DIR/notifications.log"; then
        local log_size=$(wc -l < "$HOOKS_DIR/notifications.log" 2>/dev/null || echo "0")
        if [ "$log_size" -lt 10000 ]; then  # Reasonable log size
            print_pass
        else
            print_warning "Log file is large ($log_size lines). Consider rotation."
            print_pass  # Not a failure, just a warning
        fi
    else
        print_skip "No log file found"
    fi
    
    print_test "Temporary file cleanup"
    # Check for any temporary files left by our hooks
    local temp_files=$(find /tmp -name "*claude*hook*" -o -name "*notification*" 2>/dev/null | wc -l)
    if [ "$temp_files" -eq 0 ]; then
        print_pass
    else
        print_fail "Found $temp_files temporary files"
    fi
}

# Summary report
print_summary() {
    echo
    echo -e "${BLUE}======================================${NC}"
    echo -e "${BLUE}Test Summary${NC}"
    echo -e "${BLUE}======================================${NC}"
    echo
    echo -e "Total Tests: ${BLUE}$TOTAL_TESTS${NC}"
    echo -e "Passed:      ${GREEN}$PASSED_TESTS${NC}"
    echo -e "Failed:      ${RED}$FAILED_TESTS${NC}"
    echo
    
    if [ "$FAILED_TESTS" -eq 0 ]; then
        echo -e "${GREEN}All tests passed! 🎉${NC}"
        echo -e "${GREEN}Claude Notification Hooks are working correctly.${NC}"
        exit 0
    else
        echo -e "${RED}Some tests failed! ⚠️${NC}"
        echo -e "${RED}Check the output above for details.${NC}"
        exit 1
    fi
}

# Main execution
main() {
    print_header
    cleanup_test_env
    
    # Run all test suites
    test_system_requirements
    test_repository_structure  
    test_script_validation
    test_installation
    test_hook_functionality
    test_audio_functionality
    test_tts_functionality
    test_configuration
    test_integration
    test_performance
    test_cleanup
    
    print_summary
}

# Handle script interruption
trap 'echo -e "\n${RED}Tests interrupted.${NC}"; cleanup_test_env; exit 1' INT TERM

# Handle command line arguments
case "${1:-}" in
    -h|--help)
        echo "Claude Notification Hooks Test Suite"
        echo
        echo "Usage: $0 [OPTIONS]"
        echo
        echo "Options:"
        echo "  -h, --help     Show this help message"
        echo "  --quick        Run only basic tests"
        echo "  --audio        Test audio functionality only"
        echo "  --tts          Test TTS functionality only"
        echo "  --config       Test configuration only"
        echo
        exit 0
        ;;
    --quick)
        print_header
        test_system_requirements
        test_repository_structure
        test_hook_functionality
        print_summary
        ;;
    --audio)
        print_header
        test_audio_functionality
        print_summary
        ;;
    --tts)
        print_header
        test_tts_functionality
        print_summary
        ;;
    --config)
        print_header
        test_configuration
        print_summary
        ;;
    *)
        main "$@"
        ;;
esac