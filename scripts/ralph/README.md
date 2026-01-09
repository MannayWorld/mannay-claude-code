# Ralph Mode - Autonomous AI Development Loop

Ship features while you sleep using Ralph Wiggum autonomous loop mode.

## What is Ralph Mode?

Ralph mode enables Claude to work autonomously for hours or days by:
- Executing user stories from a PRD one at a time
- Starting with fresh context each iteration (prevents context rot)
- Persisting memory via git commits, progress.txt, and prd.json
- Orchestrating Mannay's specialized agents for domain expertise
- Running typecheck + tests before every commit

Named after Ralph Wiggum from The Simpsons - perpetually trying, sometimes failing, but never stopping until success.

## Quick Start

### 1. Create Your PRD

Copy the template and customize:

```bash
cp scripts/ralph/templates/prd.json scripts/ralph/prd.json
# Edit prd.json with your user stories
```

**PRD Guidelines:**
- ✅ Small stories (fit in one context window, ~50K tokens)
- ✅ Explicit acceptance criteria (testable, specific)
- ✅ Priority order (1 = highest, 2, 3...)
- ✅ Include "typecheck passes" and "tests pass" in criteria

### 2. Initialize Progress Log

```bash
cp scripts/ralph/templates/progress.txt scripts/ralph/progress.txt
# Add initial project context
```

### 3. Create AGENTS.md (Optional but Recommended)

```bash
cp scripts/ralph/templates/AGENTS.md scripts/ralph/AGENTS.md
# Document your tech stack, patterns, gotchas
```

### 4. Start Ralph

```bash
/ralph-start
```

Ralph will:
1. Verify all files exist
2. Activate autonomous loop mode
3. Begin executing stories from PRD
4. Run until all complete or max iterations reached

### 5. Monitor Progress

```bash
# Check status anytime
/ralph-status

# View recent commits
git log --oneline --grep="feat(ralph):" -10

# Check remaining stories
jq '.userStories[] | select(.passes == false) | {id, title}' scripts/ralph/prd.json
```

### 6. Stop if Needed

```bash
/ralph-stop
```

Ralph completes current story and pauses.

## File Structure

```
scripts/ralph/
├── templates/          # Templates for new projects
│   ├── prd.json       # PRD template with examples
│   ├── progress.txt   # Progress log template
│   ├── prompt.md      # Ralph execution prompt
│   └── AGENTS.md      # Codebase guidance template
├── prd.json           # Your actual PRD (git-ignored)
├── progress.txt       # Your progress log (git-ignored)
├── AGENTS.md          # Your project guidance (committed)
└── README.md          # This file
```

## Writing Good User Stories

### ❌ Too Big

```
"Build complete authentication system with email, OAuth, 2FA"
```

Story spans multiple features. Split into smaller stories.

### ✅ Right Size

```
US-001: Add email/password login form component
US-002: Add login server action with validation
US-003: Connect form to action with error handling
US-004: Add OAuth providers (Google, GitHub)
US-005: Add 2FA setup page
```

Each story independently testable, fits in one iteration.

### ❌ Vague Criteria

```
"Users can log in successfully"
```

Not specific, not testable.

### ✅ Explicit Criteria

```
[
  "Email input with format validation",
  "Password input with min 8 chars requirement",
  "Submit button triggers validation",
  "Shows error message for invalid credentials",
  "Redirects to /dashboard on success",
  "Rate limiting: 5 attempts per 15min",
  "typecheck passes",
  "tests pass with >80% coverage"
]
```

Specific, testable, complete.

## How Ralph Works

### Iteration Loop

```
Start Iteration N:
  ↓
1. Read prd.json, progress.txt, AGENTS.md (fresh context)
  ↓
2. Find highest priority story with passes: false
  ↓
3. Execute story using TDD + agents
  ↓
4. Run typecheck → must pass
  ↓
5. Run tests → must pass
  ↓
6. Commit with feat(ralph): prefix
  ↓
7. Update prd.json (passes: true)
  ↓
8. Append learnings to progress.txt
  ↓
9. All stories complete?
   Yes → Output <promise>COMPLETE</promise> → Stop
   No → End response → Loop restarts at step 1
```

### Memory Persistence

Ralph's memory across iterations:

- **Git commits**: Complete code history
- **prd.json**: Task tracking (`passes: true/false`)
- **progress.txt**: Accumulated learnings and patterns
- **AGENTS.md**: Static codebase guidance

Each iteration starts with fresh context window but reads these files to understand previous work.

### Agent Orchestration

Ralph automatically invokes Mannay agents based on story content:

- **Auth/security stories** → `security-engineer` agent
- **API design stories** → `api-designer` agent
- **Performance stories** → `performance-engineer` agent
- **TypeScript issues** → `typescript-pro` agent
- **UI/UX stories** → `frontend-architect` agent
- **Backend stories** → `backend-architect` agent

## Configuration Options

Environment variables (set by /ralph-start):

```bash
RALPH_ACTIVE=true                           # Enable loop
RALPH_MAX_ITERATIONS=20                     # Safety limit
RALPH_PROMPT_FILE="scripts/ralph/prompt.md" # Prompt to re-inject
RALPH_COMPLETION_PROMISE="COMPLETE"         # Stop condition string
```

## Monitoring and Debugging

### Check Story Status

```bash
# List all stories with status
jq -r '.userStories[] | "[\(.id)] \(.title) - \(if .passes then "✅" elif .blocked then "⛔" else "⏳" end)"' scripts/ralph/prd.json
```

### View Recent Learnings

```bash
tail -50 scripts/ralph/progress.txt
```

### Check Ralph Commits

```bash
git log --oneline --grep="feat(ralph):" --all
```

### Iteration Count

```bash
echo $RALPH_ITERATION
```

## Troubleshooting

### Ralph keeps failing on same story

**Possible causes:**
- Story too large (split into smaller stories)
- Acceptance criteria unclear (make more specific)
- Missing context (add to AGENTS.md or progress.txt patterns)

**Solution:** Mark story as blocked, add clear reason, move to next story.

### Tests failing repeatedly

**Check:**
- Dev server running if needed
- Database migrated
- Environment variables set
- Test requirements in AGENTS.md

**Solution:** Add test setup requirements to AGENTS.md Gotchas section.

### Max iterations reached

**Possible causes:**
- Stories too ambitious
- Flaky tests
- Missing dependencies

**Solution:** Review progress.txt for patterns, adjust stories, restart with /ralph-start.

### Git conflicts

Ralph works on dedicated branch (`branchName` in PRD). If conflicts arise:

1. Stop Ralph: `/ralph-stop`
2. Manually resolve conflicts
3. Restart: `/ralph-start`

## AFK vs HOTL Ralph

### AFK Ralph (Away From Keyboard)

```bash
# Set high iteration limit, leave overnight
export RALPH_MAX_ITERATIONS=50
/ralph-start
```

**Best for:**
- Well-defined stories
- Trusted test suite
- Non-critical features

**Risks:**
- May burn tokens on wrong path
- No human course-correction

### HOTL Ralph (Hand On The Loop)

```bash
# Set low iteration limit, monitor closely
export RALPH_MAX_ITERATIONS=5
/ralph-start

# After 5 iterations, check progress
/ralph-status

# Resume for another batch
/ralph-start
```

**Best for:**
- Complex features
- Ambiguous requirements
- Learning Ralph workflow

**Benefits:**
- Human review between batches
- Can course-correct quickly
- Lower token waste

## Best Practices

### 1. Start Small

First Ralph session? Try 3-5 simple stories, max 10 iterations.

### 2. Invest in AGENTS.md

Document patterns, gotchas, setup requirements. Ralph reads this every iteration.

### 3. Review Progress Regularly

Check progress.txt after Ralph completes. Promote good patterns to Codebase Patterns section.

### 4. Use Blocked Status

Can't complete a story? Mark it blocked with clear reason. Human reviews later.

### 5. Trust the Loop

Ralph will fail and retry. That's the design. The loop handles iteration, not perfection.

## When NOT to Use Ralph

- ❌ Exploratory/research work
- ❌ Major architectural refactors
- ❌ Security-critical code needing immediate review
- ❌ Tasks without clear completion criteria
- ❌ One-off simple changes (just do them directly)

## Real-World Results

- **Geoffrey Huntley**: 3-month Ralph loop built a complete programming language
- **YC Hackathon**: 6+ repos shipped overnight for $297 API costs
- **Matt Pocock**: "I'm not going back" - uses Ralph for everything

## Further Reading

- [Ralph Wiggum: Autonomous Loops for Claude Code](https://paddo.dev/blog/ralph-wiggum-autonomous-loops/)
- [Official Anthropic Ralph Plugin](https://github.com/anthropics/claude-code/tree/main/plugins/ralph-wiggum)
- [Matt Pocock on Ralph](https://x.com/mattpocockuk/status/2007924876548637089)
- [Geoffrey Huntley's Original Technique](https://ghuntley.com/ralph/)

## Credits

- Original technique: [Geoffrey Huntley](https://ghuntley.com/ralph/)
- Methodology: [Matt Pocock](https://x.com/mattpocockuk)
- Mannay implementation: Integrated with Mannay Claude Code plugin agents and skills
