---
description: Initialize Ralph Mode in the current project - sets up all necessary files and directories
model: claude-opus-4-5
---

# Ralph Init - Initialize Ralph Mode in Current Project

Initialize Ralph Mode by creating all necessary directories and files for autonomous development.

## What This Command Does

1. Creates `scripts/ralph/` directory structure
2. Copies execution scripts (ralph-loop.sh, circuit_breaker.sh, response_analyzer.sh)
3. Creates initial template files (prd.json, progress.txt, prompt.md, AGENTS.md)
4. Creates `.safety-net.json` for command safety protection
5. Makes shell scripts executable
6. Adds appropriate entries to .gitignore

## Pre-Check

First, check if Ralph is already initialized:

```bash
ls -la scripts/ralph/ 2>/dev/null
```

If `scripts/ralph/ralph-loop.sh` already exists, inform the user:

> "Ralph is already initialized in this project. Use `/ralph-build` to create a PRD or `/ralph-start` to begin execution."

Only proceed if Ralph is NOT already initialized.

## Step 1: Create Directory Structure

```bash
mkdir -p scripts/ralph/lib
mkdir -p scripts/ralph/templates
mkdir -p scripts/ralph/logs
```

## Step 2: Create ralph-loop.sh

Create `scripts/ralph/ralph-loop.sh` with this content:

```bash
#!/usr/bin/env bash
# Ralph Loop - Autonomous execution wrapper for Claude Code
# Version: 1.0.0

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
LIB_DIR="$SCRIPT_DIR/lib"
LOGS_DIR="$SCRIPT_DIR/logs"

source "$LIB_DIR/response_analyzer.sh"
source "$LIB_DIR/circuit_breaker.sh"

MAX_ITERATIONS="${RALPH_MAX_ITERATIONS:-60}"
PROMPT_FILE="${RALPH_PROMPT_FILE:-scripts/ralph/prompt.md}"
PRD_FILE="scripts/ralph/prd.json"
PROGRESS_FILE="scripts/ralph/progress.txt"
COMPLETION_PROMISE="${RALPH_COMPLETION_PROMISE:-COMPLETE}"
CLAUDE_CMD="${CLAUDE_CMD:-claude}"
CLAUDE_TIMEOUT="${CLAUDE_TIMEOUT:-900}"
MAX_CALLS_PER_HOUR="${MAX_CALLS_PER_HOUR:-100}"
CALL_COUNT_FILE=".ralph_call_count"
TIMESTAMP_FILE=".ralph_timestamp"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

init_ralph() {
echo -e "${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║  Ralph Mode 1.0.0 - Autonomous Loop                        ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""
cd "$PROJECT_ROOT" || exit 1
mkdir -p "$LOGS_DIR"

if [ ! -f "$PRD_FILE" ]; then
  echo -e "${RED}Error: PRD file not found: $PRD_FILE${NC}" >&2
  echo "Run /ralph-build first to create your PRD" >&2
  exit 1
fi

if [ ! -f "$PROGRESS_FILE" ]; then
  echo -e "${YELLOW}Creating progress file...${NC}"
  cp scripts/ralph/templates/progress.txt "$PROGRESS_FILE" 2>/dev/null || touch "$PROGRESS_FILE"
fi

if [ ! -f "$PROMPT_FILE" ]; then
  echo -e "${YELLOW}Creating prompt file...${NC}"
  cp scripts/ralph/templates/prompt.md "$PROMPT_FILE" 2>/dev/null || touch "$PROMPT_FILE"
fi

if command -v jq >/dev/null 2>&1; then
  local prd_max_iter
  prd_max_iter=$(jq -r '.maxIterations // empty' "$PRD_FILE" 2>/dev/null || echo "")
  if [ -n "$prd_max_iter" ] && [ "$prd_max_iter" != "null" ]; then
    MAX_ITERATIONS="$prd_max_iter"
  fi
fi

init_circuit_breaker
init_call_tracking

echo -e "${GREEN}✓ Project root: $PROJECT_ROOT${NC}"
echo -e "${GREEN}✓ PRD: $PRD_FILE${NC}"
echo -e "${GREEN}✓ Max iterations: $MAX_ITERATIONS${NC}"
echo ""
}

init_call_tracking() {
local current_hour=$(date +%Y%m%d%H)
if [ ! -f "$TIMESTAMP_FILE" ]; then
  echo "$current_hour" > "$TIMESTAMP_FILE"
  echo "0" > "$CALL_COUNT_FILE"
else
  local last_hour=$(cat "$TIMESTAMP_FILE")
  if [ "$current_hour" != "$last_hour" ]; then
    echo "$current_hour" > "$TIMESTAMP_FILE"
    echo "0" > "$CALL_COUNT_FILE"
  fi
fi
}

can_make_call() {
init_call_tracking
local call_count=0
[ -f "$CALL_COUNT_FILE" ] && call_count=$(cat "$CALL_COUNT_FILE")
[ "$call_count" -ge "$MAX_CALLS_PER_HOUR" ] && return 1
return 0
}

increment_call_counter() {
local call_count=0
[ -f "$CALL_COUNT_FILE" ] && call_count=$(cat "$CALL_COUNT_FILE")
echo $((call_count + 1)) > "$CALL_COUNT_FILE"
}

execute_claude() {
local iteration="$1"
local log_file="$LOGS_DIR/ralph_iteration_${iteration}_$(date +%Y%m%d_%H%M%S).log"
local response_file="$LOGS_DIR/ralph_response_${iteration}.txt"

echo -e "${BLUE}Executing Claude (iteration $iteration)...${NC}"

if timeout "$CLAUDE_TIMEOUT" "$CLAUDE_CMD" --continue --output-format text --dangerously-skip-permissions < "$PROMPT_FILE" > "$response_file" 2>&1; then
  echo -e "${GREEN}✓ Execution completed${NC}"
  cp "$response_file" "$log_file"
  return 0
else
  echo -e "${RED}✗ Execution failed${NC}" >&2
  cp "$response_file" "$log_file" 2>/dev/null || true
  return 1
fi
}

main() {
local iteration=1
init_ralph

echo -e "${GREEN}Starting Ralph autonomous loop...${NC}"

while [ "$iteration" -le "$MAX_ITERATIONS" ]; do
  echo -e "\n${BLUE}═══ Iteration $iteration of $MAX_ITERATIONS ═══${NC}\n"

  if ! can_execute; then
    should_halt_execution
    exit 3
  fi

  if ! can_make_call; then
    echo -e "${YELLOW}Rate limit reached, waiting...${NC}"
    sleep 60
    continue
  fi

  increment_call_counter
  local response_file="$LOGS_DIR/ralph_response_${iteration}.txt"

  if execute_claude "$iteration"; then
    if analyze_response "$response_file" "$iteration"; then
      echo -e "${GREEN}Continuing...${NC}"
    else
      echo -e "\n${GREEN}╔═══ Ralph Mode: Complete ✓ ═══╗${NC}\n"
      exit 0
    fi

    if ! check_prd_complete; then
      echo -e "\n${GREEN}╔═══ PRD Complete ✓ ═══╗${NC}\n"
      exit 0
    fi

    local files_changed=0
    git diff --name-only HEAD 2>/dev/null | wc -l | grep -q "[1-9]" && \
      files_changed=$(git diff --name-only HEAD | wc -l)
    record_loop_result "$files_changed" ""
  else
    record_loop_result 0 "execution_failed"
  fi

  iteration=$((iteration + 1))
done

echo -e "\n${YELLOW}Max iterations reached${NC}\n"
exit 0
}

trap 'echo -e "\n${YELLOW}Interrupted${NC}"; exit 130' SIGINT SIGTERM
main "$@"
```

## Step 3: Create circuit_breaker.sh

Create `scripts/ralph/lib/circuit_breaker.sh` with this content:

```bash
#!/usr/bin/env bash
# Circuit Breaker - Prevents runaway loops

CB_STATE_FILE=".circuit_breaker_state"
CB_HISTORY_FILE=".circuit_breaker_history"
NO_PROGRESS_THRESHOLD=3
REPEAT_ERROR_THRESHOLD=5

init_circuit_breaker() {
  [ ! -f "$CB_STATE_FILE" ] && echo '{"state":"CLOSED","no_progress_count":0,"repeat_error_count":0,"last_error":""}' > "$CB_STATE_FILE"
}

can_execute() {
  init_circuit_breaker
  command -v jq >/dev/null 2>&1 || return 0
  local state=$(jq -r '.state // "CLOSED"' "$CB_STATE_FILE" 2>/dev/null || echo "CLOSED")
  [ "$state" = "OPEN" ] && { echo "Circuit breaker OPEN" >&2; return 1; }
  return 0
}

record_loop_result() {
  local files_changed="$1"
  local error_msg="${2:-}"
  init_circuit_breaker
  command -v jq >/dev/null 2>&1 || return

  local state=$(jq -r '.state // "CLOSED"' "$CB_STATE_FILE")
  local no_progress=$(jq -r '.no_progress_count // 0' "$CB_STATE_FILE")
  local errors=$(jq -r '.repeat_error_count // 0' "$CB_STATE_FILE")
  local last_err=$(jq -r '.last_error // ""' "$CB_STATE_FILE")

  [ "$files_changed" -eq 0 ] && no_progress=$((no_progress + 1)) || no_progress=0

  if [ -n "$error_msg" ]; then
    [ "$error_msg" = "$last_err" ] && errors=$((errors + 1)) || { errors=1; last_err="$error_msg"; }
  else
    errors=0; last_err=""
  fi

  local new_state="$state"
  if [ "$state" = "CLOSED" ] && { [ "$no_progress" -ge 2 ] || [ "$errors" -ge 3 ]; }; then
    new_state="HALF_OPEN"
  elif [ "$state" = "HALF_OPEN" ]; then
    if [ "$files_changed" -gt 0 ] && [ -z "$error_msg" ]; then
      new_state="CLOSED"; no_progress=0; errors=0
    elif [ "$no_progress" -ge "$NO_PROGRESS_THRESHOLD" ] || [ "$errors" -ge "$REPEAT_ERROR_THRESHOLD" ]; then
      new_state="OPEN"
    fi
  fi

  jq --arg s "$new_state" --arg p "$no_progress" --arg e "$errors" --arg l "$last_err" \
     '.state=$s | .no_progress_count=($p|tonumber) | .repeat_error_count=($e|tonumber) | .last_error=$l' \
     "$CB_STATE_FILE" > "${CB_STATE_FILE}.tmp" && mv "${CB_STATE_FILE}.tmp" "$CB_STATE_FILE"
}

should_halt_execution() {
  can_execute || {
    echo "Circuit breaker halted execution. Review progress.txt. Reset: rm $CB_STATE_FILE" >&2
    return 0
  }
  return 1
}

reset_circuit_breaker() {
  rm -f "$CB_STATE_FILE" "$CB_HISTORY_FILE" ".exit_signals"
  init_circuit_breaker
}
```

## Step 4: Create response_analyzer.sh

Create `scripts/ralph/lib/response_analyzer.sh` with this content:

```bash
#!/usr/bin/env bash
# Response Analyzer - Detects completion signals

analyze_response() {
  local response_file="$1"
  local loop_num="$2"
  local confidence=0

  [ ! -f "$response_file" ] && return 0
  local content=$(cat "$response_file")

  echo "$content" | grep -q "<promise>COMPLETE</promise>" && { echo "Completion promise detected" >&2; return 1; }

  echo "$content" | grep -qiE "(all (tasks|stories) complete|nothing to do|implementation done)" && confidence=$((confidence + 30))
  echo "$content" | grep -qiE "(done|finished|completed)" && confidence=$((confidence + 15))

  update_exit_signals "$confidence" "$loop_num"
  should_exit_from_signals
}

update_exit_signals() {
  local confidence="$1"
  local signals_file=".exit_signals"
  [ ! -f "$signals_file" ] && echo '{"done_signals":0,"completion_indicators":0}' > "$signals_file"
  command -v jq >/dev/null 2>&1 || return

  local done=$(jq -r '.done_signals // 0' "$signals_file")
  local comp=$(jq -r '.completion_indicators // 0' "$signals_file")
  [ "$confidence" -ge 25 ] && done=$((done + 1))
  [ "$confidence" -ge 30 ] && comp=$((comp + 1))

  jq --arg d "$done" --arg c "$comp" '.done_signals=($d|tonumber) | .completion_indicators=($c|tonumber)' \
     "$signals_file" > "${signals_file}.tmp" && mv "${signals_file}.tmp" "$signals_file"
}

should_exit_from_signals() {
  local signals_file=".exit_signals"
  [ ! -f "$signals_file" ] && return 0
  command -v jq >/dev/null 2>&1 || return 0

  local done=$(jq -r '.done_signals // 0' "$signals_file")
  local comp=$(jq -r '.completion_indicators // 0' "$signals_file")

  [ "$done" -ge 2 ] && { echo "Exit: 2+ done signals" >&2; return 1; }
  [ "$comp" -ge 2 ] && { echo "Exit: 2+ completion indicators" >&2; return 1; }
  return 0
}

check_prd_complete() {
  local prd_file="scripts/ralph/prd.json"
  [ ! -f "$prd_file" ] && return 0
  command -v jq >/dev/null 2>&1 || return 0

  local incomplete=$(jq '[.userStories[] | select(.passes == false)] | length' "$prd_file" 2>/dev/null || echo "1")
  [ "$incomplete" -eq 0 ] && { echo "All PRD stories complete" >&2; return 1; }
  return 0
}
```

## Step 5: Create Template Files

### templates/prd.json

Create `scripts/ralph/templates/prd.json`:

```json
{
  "projectName": "Your Project Name",
  "branchName": "ralph/your-feature",
  "description": "Description of what you're building",
  "created": "",
  "maxIterations": 60,
  "userStories": []
}
```

### templates/progress.txt

Create `scripts/ralph/templates/progress.txt`:

```
# Ralph Progress Log

**Project:** [Your Feature]
**Started:** [Date]
**Branch:** [ralph/your-branch]

---

## Codebase Patterns

Add reusable patterns here as you discover them:

---

## Session Log

(Entries are appended below after each story completion)
```

### templates/prompt.md

Create `scripts/ralph/templates/prompt.md` with the 7-phase autonomous execution workflow:

```markdown
# Ralph Mode - Autonomous Story Execution

You are Ralph, executing ONE user story from the PRD autonomously.

## 7-PHASE WORKFLOW

### PHASE 1: CONTEXT LOADING
- Read scripts/ralph/prd.json (find next story)
- Read scripts/ralph/progress.txt (check Codebase Patterns FIRST)
- Read scripts/ralph/AGENTS.md (if exists)
- Verify git branch matches PRD branchName

### PHASE 2: STORY SELECTION
- Select highest priority story with passes: false and blocked: false
- If ALL stories pass, output <promise>COMPLETE</promise> and stop

### PHASE 3: STORY EXECUTION
- Implement ONE story using TDD (test first, then implement)
- Invoke relevant agents (security-engineer, api-designer, etc.)

### PHASE 4: VERIFICATION (MANDATORY)
- Run typecheck: npm run typecheck
- Run tests: npm test
- Run lint if available
- DO NOT PROCEED if any check fails

### PHASE 5: COMMIT (MANDATORY)
- git add .
- git commit -m "feat(ralph): [STORY_ID] - [Title]"
- EVERY completed story MUST have a commit

### PHASE 6: UPDATE FILES (MANDATORY)
- Update prd.json: set passes: true
- Append to progress.txt with structured entry
- Update AGENTS.md if new patterns discovered

### PHASE 7: COMPLETION CHECK
- Count remaining stories with passes: false
- If 0, output <promise>COMPLETE</promise>
- Otherwise, end response (loop restarts)

## CRITICAL RULES
1. ONE story per iteration
2. MUST COMMIT after each story
3. MUST PASS checks before commit
4. NO CREDITS in commits (no Co-Authored-By)
5. Check Codebase Patterns FIRST
6. APPEND to progress.txt, never overwrite

## BEGIN
Read scripts/ralph/prd.json and execute Phase 1 now.
```

Note: The actual template file contains detailed step-by-step instructions for each phase. This is a summary - see the full template in the plugin for complete content.

## Step 6: Copy Templates to Working Location

```bash
cp scripts/ralph/templates/prd.json scripts/ralph/prd.json
cp scripts/ralph/templates/progress.txt scripts/ralph/progress.txt
cp scripts/ralph/templates/prompt.md scripts/ralph/prompt.md
cp scripts/ralph/templates/AGENTS.md scripts/ralph/AGENTS.md
```

## Step 7: Make Scripts Executable

```bash
chmod +x scripts/ralph/ralph-loop.sh
chmod +x scripts/ralph/lib/circuit_breaker.sh
chmod +x scripts/ralph/lib/response_analyzer.sh
```

## Step 8: Update .gitignore

Add these entries to `.gitignore` (create if doesn't exist):

```
# Ralph runtime files (don't commit these)
scripts/ralph/logs/
.ralph_*
.exit_signals
.circuit_breaker_*
.safety-net.log
```

## Step 9: Create Safety Net Config

Create `.safety-net.json` in the project root for command safety protection:

```json
{
  "version": 1,
  "enabled": true,
  "logBlocked": true,
  "logFile": ".safety-net.log",
  "failMode": "closed",
  "rules": [],
  "allowlist": [
    "rm -rf dist/",
    "rm -rf build/",
    "rm -rf .next/",
    "rm -rf node_modules/",
    "rm -rf __pycache__/",
    "rm -rf .cache/",
    "rm -rf coverage/"
  ],
  "protectedPaths": [
    "/etc",
    "/usr",
    "/var",
    "/System",
    "$HOME/.ssh",
    "$HOME/.gnupg"
  ]
}
```

This configuration:
- Enables safety net protection during autonomous execution
- Blocks dangerous commands (git reset --hard, rm -rf /, etc.)
- Allows common build artifact cleanup (dist/, node_modules/, etc.)
- Logs blocked commands to `.safety-net.log`

## Step 10: Success Message

After completing all steps, output:

```
╔════════════════════════════════════════════════════════════╗
║  Ralph Mode Initialized Successfully! ✓                    ║
╚════════════════════════════════════════════════════════════╝

Created:
  ✓ scripts/ralph/ralph-loop.sh (main execution script)
  ✓ scripts/ralph/lib/circuit_breaker.sh
  ✓ scripts/ralph/lib/response_analyzer.sh
  ✓ scripts/ralph/templates/ (PRD, progress, prompt, AGENTS templates)
  ✓ scripts/ralph/prd.json (initial PRD - edit with /ralph-build)
  ✓ scripts/ralph/progress.txt (progress log)
  ✓ scripts/ralph/prompt.md (execution prompt with 7-phase workflow)
  ✓ scripts/ralph/AGENTS.md (codebase guidance for Ralph)
  ✓ .safety-net.json (command safety protection)
  ✓ .gitignore updated

Safety Net Protection:
  ✓ Blocks dangerous commands (git reset --hard, rm -rf /, etc.)
  ✓ Allows build artifact cleanup (dist/, node_modules/, etc.)
  ✓ Customize rules in .safety-net.json

Next Steps:
  1. Run /ralph-build to create your PRD interactively
  2. Or edit scripts/ralph/prd.json manually
  3. Run /ralph-start to begin autonomous execution
  4. In terminal: ./scripts/ralph/ralph-loop.sh

Documentation: See scripts/ralph/README.md
```
