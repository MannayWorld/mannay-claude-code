#!/usr/bin/env bash
# Safety Net - Main Orchestrator
# PreToolUse hook that intercepts Bash commands and checks safety rules
# Part of mannay-claude-code plugin
#
# Usage: Called automatically by Claude Code as a PreToolUse hook
# Input: JSON via stdin containing the command to be executed
# Output: JSON with hookSpecificOutput containing allow/deny decision

set -euo pipefail

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="$SCRIPT_DIR/lib"

# Source rule libraries
source "$LIB_DIR/utils.sh"
source "$LIB_DIR/rules-git.sh"
source "$LIB_DIR/rules-rm.sh"
source "$LIB_DIR/rules-system.sh"
source "$LIB_DIR/rules-custom.sh"

# Main function
main() {
  # Check if safety net is enabled
  if ! is_safety_net_enabled; then
    output_allow
    exit 0
  fi

  # Read JSON input from stdin
  local input=""
  if [ -t 0 ]; then
    # No stdin, nothing to check
    output_allow
    exit 0
  fi

  input=$(cat)

  # Extract command from JSON
  local command
  command=$(extract_command "$input")

  # If no command found, allow (nothing to check)
  if [ -z "$command" ]; then
    if is_strict_mode; then
      output_deny "Could not parse command from input (strict mode)"
      exit 0
    fi
    output_allow
    exit 0
  fi

  # Process the command
  check_command "$command"

  # Output result
  if is_blocked; then
    local reason
    reason=$(get_block_reason)
    log_blocked "$command" "$reason"
    output_deny "$reason"
  else
    output_allow
  fi
}

# Check a command against all rules
check_command() {
  local cmd="$1"

  # Reset block state
  reset_block

  # Unwrap bash -c / sh -c wrappers
  cmd=$(unwrap_command "$cmd")

  # Strip wrapper commands (sudo, env, etc.)
  cmd=$(strip_wrappers "$cmd")

  # Split on shell operators and check each sub-command
  while IFS= read -r sub_cmd; do
    [ -z "$sub_cmd" ] && continue

    # Trim whitespace
    sub_cmd="${sub_cmd#"${sub_cmd%%[![:space:]]*}"}"
    sub_cmd="${sub_cmd%"${sub_cmd##*[![:space:]]}"}"
    [ -z "$sub_cmd" ] && continue

    # Check against all rule sets
    # Order matters: system rules first (catch bypasses), then specific rules

    # 1. System rules (eval, exec, curl|bash, etc.)
    if ! check_system_rules "$sub_cmd"; then
      return 1
    fi

    # 2. Injection patterns
    if ! check_injection_patterns "$sub_cmd"; then
      return 1
    fi

    # 3. Git rules
    if ! check_git_rules "$sub_cmd"; then
      return 1
    fi

    # 4. RM/file deletion rules
    if ! check_rm_rules "$sub_cmd"; then
      return 1
    fi

    # 5. Other file deletion commands
    if ! check_file_deletion_rules "$sub_cmd"; then
      return 1
    fi

    # 6. Custom rules (user-defined)
    if ! check_custom_rules "$sub_cmd"; then
      return 1
    fi

  done < <(split_commands "$cmd")

  return 0
}

# Run main function
main "$@"
