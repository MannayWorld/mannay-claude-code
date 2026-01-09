#!/usr/bin/env bash
# Ralph Loop - Autonomous execution wrapper for Claude Code
# External wrapper pattern with mannay's agents/skills integration
# Version: 1.2.0

set -euo pipefail

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
LIB_DIR="$SCRIPT_DIR/lib"
LOGS_DIR="$SCRIPT_DIR/logs"

# Source helper libraries
source "$LIB_DIR/response_analyzer.sh"
source "$LIB_DIR/circuit_breaker.sh"

# Ralph configuration (can be overridden by environment)
MAX_ITERATIONS="${RALPH_MAX_ITERATIONS:-60}"
PROMPT_FILE="${RALPH_PROMPT_FILE:-scripts/ralph/prompt.md}"
PRD_FILE="scripts/ralph/prd.json"
PROGRESS_FILE="scripts/ralph/progress.txt"
COMPLETION_PROMISE="${RALPH_COMPLETION_PROMISE:-COMPLETE}"

# Execution settings
CLAUDE_CMD="${CLAUDE_CMD:-claude}"
CLAUDE_TIMEOUT="${CLAUDE_TIMEOUT:-900}"  # 15 minutes in seconds
MAX_CALLS_PER_HOUR="${MAX_CALLS_PER_HOUR:-100}"

# State files
CALL_COUNT_FILE=".ralph_call_count"
TIMESTAMP_FILE=".ralph_timestamp"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Initialize Ralph environment
init_ralph() {
  echo -e "${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
  echo -e "${BLUE}║  Ralph Mode 1.2.0 - Autonomous Loop (Hybrid Approach)     ║${NC}"
  echo -e "${BLUE}╚════════════════════════════════════════════════════════════╝${NC}"
  echo ""

  # Change to project root
  cd "$PROJECT_ROOT" || exit 1

  # Create logs directory
  mkdir -p "$LOGS_DIR"

  # Validate required files
  if [ ! -f "$PRD_FILE" ]; then
    echo -e "${RED}Error: PRD file not found: $PRD_FILE${NC}" >&2
    echo "Run /ralph-build or create the PRD manually" >&2
    exit 1
  fi

  if [ ! -f "$PROGRESS_FILE" ]; then
    echo -e "${RED}Error: Progress file not found: $PROGRESS_FILE${NC}" >&2
    exit 1
  fi

  if [ ! -f "$PROMPT_FILE" ]; then
    echo -e "${RED}Error: Prompt file not found: $PROMPT_FILE${NC}" >&2
    exit 1
  fi

  # Read max iterations from PRD if available
  if command -v jq >/dev/null 2>&1; then
    local prd_max_iter
    prd_max_iter=$(jq -r '.maxIterations // empty' "$PRD_FILE" 2>/dev/null || echo "")
    if [ -n "$prd_max_iter" ] && [ "$prd_max_iter" != "null" ]; then
      MAX_ITERATIONS="$prd_max_iter"
    fi
  fi

  # Initialize circuit breaker
  init_circuit_breaker

  # Initialize call tracking
  init_call_tracking

  echo -e "${GREEN}✓ Project root: $PROJECT_ROOT${NC}"
  echo -e "${GREEN}✓ PRD: $PRD_FILE${NC}"
  echo -e "${GREEN}✓ Progress: $PROGRESS_FILE${NC}"
  echo -e "${GREEN}✓ Prompt: $PROMPT_FILE${NC}"
  echo -e "${GREEN}✓ Max iterations: $MAX_ITERATIONS${NC}"
  echo -e "${GREEN}✓ Agents & Skills: Active via plugin system${NC}"
  echo ""
}

# Initialize or reset call tracking
init_call_tracking() {
  local current_hour
  current_hour=$(date +%Y%m%d%H)

  if [ ! -f "$TIMESTAMP_FILE" ]; then
    echo "$current_hour" > "$TIMESTAMP_FILE"
    echo "0" > "$CALL_COUNT_FILE"
  else
    local last_hour
    last_hour=$(cat "$TIMESTAMP_FILE")

    if [ "$current_hour" != "$last_hour" ]; then
      echo "$current_hour" > "$TIMESTAMP_FILE"
      echo "0" > "$CALL_COUNT_FILE"
      echo -e "${YELLOW}Rate limit reset (new hour)${NC}"
    fi
  fi
}

# Check if we can make another API call
can_make_call() {
  init_call_tracking

  local call_count=0
  if [ -f "$CALL_COUNT_FILE" ]; then
    call_count=$(cat "$CALL_COUNT_FILE")
  fi

  if [ "$call_count" -ge "$MAX_CALLS_PER_HOUR" ]; then
    echo -e "${RED}Rate limit reached: $call_count/$MAX_CALLS_PER_HOUR calls this hour${NC}" >&2
    return 1
  fi

  return 0
}

# Increment call counter
increment_call_counter() {
  local call_count=0
  if [ -f "$CALL_COUNT_FILE" ]; then
    call_count=$(cat "$CALL_COUNT_FILE")
  fi

  call_count=$((call_count + 1))
  echo "$call_count" > "$CALL_COUNT_FILE"

  echo -e "${BLUE}API calls this hour: $call_count/$MAX_CALLS_PER_HOUR${NC}"
}

# Execute Claude Code CLI
# Args: $1 = iteration number
execute_claude() {
  local iteration="$1"
  local log_file="$LOGS_DIR/ralph_iteration_${iteration}_$(date +%Y%m%d_%H%M%S).log"
  local response_file="$LOGS_DIR/ralph_response_${iteration}.txt"

  echo -e "${BLUE}Executing Claude Code (iteration $iteration)...${NC}"

  # Build Claude command with modern flags
  local claude_args=(
    "--continue"  # Preserve session context
    "--output-format" "text"  # Text output for compatibility
    "--dangerously-skip-permissions"  # Required for autonomous execution
  )

  # Execute Claude with timeout and capture output
  if timeout "$CLAUDE_TIMEOUT" "$CLAUDE_CMD" "${claude_args[@]}" < "$PROMPT_FILE" > "$response_file" 2>&1; then
    echo -e "${GREEN}✓ Claude execution completed${NC}"

    # Copy to log file
    cp "$response_file" "$log_file"

    return 0
  else
    local exit_code=$?
    echo -e "${RED}✗ Claude execution failed (exit code: $exit_code)${NC}" >&2

    # Still save the output
    cp "$response_file" "$log_file" 2>/dev/null || true

    return 1
  fi
}

# Main loop
main() {
  local iteration=1

  init_ralph

  echo -e "${GREEN}Starting Ralph autonomous loop...${NC}"
  echo ""

  while [ "$iteration" -le "$MAX_ITERATIONS" ]; do
    echo ""
    echo -e "${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║  Iteration $iteration of $MAX_ITERATIONS${NC}"
    echo -e "${BLUE}╚════════════════════════════════════════════════════════════╝${NC}"
    echo ""

    # Check circuit breaker
    if ! can_execute; then
      should_halt_execution
      exit 3
    fi

    # Check rate limit
    if ! can_make_call; then
      echo -e "${YELLOW}Waiting for rate limit reset...${NC}"
      sleep 60
      continue
    fi

    # Execute Claude
    increment_call_counter

    local response_file="$LOGS_DIR/ralph_response_${iteration}.txt"

    if execute_claude "$iteration"; then
      # Analyze response
      if analyze_response "$response_file" "$iteration"; then
        # Continue loop
        echo -e "${GREEN}Continuing to next iteration...${NC}"
      else
        # Exit condition met
        echo ""
        echo -e "${GREEN}╔════════════════════════════════════════════════════════════╗${NC}"
        echo -e "${GREEN}║  Ralph Mode: Completion Detected ✓${NC}"
        echo -e "${GREEN}║  All tasks completed successfully${NC}"
        echo -e "${GREEN}╚════════════════════════════════════════════════════════════╝${NC}"
        echo ""
        exit 0
      fi

      # Check PRD completion
      if ! check_prd_complete; then
        echo ""
        echo -e "${GREEN}╔════════════════════════════════════════════════════════════╗${NC}"
        echo -e "${GREEN}║  Ralph Mode: PRD Complete ✓${NC}"
        echo -e "${GREEN}║  All user stories marked as passing${NC}"
        echo -e "${GREEN}╚════════════════════════════════════════════════════════════╝${NC}"
        echo ""
        exit 0
      fi

      # Count files changed for circuit breaker
      local files_changed=0
      if git diff --name-only HEAD 2>/dev/null | wc -l | grep -q "[1-9]"; then
        files_changed=$(git diff --name-only HEAD | wc -l)
      fi

      # Update circuit breaker
      record_loop_result "$files_changed" ""

    else
      # Execution failed
      echo -e "${RED}Execution failed, continuing with caution...${NC}"

      # Update circuit breaker with error
      record_loop_result 0 "claude_execution_failed"
    fi

    iteration=$((iteration + 1))

    # Sleep between iterations to prevent API rate issues and allow for stable state
    echo -e "${BLUE}Sleeping 2 seconds before next iteration...${NC}"
    sleep 2
  done

  # Max iterations reached
  echo ""
  echo -e "${YELLOW}╔════════════════════════════════════════════════════════════╗${NC}"
  echo -e "${YELLOW}║  Ralph Mode: Max Iterations Reached${NC}"
  echo -e "${YELLOW}║  Iterations completed: $MAX_ITERATIONS${NC}"
  echo -e "${YELLOW}║  Check progress.txt and prd.json for status${NC}"
  echo -e "${YELLOW}╚════════════════════════════════════════════════════════════╝${NC}"
  echo ""

  exit 0
}

# Cleanup on exit
cleanup() {
  echo ""
  echo -e "${YELLOW}Ralph loop interrupted${NC}"
  exit 130
}

trap cleanup SIGINT SIGTERM

# Run main loop
main "$@"
