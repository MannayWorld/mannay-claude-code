#!/usr/bin/env bash
# Safety Net Utilities - JSON parsing, logging, and common functions
# Part of mannay-claude-code plugin

set -euo pipefail

# Colors for output (used in logging)
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Global variables for block reason
BLOCK_REASON=""
BLOCKED=false

# Extract command from Claude Code JSON input
# Uses jq if available, falls back to grep/sed
extract_command() {
  local input="$1"

  if command -v jq >/dev/null 2>&1; then
    echo "$input" | jq -r '.tool_input.command // .command // empty' 2>/dev/null || echo ""
  else
    # Fallback: regex extraction (handles basic cases)
    # Look for "command": "..." pattern
    echo "$input" | sed -n 's/.*"command"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' | head -1
  fi
}

# Unwrap bash -c / sh -c wrappers up to 5 levels deep
unwrap_command() {
  local cmd="$1"
  local depth=0
  local max_depth=5

  while [ $depth -lt $max_depth ]; do
    # Match: bash -c "..." or sh -c '...' or bash -c $'...'
    if [[ "$cmd" =~ ^[[:space:]]*(bash|sh|zsh)[[:space:]]+-c[[:space:]]+[\"\'\$]+(.*)[\"\']?[[:space:]]*$ ]]; then
      cmd="${BASH_REMATCH[2]}"
      # Remove trailing quote if present
      cmd="${cmd%\"}"
      cmd="${cmd%\'}"
      ((depth++))
    else
      break
    fi
  done

  echo "$cmd"
}

# Strip common wrapper commands (sudo, env, command, etc.)
strip_wrappers() {
  local cmd="$1"

  # Remove leading whitespace
  cmd="${cmd#"${cmd%%[![:space:]]*}"}"

  # Strip common wrappers (can be chained)
  local prev_cmd=""
  while [ "$cmd" != "$prev_cmd" ]; do
    prev_cmd="$cmd"
    cmd="${cmd#sudo }"
    cmd="${cmd#env }"
    cmd="${cmd#command }"
    cmd="${cmd#time }"
    cmd="${cmd#nice }"
    cmd="${cmd#nohup }"
    cmd="${cmd#timeout* }"
  done

  echo "$cmd"
}

# Split command on shell operators (&&, ||, |, ;)
# Returns commands one per line
split_commands() {
  local cmd="$1"
  local result=""
  local in_quote=false
  local quote_char=""
  local current=""
  local i=0
  local len=${#cmd}

  while [ $i -lt $len ]; do
    local char="${cmd:$i:1}"
    local next_char="${cmd:$((i+1)):1}"

    # Handle quotes
    if [ "$in_quote" = false ] && [[ "$char" == '"' || "$char" == "'" ]]; then
      in_quote=true
      quote_char="$char"
      current+="$char"
    elif [ "$in_quote" = true ] && [ "$char" == "$quote_char" ]; then
      in_quote=false
      quote_char=""
      current+="$char"
    elif [ "$in_quote" = false ]; then
      # Check for operators
      if [ "$char" = ";" ]; then
        [ -n "$current" ] && echo "$current"
        current=""
      elif [ "$char" = "&" ] && [ "$next_char" = "&" ]; then
        [ -n "$current" ] && echo "$current"
        current=""
        ((i++))
      elif [ "$char" = "|" ] && [ "$next_char" = "|" ]; then
        [ -n "$current" ] && echo "$current"
        current=""
        ((i++))
      elif [ "$char" = "|" ]; then
        [ -n "$current" ] && echo "$current"
        current=""
      else
        current+="$char"
      fi
    else
      current+="$char"
    fi

    ((i++))
  done

  # Output last command
  [ -n "$current" ] && echo "$current"
}

# Set block reason and flag
block() {
  local reason="$1"
  BLOCK_REASON="$reason"
  BLOCKED=true
}

# Reset block state
reset_block() {
  BLOCK_REASON=""
  BLOCKED=false
}

# Check if command is blocked
is_blocked() {
  [ "$BLOCKED" = true ]
}

# Get block reason
get_block_reason() {
  echo "$BLOCK_REASON"
}

# Log blocked command
log_blocked() {
  local cmd="$1"
  local reason="$2"
  local log_file="${SAFETY_NET_LOG_FILE:-.safety-net.log}"

  # Only log if logging is enabled
  if [[ "${SAFETY_NET_LOG:-1}" == "1" ]]; then
    {
      printf "[%s] BLOCKED\n" "$(date -Iseconds 2>/dev/null || date '+%Y-%m-%dT%H:%M:%S')"
      printf "  Command: %s\n" "$cmd"
      printf "  Reason: %s\n" "$reason"
      printf "  CWD: %s\n" "$(pwd)"
      printf "\n"
    } >> "$log_file" 2>/dev/null || true
  fi
}

# Output allow response in Claude Code format
output_allow() {
  cat <<'EOF'
{
  "hookSpecificOutput": {
    "hookEventName": "PreToolUse",
    "permissionDecision": "allow"
  }
}
EOF
}

# Output deny response in Claude Code format
output_deny() {
  local reason="$1"
  # Escape special characters for JSON
  reason="${reason//\\/\\\\}"
  reason="${reason//\"/\\\"}"
  reason="${reason//$'\n'/\\n}"
  reason="${reason//$'\r'/\\r}"
  reason="${reason//$'\t'/\\t}"

  cat <<EOF
{
  "hookSpecificOutput": {
    "hookEventName": "PreToolUse",
    "permissionDecision": "deny",
    "permissionDecisionReason": "$reason"
  }
}
EOF
}

# Check if safety net is enabled
is_safety_net_enabled() {
  [[ "${SAFETY_NET_ENABLED:-1}" == "1" ]]
}

# Check if strict mode is enabled (fail-closed on errors)
is_strict_mode() {
  [[ "${SAFETY_NET_STRICT:-0}" == "1" ]]
}

# Check if paranoid mode is enabled (extra strict checking)
is_paranoid_mode() {
  [[ "${SAFETY_NET_PARANOID:-0}" == "1" ]]
}
