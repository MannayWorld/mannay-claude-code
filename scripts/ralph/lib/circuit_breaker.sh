#!/usr/bin/env bash
# Circuit Breaker - Prevents runaway loops from stuck states
# Implements Michael Nygard's Circuit Breaker pattern from "Release It!"

# States: CLOSED (normal), HALF_OPEN (monitoring), OPEN (halted)
CB_STATE_FILE=".circuit_breaker_state"
CB_HISTORY_FILE=".circuit_breaker_history"

# Thresholds
NO_PROGRESS_THRESHOLD=3  # Loops without file changes
REPEAT_ERROR_THRESHOLD=5  # Loops with same error

# Initialize circuit breaker
init_circuit_breaker() {
  if [ ! -f "$CB_STATE_FILE" ]; then
    echo '{"state":"CLOSED","no_progress_count":0,"repeat_error_count":0,"last_error":"","files_changed_history":[]}' > "$CB_STATE_FILE"
  fi
}

# Check if execution can proceed
# Returns: 0 for can execute, 1 for circuit open
can_execute() {
  init_circuit_breaker

  if ! command -v jq >/dev/null 2>&1; then
    return 0
  fi

  local state
  state=$(jq -r '.state // "CLOSED"' "$CB_STATE_FILE" 2>/dev/null || echo "CLOSED")

  if [ "$state" = "OPEN" ]; then
    echo "Circuit breaker is OPEN - execution halted" >&2
    return 1
  fi

  return 0
}

# Record loop result and update circuit breaker state
# Args: $1 = files changed count, $2 = error message (optional)
record_loop_result() {
  local files_changed="$1"
  local error_msg="${2:-}"

  init_circuit_breaker

  if ! command -v jq >/dev/null 2>&1; then
    return
  fi

  local current_state
  local no_progress_count
  local repeat_error_count
  local last_error

  current_state=$(jq -r '.state // "CLOSED"' "$CB_STATE_FILE")
  no_progress_count=$(jq -r '.no_progress_count // 0' "$CB_STATE_FILE")
  repeat_error_count=$(jq -r '.repeat_error_count // 0' "$CB_STATE_FILE")
  last_error=$(jq -r '.last_error // ""' "$CB_STATE_FILE")

  # Check for no progress
  if [ "$files_changed" -eq 0 ]; then
    no_progress_count=$((no_progress_count + 1))
    echo "No files changed - progress count: $no_progress_count/$NO_PROGRESS_THRESHOLD" >&2
  else
    no_progress_count=0
    echo "Files changed: $files_changed - resetting progress counter" >&2
  fi

  # Check for repeated errors
  if [ -n "$error_msg" ]; then
    if [ "$error_msg" = "$last_error" ]; then
      repeat_error_count=$((repeat_error_count + 1))
      echo "Repeated error - count: $repeat_error_count/$REPEAT_ERROR_THRESHOLD" >&2
    else
      repeat_error_count=1
      last_error="$error_msg"
    fi
  else
    repeat_error_count=0
    last_error=""
  fi

  # Determine new state
  local new_state="$current_state"

  if [ "$current_state" = "CLOSED" ]; then
    if [ "$no_progress_count" -ge 2 ] || [ "$repeat_error_count" -ge 3 ]; then
      new_state="HALF_OPEN"
      echo "Circuit breaker transitioning: CLOSED → HALF_OPEN" >&2
      log_state_transition "CLOSED" "HALF_OPEN" "Monitoring for stagnation"
    fi
  elif [ "$current_state" = "HALF_OPEN" ]; then
    if [ "$files_changed" -gt 0 ] && [ -z "$error_msg" ]; then
      new_state="CLOSED"
      no_progress_count=0
      repeat_error_count=0
      echo "Circuit breaker transitioning: HALF_OPEN → CLOSED (recovery)" >&2
      log_state_transition "HALF_OPEN" "CLOSED" "Progress resumed"
    elif [ "$no_progress_count" -ge "$NO_PROGRESS_THRESHOLD" ] || [ "$repeat_error_count" -ge "$REPEAT_ERROR_THRESHOLD" ]; then
      new_state="OPEN"
      echo "Circuit breaker transitioning: HALF_OPEN → OPEN (halted)" >&2
      log_state_transition "HALF_OPEN" "OPEN" "Stagnation detected"
    fi
  fi

  # Update state file
  jq --arg state "$new_state" \
     --arg progress "$no_progress_count" \
     --arg errors "$repeat_error_count" \
     --arg last_err "$last_error" \
     --arg files "$files_changed" \
     '.state = $state | .no_progress_count = ($progress | tonumber) | .repeat_error_count = ($errors | tonumber) | .last_error = $last_err | .files_changed_history += [$files | tonumber]' \
     "$CB_STATE_FILE" > "${CB_STATE_FILE}.tmp" && mv "${CB_STATE_FILE}.tmp" "$CB_STATE_FILE"
}

# Log state transition to history
log_state_transition() {
  local from_state="$1"
  local to_state="$2"
  local reason="$3"
  local timestamp
  timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

  echo "$timestamp: $from_state → $to_state ($reason)" >> "$CB_HISTORY_FILE"
}

# Display diagnostic information when circuit opens
should_halt_execution() {
  if ! can_execute; then
    echo "" >&2
    echo "╔════════════════════════════════════════════════════════════╗" >&2
    echo "║  Circuit Breaker: Execution Halted" >&2
    echo "║" >&2
    echo "║  Ralph has detected stagnation and stopped to prevent" >&2
    echo "║  wasted API calls. This usually means:" >&2
    echo "║" >&2
    echo "║  1. The task is blocked by external factors" >&2
    echo "║  2. Claude is stuck in a loop" >&2
    echo "║  3. The approach needs human intervention" >&2
    echo "║" >&2
    echo "║  Review progress.txt and recent commits to diagnose." >&2
    echo "║  Reset circuit breaker: rm $CB_STATE_FILE" >&2
    echo "╚════════════════════════════════════════════════════════════╝" >&2
    echo "" >&2
    return 0  # Return 0 to signal halt
  fi

  return 1  # Return 1 to continue
}

# Reset circuit breaker (for manual intervention)
reset_circuit_breaker() {
  rm -f "$CB_STATE_FILE" "$CB_HISTORY_FILE" ".exit_signals"
  echo "Circuit breaker reset" >&2
  init_circuit_breaker
}
