# Claude Code Hook Limitations and Capabilities

## Overview

This document details what information Claude Code hooks can and cannot access, based on testing and documentation research. Understanding these limitations is important for setting realistic expectations about notification functionality.

## ✅ What Hooks CAN Access

### Basic Event Information
- **`tool_name`**: The name of the tool being used (Write, Edit, Bash, Read, Glob, Grep, etc.)
- **`hook_event_name`**: The type of hook event (PreToolUse, PostToolUse, Notification, etc.)
- **`session_id`**: Unique identifier for the Claude session
- **`transcript_path`**: Path to the conversation JSON file
- **`cwd`**: Current working directory when the hook is triggered

### Environment Variables
- **`$CLAUDE_PROJECT_DIR`**: Absolute path to the project root directory
- **Standard shell environment**: All normal environment variables available to shell scripts

### JSON Input via stdin
For more advanced hook implementations, Claude provides JSON data via stdin containing:
- Session metadata
- Tool names and basic context  
- Sometimes `tool_input` and `tool_response` (depending on hook type)
- Hook timing information

### Hook Timing
- **PreToolUse**: Hooks can run before tools execute
- **PostToolUse**: Hooks can run after tools complete successfully
- **Error conditions**: Some hook events for failed operations

## ❌ What Hooks CANNOT Access

### Specific Command Details
- **Actual bash commands**: Cannot access the specific command being run (e.g., `ls -la`, `npm install`, `git status`)
- **Command parameters**: No access to flags, arguments, or options passed to commands
- **Command output**: Cannot see the results or output of executed commands

### File-Specific Information
- **Exact file paths**: Cannot determine which specific files are being read, written, or edited
- **File names**: No access to the names of files being operated on
- **File contents**: Cannot see what's being written or read from files
- **Multiple file details**: For MultiEdit operations, cannot see which files are affected

### Tool-Specific Parameters
- **Grep patterns**: Cannot see what text is being searched for
- **Glob patterns**: Cannot see what file patterns are being matched
- **Search contexts**: Cannot access search results or match details
- **Edit details**: Cannot see what changes are being made to files

### Advanced Context
- **User intent**: Cannot determine why an operation is being performed
- **Relationship between operations**: Cannot see how operations are related
- **Success/failure details**: Limited information about why operations failed

## 🔍 Testing Results

### Attempted Variables (NOT Available)
- `$CLAUDE_COMMAND` - Not populated
- `$CLAUDE_FILE_PATH` - Not populated
- `$CLAUDE_TOOL_ARGS` - Not available
- `$CLAUDE_FILE_NAME` - Not available

### Working Hook Types
- ✅ **Tool Detection**: Can identify which tool is being used
- ✅ **Timing**: Can differentiate between pre/post execution
- ✅ **Basic Notifications**: Can trigger on tool usage
- ✅ **Environment Access**: Can access project directory and shell environment

## 💡 Practical Implications

### What Notifications Can Say
**Generic but Useful:**
- ✅ "Claude is about to run a command"
- ✅ "Claude finished executing a command"
- ✅ "Claude is reading a file"
- ✅ "Claude has modified an existing file"
- ✅ "Claude is searching for files"
- ✅ "Claude is searching file contents"

### What Notifications CANNOT Say
**Specific Details (Not Possible):**
- ❌ "Claude is running `npm install`"
- ❌ "Claude is editing `package.json`"
- ❌ "Claude is searching for `*.js` files"
- ❌ "Claude is looking for `TODO` in the codebase"

## 🛡️ Security Implications

### Why Limitations Exist
These limitations are **intentional security features**:

1. **Privacy Protection**: Prevents hooks from accessing potentially sensitive file contents or paths
2. **Command Safety**: Prevents hooks from intercepting or logging sensitive commands
3. **Isolation**: Ensures hooks can't interfere with or spy on Claude's operations
4. **Minimal Surface**: Reduces the attack surface for malicious hook scripts

### Best Practices
- **Design for generic notifications**: Build hooks that work with limited information
- **Focus on event types**: Use tool names and timing for meaningful feedback
- **Respect privacy**: Don't attempt to circumvent limitations to access restricted information
- **Graceful degradation**: Ensure hooks work even when expected information is unavailable

## 🔧 Implementation Guidelines

### Robust Hook Design
```bash
# Good: Works with available information
case "$EVENT_TYPE" in
  write)
    echo "Claude created a new file"
    ;;
  bash)
    echo "Claude executed a command"
    ;;
esac

# Bad: Relies on unavailable information
case "$EVENT_TYPE" in
  write)
    echo "Claude created file $FILENAME"  # $FILENAME not available
    ;;
  bash)
    echo "Claude ran $COMMAND"  # $COMMAND not available
    ;;
esac
```

### Fallback Strategies
```bash
# Always provide fallback messages
if [ -n "$FILENAME" ]; then
  echo "Claude created file $FILENAME"
else
  echo "Claude created a new file"  # Fallback
fi
```

## 📋 Recommendations

### For Users
1. **Set realistic expectations**: Understand that notifications will be generic
2. **Focus on awareness**: Use notifications to know when Claude is active, not what specifically it's doing
3. **Customize generic messages**: Tailor the generic messages to your preferences

### for Developers
1. **Build robust scripts**: Always handle missing information gracefully
2. **Test thoroughly**: Verify hooks work in all scenarios, including when data is unavailable
3. **Document limitations**: Clearly communicate what hooks can and cannot do
4. **Focus on reliability**: Prefer simple, working notifications over complex, fragile ones

## 🔄 Future Possibilities

### Potential Improvements
While current limitations are security-focused, future Claude Code versions might:
- Provide opt-in access to more detailed information
- Offer sanitized versions of sensitive data
- Allow user configuration of information sharing levels
- Introduce new hook types with different access levels

### Current Status
As of the current Claude Code version, these limitations are **permanent design decisions** and should be considered when building hook-based systems.

## 📚 Related Documentation

- [Claude Code Hooks Documentation](https://docs.anthropic.com/en/docs/claude-code/hooks)
- [Configuration Guide](CONFIGURATION.md) - Working within these limitations
- [Troubleshooting Guide](TROUBLESHOOTING.md) - Common issues related to missing information