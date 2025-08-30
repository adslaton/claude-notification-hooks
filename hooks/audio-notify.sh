#!/bin/bash

# Audio notification script for Claude Code hooks
# Usage: audio-notify.sh <event_type> [message] [tool_name] [file_path] [command]

EVENT_TYPE="${1:-default}"
MESSAGE="${2:-Claude notification}"
TOOL_NAME="${3:-}"
FILE_PATH="${4:-}"
COMMAND_DETAIL="${5:-}"

# Configuration
SCRIPT_DIR="$(dirname "$0")"
CONFIG_FILE="$SCRIPT_DIR/sounds.conf"
LOG_FILE="$SCRIPT_DIR/notifications.log"

# Default sound mappings (using macOS system sounds)
# Function to get sound for event type
get_sound() {
  case "$1" in
    completed|write|edit|multiedit)
      echo "/System/Library/Sounds/Glass.aiff"
      ;;
    read)
      echo "/System/Library/Sounds/Tink.aiff"
      ;;
    glob|grep)
      echo "/System/Library/Sounds/Morse.aiff"
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

# Helper functions for contextual information
get_filename() {
  local filepath="$1"
  if [ -n "$filepath" ]; then
    basename "$filepath"
  fi
}

get_short_command() {
  local cmd="$1"
  if [ -n "$cmd" ]; then
    # Extract just the command name (first word)
    echo "$cmd" | awk '{print $1}'
  fi
}

clean_filename_for_speech() {
  local filename="$1"
  # Remove file extensions and make speech-friendly
  echo "$filename" | sed 's/\.[^.]*$//' | sed 's/[-_]/ /g'
}

# Load custom sound configuration if it exists
if [ -f "$CONFIG_FILE" ]; then
  source "$CONFIG_FILE"
fi

# Check for quiet hours (22:00 - 08:00)
HOUR=$(date +%H)
if [ "$CLAUDE_QUIET_HOURS" = "true" ] && ([ $HOUR -ge 22 ] || [ $HOUR -lt 8 ]); then
  exit 0
fi

# Get sound for event type
SOUND_FILE="$(get_sound "$EVENT_TYPE")"

# Play sound if enabled and file exists
if [ "$CLAUDE_DISABLE_SOUNDS" != "true" ] && command -v afplay >/dev/null 2>&1 && [ -f "$SOUND_FILE" ]; then
  # Use volume setting if configured
  VOLUME_ARG=""
  if [ -n "$CLAUDE_NOTIFICATION_VOLUME" ]; then
    VOLUME_ARG="-v $CLAUDE_NOTIFICATION_VOLUME"
  fi
  
  afplay $VOLUME_ARG "$SOUND_FILE" &
fi

# Function to get TTS message for event type
get_tts_message() {
  local event_type="$1"
  local message="$2"
  local tool_name="$3"
  local file_path="$4"
  local command_detail="$5"
  
  # Get contextual information
  local filename=$(get_filename "$file_path")
  local clean_filename=$(clean_filename_for_speech "$filename")
  local short_command=$(get_short_command "$command_detail")
  
  case "$event_type" in
    completed|write)
      if [ -n "$clean_filename" ]; then
        echo "Claude created file $clean_filename"
      else
        echo "Claude has created a new file"
      fi
      ;;
    edit)
      if [ -n "$clean_filename" ]; then
        echo "Claude modified file $clean_filename"
      else
        echo "Claude has modified an existing file"
      fi
      ;;
    multiedit)
      echo "Claude has completed multiple file edits"
      ;;
    bash)
      if [ -n "$short_command" ]; then
        echo "Claude finished running $short_command"
      else
        echo "Claude has finished executing a command"
      fi
      ;;
    alert)
      if [ -n "$short_command" ]; then
        echo "Claude is about to run $short_command"
      else
        echo "Claude is about to run a command"
      fi
      ;;
    read)
      if [ -n "$clean_filename" ]; then
        echo "Claude is reading file $clean_filename"
      else
        echo "Claude is reading a file"
      fi
      ;;
    glob)
      echo "Claude is searching for files"
      ;;
    grep)
      if [ -n "$clean_filename" ]; then
        echo "Claude is searching in file $clean_filename"
      else
        echo "Claude is searching file contents"
      fi
      ;;
    error)
      if [ -n "$short_command" ]; then
        echo "Claude encountered an error with $short_command"
      elif [ -n "$clean_filename" ]; then
        echo "Claude encountered an error with file $clean_filename"
      else
        echo "Claude encountered an error"
      fi
      ;;
    notification)
      # Use the provided message for general notifications
      echo "Claude says: $message"
      ;;
    *)
      echo "Claude performed an action"
      ;;
  esac
}

# Text-to-speech notification
if [ "$CLAUDE_ENABLE_TTS" = "true" ] && command -v say >/dev/null 2>&1; then
  TTS_MESSAGE="$(get_tts_message "$EVENT_TYPE" "$MESSAGE" "$TOOL_NAME" "$FILE_PATH" "$COMMAND_DETAIL")"
  
  # Use custom voice if configured
  VOICE_ARG=""
  if [ -n "$CLAUDE_TTS_VOICE" ]; then
    VOICE_ARG="-v $CLAUDE_TTS_VOICE"
  fi
  
  # Use custom rate if configured
  RATE_ARG=""
  if [ -n "$CLAUDE_TTS_RATE" ]; then
    RATE_ARG="-r $CLAUDE_TTS_RATE"
  fi
  
  # Speak the message in background
  say $VOICE_ARG $RATE_ARG "$TTS_MESSAGE" &
fi

# Log the event if logging is enabled
if [ "$CLAUDE_LOG_NOTIFICATIONS" != "false" ]; then
  TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')
  TOOL_INFO=""
  if [ -n "$TOOL_NAME" ]; then
    TOOL_INFO=" [$TOOL_NAME]"
  fi
  echo "[$TIMESTAMP] $EVENT_TYPE$TOOL_INFO: $MESSAGE" >> "$LOG_FILE"
fi

exit 0