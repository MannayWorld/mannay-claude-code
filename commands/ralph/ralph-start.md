# Ralph Start - Begin Autonomous Loop

You are activating Ralph mode with the **hybrid approach** that combines:
- ✓ External wrapper script loop mechanism
- ✓ Comprehensive agents (15 specialists) and skills (11 workflows)
- ✓ Circuit breaker for stagnation detection
- ✓ Rate limiting (100 calls/hour)
- ✓ Multi-layered completion detection
- ✓ **Safety Net protection** (blocks dangerous commands)

## How It Works

The wrapper script (`scripts/ralph/ralph-loop.sh`) will:
1. Call Claude Code CLI repeatedly in an external loop
2. **Your agents and skills are automatically available** (loaded from this plugin)
3. Use circuit breaker to detect stuck states
4. Exit gracefully when tasks complete
5. **Permissions handled automatically** via `--dangerously-skip-permissions` flag
6. **Safety Net intercepts dangerous commands** before execution
7. **2-second sleep between iterations** to prevent API rate issues

**Important:** This is NOT the old hook-based approach. This is a standalone wrapper that calls `claude` CLI with full tool permissions, protected by the Safety Net hook.

## Commit Expectations

**CRITICAL:** Every completed story MUST result in a git commit.

Ralph follows a **7-phase workflow** where Phase 5 is COMMIT (MANDATORY):

```
Phase 1: Context Loading    → Read PRD, progress.txt, AGENTS.md, verify branch
Phase 2: Story Selection    → Find next story with passes: false
Phase 3: Story Execution    → Implement using TDD, invoke agents
Phase 4: Verification       → typecheck + tests MUST pass
Phase 5: COMMIT (MANDATORY) → git add . && git commit -m "feat(ralph): ..."
Phase 6: Update Files       → Set passes: true, append to progress.txt
Phase 7: Completion Check   → Output <promise>COMPLETE</promise> or end response
```

If Ralph is NOT committing after each story, check:
1. The `scripts/ralph/prompt.md` file has the 7-phase workflow
2. Typecheck and tests are passing (Phase 4)
3. Review logs in `scripts/ralph/logs/`

## Safety Net Protection

The Safety Net is a PreToolUse hook that intercepts all Bash commands before execution. It blocks:

| Category | Blocked | Allowed |
|----------|---------|---------|
| **Git** | `reset --hard`, `push --force`, `clean -f`, `branch -D` | `push`, `push --force-with-lease`, `branch -d` |
| **Files** | `rm -rf /`, `rm -rf ~`, `rm -rf .` | `rm -rf node_modules/`, `rm -rf dist/` |
| **System** | `eval`, `curl \| bash`, `chmod 777` | Normal commands |

Customize in `.safety-net.json`:
```json
{
  "enabled": true,
  "allowlist": ["rm -rf custom-dir/"],
  "rules": [{"name": "custom-rule", "command": "npm", "subcommand": "publish", "action": "block"}]
}
```

Blocked commands are logged to `.safety-net.log`.

## Required Files Check

First, verify all required files exist:

1. **PRD**: `scripts/ralph/prd.json`
2. **Progress log**: `scripts/ralph/progress.txt`
3. **Prompt file**: `scripts/ralph/prompt.md`

If any are missing, run `/ralph-build` or create them using templates below.

## File Templates

### If PRD doesn't exist:

Create `scripts/ralph/prd.json`:

```json
{
  "projectName": "My Feature",
  "branchName": "ralph/my-feature",
  "description": "Description of what this accomplishes",
  "created": "2026-01-09",
  "maxIterations": 60,
  "completionPromise": "<promise>COMPLETE</promise>",
  "qualityGates": {
    "testCoverage": 80,
    "typeErrors": 0,
    "lintErrors": 0
  },
  "userStories": [
    {
      "id": "US-001",
      "title": "First user story",
      "description": "Detailed description",
      "acceptanceCriteria": [
        "Criterion 1",
        "Criterion 2",
        "typecheck passes",
        "tests pass"
      ],
      "priority": 1,
      "passes": false,
      "blocked": false,
      "blockedReason": ""
    }
  ]
}
```

### If progress.txt doesn't exist:

Create `scripts/ralph/progress.txt`:

```markdown
# Ralph Progress Log

**Project:** My Feature
**Started:** 2026-01-09
**Branch:** ralph/my-feature

---

## Codebase Patterns

(Will be populated during execution)

---

## Key Files

(Will be populated during execution)

---

## Session Log

(Story entries will be appended here)
```

### If prompt.md doesn't exist:

Create `scripts/ralph/prompt.md` with the 7-phase workflow:

```markdown
# Ralph Mode - Autonomous Story Execution

You are Ralph, executing ONE user story from the PRD autonomously.

## 7-PHASE WORKFLOW

### PHASE 1: CONTEXT LOADING
- Read scripts/ralph/prd.json, scripts/ralph/progress.txt, scripts/ralph/AGENTS.md
- Check Codebase Patterns section in progress.txt FIRST
- Verify git branch matches PRD branchName

### PHASE 2: STORY SELECTION
- Find highest priority story with passes: false and blocked: false
- If ALL stories pass, output <promise>COMPLETE</promise> and stop

### PHASE 3: STORY EXECUTION
- Implement ONE story using TDD (write test first)
- Invoke relevant agents (security-engineer, api-designer, typescript-pro, etc.)

### PHASE 4: VERIFICATION (MANDATORY)
- Run: npm run typecheck (MUST PASS)
- Run: npm test (MUST PASS)
- DO NOT PROCEED if any check fails

### PHASE 5: COMMIT (MANDATORY)
- git add .
- git commit -m "feat(ralph): [STORY_ID] - [Title]"
- EVERY completed story MUST result in a commit

### PHASE 6: UPDATE FILES (MANDATORY)
- Update prd.json: set passes: true for completed story
- APPEND to progress.txt (never overwrite)
- Update AGENTS.md if new patterns discovered

### PHASE 7: COMPLETION CHECK
- If all stories pass, output <promise>COMPLETE</promise>
- Otherwise, end response (loop restarts for next story)

## CRITICAL RULES
1. ONE story per iteration
2. MUST COMMIT after each story
3. MUST PASS checks before commit
4. NO CREDITS in commits (no Co-Authored-By)
5. Check Codebase Patterns FIRST

## BEGIN
Read scripts/ralph/prd.json and execute Phase 1 now.
```

## Launch Ralph

Once all files are ready, spawn the wrapper script:

```bash
# Navigate to project root
cd "$(git rev-parse --show-toplevel)"

# Make scripts executable (if not already)
chmod +x scripts/ralph/ralph-loop.sh
chmod +x scripts/ralph/lib/*.sh

# Launch Ralph wrapper
echo "🚀 Launching Ralph autonomous loop..."
echo ""
./scripts/ralph/ralph-loop.sh
```

The wrapper will:
- Initialize circuit breaker and rate limiting
- Display iteration progress with colored output
- Call Claude Code CLI which loads your agents/skills
- Monitor for completion signals and stagnation
- Exit gracefully when done or if stuck

## Monitoring Ralph

While Ralph is running, you can:

- **Check logs**: `tail -f scripts/ralph/logs/ralph_iteration_*.log`
- **View PRD status**: `jq '.userStories[] | select(.passes == false)' scripts/ralph/prd.json`
- **Monitor commits** (IMPORTANT): `git log --oneline -10`
- **Check progress**: `tail -20 scripts/ralph/progress.txt`
- **Count completed stories**: `jq '[.userStories[] | select(.passes == true)] | length' scripts/ralph/prd.json`

**Key Indicator:** If Ralph is working correctly, you should see new commits appearing after each story completion. Each commit message should follow the format: `feat(ralph): US-XXX - Story Title`

## Stopping Ralph

Press `Ctrl+C` to stop the loop gracefully.

Or from another terminal:

```bash
pkill -f ralph-loop.sh
```

## Resetting Circuit Breaker

If Ralph detects stagnation and halts:

```bash
rm .circuit_breaker_state .circuit_breaker_history .exit_signals
```

Then review `progress.txt` and recent commits to diagnose the issue.

## Technical Note

This implementation uses an external wrapper script pattern instead of hook-based loop injection due to Claude Code plugin limitations (Issue #10412). The wrapper calls `claude` CLI repeatedly while your agents/skills are loaded automatically.

## Troubleshooting

**"PRD file not found"**
→ Run `/ralph-build` to generate PRD

**"Permission denied" (file permissions)**
→ Run `chmod +x scripts/ralph/ralph-loop.sh`

**"Claude CLI has no permissions" / Tool permission errors**
→ The wrapper uses `--dangerously-skip-permissions` flag for autonomous execution
→ If still failing, ensure you're using Claude Code CLI v1.0.0+

**"Circuit breaker open"**
→ Ralph detected stagnation. Review logs, reset circuit breaker

**"Rate limit reached"**
→ Wait for hourly reset or adjust MAX_CALLS_PER_HOUR

**"Command not found: claude"**
→ Ensure Claude Code CLI is installed and in PATH

**"Command blocked by Safety Net"**
→ Check `.safety-net.log` for details
→ Add command to `allowlist` in `.safety-net.json` if legitimate
→ Set `SAFETY_NET_ENABLED=0` to disable (not recommended)

**"Safety Net blocking legitimate rm -rf"**
→ Relative paths like `rm -rf dist/` should be allowed by default
→ Add specific paths to `allowlist` in `.safety-net.json`

---

Ready to launch Ralph! 🚀
