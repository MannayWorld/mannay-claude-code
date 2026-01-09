#!/usr/bin/env bash
# Response Analyzer - Detects completion signals from Claude's output
# Multi-layered completion detection for autonomous loop execution

# Analyze Claude's response for completion signals
# Args: $1 = response file path, $2 = loop number
# Returns: 0 for continue, 1 for exit
analyze_response() {
  local response_file="$1"
  local loop_num="$2"
  local confidence=0

  if [ ! -f "$response_file" ]; then
    echo "Warning: Response file not found: $response_file" >&2
    return 0
  fi

  local content
  content=$(cat "$response_file")

  # Check for completion promise (highest priority)
  if echo "$content" | grep -q "<promise>COMPLETE</promise>"; then
    echo "Completion promise detected" >&2
    return 1
  fi

  # Check for strong completion indicators
  if echo "$content" | grep -qiE "(all (tasks|stories|items) (are )?complete|nothing (left )?to do|implementation (is )?done|successfully completed all)"; then
    confidence=$((confidence + 30))
    echo "Strong completion indicator found (+30)" >&2
  fi

  # Check for "done" signals
  if echo "$content" | grep -qiE "(^|\s)(done|finished|completed)(\.|!|\s|$)"; then
    confidence=$((confidence + 15))
    echo "Done signal found (+15)" >&2
  fi

  # Check files changed (using git)
  local files_changed=0
  if git diff --name-only HEAD | wc -l | grep -q "[1-9]"; then
    files_changed=$(git diff --name-only HEAD | wc -l)
    echo "Files changed: $files_changed" >&2
  else
    # No changes = possible completion or stuck
    confidence=$((confidence + 10))
    echo "No files changed (+10)" >&2
  fi

  # Update exit signals file
  update_exit_signals "$confidence" "$loop_num"

  # Check if we should exit
  should_exit_from_signals
  return $?
}

# Update .exit_signals JSON file
update_exit_signals() {
  local confidence="$1"
  local loop_num="$2"
  local signals_file=".exit_signals"

  # Initialize if doesn't exist
  if [ ! -f "$signals_file" ]; then
    echo '{"done_signals":0,"completion_indicators":0,"test_only_loops":0,"confidence_scores":[]}' > "$signals_file"
  fi

  # Read current values
  local done_count=0
  local completion_count=0
  local test_count=0

  if command -v jq >/dev/null 2>&1; then
    done_count=$(jq -r '.done_signals // 0' "$signals_file" 2>/dev/null || echo "0")
    completion_count=$(jq -r '.completion_indicators // 0' "$signals_file" 2>/dev/null || echo "0")
    test_count=$(jq -r '.test_only_loops // 0' "$signals_file" 2>/dev/null || echo "0")

    # Increment if high confidence
    if [ "$confidence" -ge 25 ]; then
      done_count=$((done_count + 1))
    fi

    if [ "$confidence" -ge 30 ]; then
      completion_count=$((completion_count + 1))
    fi

    # Write back
    jq --arg done "$done_count" \
       --arg comp "$completion_count" \
       --arg test "$test_count" \
       --arg conf "$confidence" \
       '.done_signals = ($done | tonumber) | .completion_indicators = ($comp | tonumber) | .test_only_loops = ($test | tonumber) | .confidence_scores += [$conf | tonumber]' \
       "$signals_file" > "${signals_file}.tmp" && mv "${signals_file}.tmp" "$signals_file"
  fi
}

# Check if we should exit based on accumulated signals
# Returns: 0 for continue, 1 for exit
should_exit_from_signals() {
  local signals_file=".exit_signals"

  if [ ! -f "$signals_file" ]; then
    return 0
  fi

  if ! command -v jq >/dev/null 2>&1; then
    return 0
  fi

  local done_signals=0
  local completion_indicators=0
  local test_loops=0

  done_signals=$(jq -r '.done_signals // 0' "$signals_file" 2>/dev/null || echo "0")
  completion_indicators=$(jq -r '.completion_indicators // 0' "$signals_file" 2>/dev/null || echo "0")
  test_loops=$(jq -r '.test_only_loops // 0' "$signals_file" 2>/dev/null || echo "0")

  # Exit conditions for autonomous loop
  if [ "$test_loops" -ge 3 ]; then
    echo "Exit condition: Test saturation (3+ test-only loops)" >&2
    return 1
  fi

  if [ "$done_signals" -ge 2 ]; then
    echo "Exit condition: 2+ done signals detected" >&2
    return 1
  fi

  if [ "$completion_indicators" -ge 2 ]; then
    echo "Exit condition: 2+ completion indicators detected" >&2
    return 1
  fi

  return 0
}

# Check if all tasks in PRD are complete
check_prd_complete() {
  local prd_file="scripts/ralph/prd.json"

  if [ ! -f "$prd_file" ]; then
    return 0
  fi

  if ! command -v jq >/dev/null 2>&1; then
    return 0
  fi

  # Count stories with passes: false
  local incomplete=0
  incomplete=$(jq '[.userStories[] | select(.passes == false)] | length' "$prd_file" 2>/dev/null || echo "0")

  if [ "$incomplete" -eq 0 ]; then
    echo "Exit condition: All PRD stories complete" >&2
    return 1
  fi

  return 0
}
