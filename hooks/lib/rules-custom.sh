#!/usr/bin/env bash
# Safety Net - Custom Rules Loader
# Loads and applies user-defined rules from .safety-net.json
# Part of mannay-claude-code plugin

# Default config locations
PROJECT_CONFIG=".safety-net.json"
GLOBAL_CONFIG="$HOME/.claude/safety-net.json"

# Cache for loaded rules (to avoid re-parsing JSON on every command)
CUSTOM_RULES_LOADED=false
CUSTOM_RULES_ENABLED=true
CUSTOM_RULES=()
CUSTOM_ALLOWLIST=()

# Load custom rules from config files
load_custom_rules() {
  if [ "$CUSTOM_RULES_LOADED" = true ]; then
    return 0
  fi

  CUSTOM_RULES_LOADED=true

  # Check if jq is available (required for JSON parsing)
  if ! command -v jq >/dev/null 2>&1; then
    # No jq, can't load custom rules
    return 0
  fi

  # Load global config first
  if [ -f "$GLOBAL_CONFIG" ]; then
    load_config_file "$GLOBAL_CONFIG"
  fi

  # Load project config (overrides global)
  if [ -f "$PROJECT_CONFIG" ]; then
    load_config_file "$PROJECT_CONFIG"
  fi
}

# Load rules from a specific config file
load_config_file() {
  local config_file="$1"

  # Check if enabled
  local enabled
  enabled=$(jq -r '.enabled // true' "$config_file" 2>/dev/null)
  if [ "$enabled" = "false" ]; then
    CUSTOM_RULES_ENABLED=false
    return 0
  fi

  # Load allowlist
  local allowlist_json
  allowlist_json=$(jq -r '.allowlist // [] | .[]' "$config_file" 2>/dev/null)
  while IFS= read -r pattern; do
    [ -n "$pattern" ] && CUSTOM_ALLOWLIST+=("$pattern")
  done <<< "$allowlist_json"

  # Load custom rules
  local rules_count
  rules_count=$(jq -r '.rules | length // 0' "$config_file" 2>/dev/null)

  for ((i=0; i<rules_count; i++)); do
    local rule_name rule_pattern rule_command rule_subcommand rule_action rule_reason
    rule_name=$(jq -r ".rules[$i].name // \"\"" "$config_file" 2>/dev/null)
    rule_pattern=$(jq -r ".rules[$i].pattern // \"\"" "$config_file" 2>/dev/null)
    rule_command=$(jq -r ".rules[$i].command // \"\"" "$config_file" 2>/dev/null)
    rule_subcommand=$(jq -r ".rules[$i].subcommand // \"\"" "$config_file" 2>/dev/null)
    rule_action=$(jq -r ".rules[$i].action // \"block\"" "$config_file" 2>/dev/null)
    rule_reason=$(jq -r ".rules[$i].reason // \"Blocked by custom rule\"" "$config_file" 2>/dev/null)

    # Store rule as colon-separated string
    CUSTOM_RULES+=("$rule_name:$rule_pattern:$rule_command:$rule_subcommand:$rule_action:$rule_reason")
  done
}

# Check if command matches allowlist
is_in_allowlist() {
  local cmd="$1"

  for pattern in "${CUSTOM_ALLOWLIST[@]}"; do
    # Exact match
    if [ "$cmd" = "$pattern" ]; then
      return 0
    fi

    # Pattern match (if pattern contains regex-like characters)
    if [[ "$pattern" == *"*"* ]] || [[ "$pattern" == *"?"* ]]; then
      # Shell glob matching
      if [[ "$cmd" == $pattern ]]; then
        return 0
      fi
    fi
  done

  return 1
}

# Check custom rules
# Returns 0 if command is safe, 1 if blocked
check_custom_rules() {
  local cmd="$1"

  # Load rules if not already loaded
  load_custom_rules

  # If custom rules disabled, allow everything
  if [ "$CUSTOM_RULES_ENABLED" = false ]; then
    return 0
  fi

  # Check allowlist first (allowlist takes precedence)
  if is_in_allowlist "$cmd"; then
    return 0
  fi

  # Check each custom rule
  for rule in "${CUSTOM_RULES[@]}"; do
    IFS=':' read -r name pattern command subcommand action reason <<< "$rule"

    local matched=false

    # Check by pattern (regex)
    if [ -n "$pattern" ]; then
      if [[ "$cmd" =~ $pattern ]]; then
        matched=true
      fi
    fi

    # Check by command and subcommand
    if [ -n "$command" ]; then
      if [[ "$cmd" =~ ^[[:space:]]*$command[[:space:]] ]]; then
        if [ -n "$subcommand" ]; then
          if [[ "$cmd" =~ [[:space:]]$subcommand([[:space:]]|$) ]]; then
            matched=true
          fi
        else
          matched=true
        fi
      fi
    fi

    # Apply action if matched
    if [ "$matched" = true ]; then
      if [ "$action" = "block" ]; then
        block "$reason (custom rule: $name)"
        return 1
      elif [ "$action" = "warn" ]; then
        # Log warning but allow
        log_blocked "$cmd" "WARNING: $reason (custom rule: $name)"
      fi
      # action = "allow" does nothing (default behavior)
    fi
  done

  return 0  # No custom rules blocked the command
}

# Get config file path for the current project
get_project_config_path() {
  echo "$PROJECT_CONFIG"
}

# Check if custom rules are available
has_custom_rules() {
  load_custom_rules
  [ ${#CUSTOM_RULES[@]} -gt 0 ]
}

# Reset loaded rules (useful for testing)
reset_custom_rules() {
  CUSTOM_RULES_LOADED=false
  CUSTOM_RULES_ENABLED=true
  CUSTOM_RULES=()
  CUSTOM_ALLOWLIST=()
}
