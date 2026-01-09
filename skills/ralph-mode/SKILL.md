---
name: ralph-mode
description: "Autonomous loop execution of PRD user stories. Claude works independently completing stories one at a time with commits. Use when you have a PRD and want autonomous implementation. Triggers on: 'run ralph', 'start ralph', 'autonomous mode', 'execute the prd', 'implement all stories'."
category: execution
triggers:
  - "run ralph"
  - "start ralph"
  - "autonomous mode"
  - "execute the prd"
  - "implement all stories"
  - "work autonomously"
---

# Ralph Mode - Autonomous Loop Execution

## Overview

Ralph mode enables Claude to work autonomously for hours or days by executing user stories from a PRD (Product Requirements Document) in a continuous loop.

### 7-Phase Workflow (v1.2.0)

Each iteration follows this explicit workflow:

1. **CONTEXT LOADING** - Read prd.json, progress.txt, AGENTS.md; verify git branch
2. **STORY SELECTION** - Find highest priority story with `passes: false`
3. **STORY EXECUTION** - Implement using TDD, invoke relevant agents
4. **VERIFICATION** - Run typecheck + tests (MUST PASS before proceeding)
5. **COMMIT (MANDATORY)** - `git commit -m "feat(ralph): [STORY_ID] - [Title]"`
6. **UPDATE FILES** - Set `passes: true` in prd.json, append to progress.txt
7. **COMPLETION CHECK** - Output `<promise>COMPLETE</promise>` if all done, otherwise end

**CRITICAL:** Every completed story MUST result in a git commit. This is the key indicator that Ralph is working correctly.

**Memory persists via:**
- **Git commits**: Code history and changes
- **progress.txt**: Accumulated learnings and patterns
- **prd.json**: Task status tracking
- **AGENTS.md**: Codebase-specific guidance

## When to Use Ralph Mode

**✅ Use when:**
- You have a well-defined PRD with discrete user stories
- Each story has explicit acceptance criteria
- Programmatic verification available (tests, typecheck, linting)
- You can leave Claude working autonomously (overnight, weekend)
- Stories are independent and can be completed sequentially

**❌ Don't use when:**
- Exploratory or research work without clear goals
- Major architectural refactors requiring human decisions
- Security-critical code that needs immediate human review
- Tasks without clear completion criteria
- Single simple tasks (just do them directly)

## Required Files

Before starting Ralph mode, ensure these files exist in your project:

### 1. `scripts/ralph/prd.json`

PRD with user stories in this exact format:

```json
{
  "projectName": "Feature Name",
  "branchName": "ralph/feature-name",
  "description": "What this feature accomplishes",
  "created": "2026-01-07",
  "userStories": [
    {
      "id": "US-001",
      "title": "Specific, actionable story title",
      "description": "Detailed description of what to build",
      "acceptanceCriteria": [
        "Specific, testable criterion 1",
        "Specific, testable criterion 2",
        "typecheck passes",
        "tests pass (>80% coverage)"
      ],
      "priority": 1,
      "passes": false,
      "notes": "Context, constraints, patterns to use",
      "blocked": false,
      "blockedReason": ""
    }
  ]
}
```

**Critical PRD rules:**
- **Small stories**: Must fit in one context window (~50K tokens with code)
- **Explicit criteria**: Testable, specific, complete
- **Priority order**: 1, 2, 3... (lowest number = highest priority)
- **`passes` flag**: `false` until story complete, then `true`

### 2. `scripts/ralph/progress.txt`

Progress log with initial context:

```markdown
# Ralph Progress Log

**Project:** Feature Name
**Started:** 2026-01-07
**Branch:** ralph/feature-name

---

## Codebase Patterns

(Patterns discovered during execution will be added here)

---

## Key Files

(Important files and their purposes)

---

## Session Log

(Story-specific learnings will be appended here)
```

### 3. `scripts/ralph/AGENTS.md` (optional but recommended)

Codebase-specific guidance for agents:

```markdown
# AGENTS.md

## Project Overview
Brief description of the project

## Tech Stack
- Framework and versions
- Key libraries
- Database, auth system

## Architecture
High-level patterns and structure

## Conventions
- File organization
- Naming patterns
- Testing approach

## Dependencies
- Required services (dev server, database)
- Environment variables

## Testing
- How to run tests
- Test requirements (coverage, etc.)

## Common Gotchas
Things that trip up agents/developers
```

## Ralph Mode Execution Workflow

When Ralph mode activates, I follow this systematic workflow for each iteration:

### Phase 1: Context Loading

**Step 1: Read all Ralph files**
```bash
# Read PRD to understand stories and find next task
cat scripts/ralph/prd.json

# Read progress log for accumulated learnings and patterns
cat scripts/ralph/progress.txt

# Read codebase guidance if exists
cat scripts/ralph/AGENTS.md
```

**Step 2: Verify git branch**
```bash
# Check current branch matches PRD branchName
git branch --show-current

# If not on correct branch, checkout or create it
git checkout -b ralph/feature-name
```

### Phase 2: Story Selection

**Step 3: Select highest priority story where `passes: false`**

Parse prd.json and find:
- Lowest priority number (1 is higher priority than 2)
- Where `"passes": false`
- Where `"blocked": false`

**If no stories available:** Output `<promise>COMPLETE</promise>` and stop.

### Phase 3: Story Execution

**Step 4: Invoke task-analysis agent**

Use the task-analysis skill to break down the story:
```
Analyze story [STORY_ID]: [Story Title]

Acceptance Criteria:
- [criterion 1]
- [criterion 2]
...

Create implementation steps following TDD.
```

**Step 5: Execute using test-driven-development skill**

For each implementation step:
1. Write failing test first
2. Run test to verify it fails
3. Write minimal implementation
4. Run test to verify it passes
5. Refactor if needed

**Step 6: Invoke relevant domain agents**

Based on story type, automatically invoke:
- **Auth/validation** → security-engineer agent
- **API design** → api-designer agent
- **Performance critical** → performance-engineer agent
- **Complex types** → typescript-pro agent
- **Architecture** → backend-architect or frontend-architect
- **Accessibility** → accessibility-specialist agent

### Phase 4: Verification

**Step 7: Run typecheck**

```bash
# Project-specific typecheck command (detect from package.json)
pnpm typecheck
# or: npx tsc --noEmit
# or: npm run typecheck
```

**Expected:** All type checks pass, no errors.

**If fails:** Fix type errors before proceeding. Do NOT commit failing typecheck.

**Step 8: Run tests**

```bash
# Project-specific test command
pnpm test
# or: npm test
# or: npm run test:coverage
```

**Expected:** All tests pass, coverage meets threshold (usually >80%).

**If fails:** Fix failing tests before proceeding. Do NOT commit failing tests.

### Phase 5: Commit and Update

**Step 9: Commit if all checks pass**

```bash
git add .
git commit -m "feat(ralph): [STORY_ID] - [Story Title]

[Brief description of implementation]

Closes: [STORY_ID]"

# IMPORTANT: NO Co-Authored-By credits - keep commits clean
```

**Commit message format:**
- Prefix: `feat(ralph):` for features, `fix(ralph):` for bugs
- Include story ID for traceability
- Brief description of what was implemented
- Reference story ID in footer

**Step 10: Update prd.json**

Set `"passes": true` for the completed story:

```json
{
  "id": "US-001",
  "passes": true,  // Changed from false to true
  ...
}
```

Save the updated prd.json file.

**Step 11: Append to progress.txt**

Add entry in this format:

```markdown
---

## [2026-01-07 14:32] - US-001: Story Title

**Implemented:**
- What was built
- Key functionality added

**Files Changed:**
- path/to/file.ts (created/modified)
- path/to/test.ts (created)

**Learnings:**
- Patterns discovered
- Gotchas encountered
- Dependencies noted

**Agents Invoked:**
- security-engineer: Validated auth implementation
- typescript-pro: Resolved complex type intersection
```

**IMPORTANT:** APPEND to progress.txt, never overwrite existing content.

### Phase 6: Pattern Promotion

**Step 12: Update Codebase Patterns section if reusable patterns discovered**

If you discovered patterns worth preserving for future stories, ADD them to the `## Codebase Patterns` section at the TOP of progress.txt:

```markdown
## Codebase Patterns

- [New Pattern Category]: [Pattern description]
- Example: "API validation: Always use Zod schemas before database calls"
- Example: "React refs: Use useRef<NodeJS.Timeout | null>(null) for timer refs"
```

These patterns persist and should be checked FIRST in future iterations.

### Phase 7: Completion Check

**Step 13: Check if all stories are complete**

Parse prd.json and check:
- Are ALL stories now `"passes": true`?

**If YES:**
- Output exactly `<promise>COMPLETE</promise>`
- The loop will terminate

**If NO:**
- End response normally
- The loop will restart with fresh context for next story

## Handling Blocked Stories

If you cannot complete a story after reasonable effort (e.g., missing dependencies, unclear requirements, blocking bugs):

**Step 1: Document what you tried in progress.txt**

```markdown
---

## [2026-01-07 15:45] - US-003: Story Title (BLOCKED)

**Attempted:**
- Approach 1: [what was tried]
- Approach 2: [what was tried]

**Blocking Issue:**
[Clear description of what's blocking completion]

**Requires:**
[What's needed to unblock: human decision, external dependency, etc.]
```

**Step 2: Mark story as blocked in prd.json**

```json
{
  "id": "US-003",
  "blocked": true,
  "blockedReason": "Missing API credentials for third-party service",
  "passes": false
}
```

**Step 3: Move to next unblocked story**

Continue with next highest priority story where `"blocked": false` and `"passes": false`.

Human will review blocked stories later.

## Agent Orchestration

Ralph mode intelligently invokes Mannay's specialized agents based on story content:

### Automatic Agent Dispatch

**Story involves authentication/authorization:**
→ Invoke security-engineer agent first
→ Review for OWASP vulnerabilities, proper validation
→ Ensure secure credential handling

**Story involves API design:**
→ Invoke api-designer agent
→ Contract-first approach, clear specifications
→ RESTful patterns or GraphQL best practices

**Story involves performance optimization:**
→ Invoke performance-engineer agent
→ Measurement-driven analysis, bottleneck identification
→ Quantified improvements (response time, bundle size)

**Story involves complex TypeScript types:**
→ Invoke typescript-pro agent
→ Advanced type patterns, full-stack type safety
→ Generic constraints and inference

**Story involves UI/UX:**
→ Invoke frontend-architect agent
→ Accessibility checks, responsive design
→ Modern framework patterns

**Story involves backend/data:**
→ Invoke backend-architect agent
→ Data integrity, fault tolerance
→ Database design patterns

### Agent Invocation Example

```markdown
I'm invoking the security-engineer agent to review the authentication implementation before committing.

[Call security-engineer agent with context]

Agent feedback:
- ✅ Password hashing uses bcrypt with sufficient rounds
- ⚠️ JWT tokens should use httpOnly cookies
- ✅ Input validation present with Zod schemas

Applying agent recommendations...
[Make fixes]
```

## Integration with Existing Skills

Ralph mode composes with other Mannay skills:

**task-analysis** → Breaks down story into implementation steps
**test-driven-development** → RED-GREEN-REFACTOR cycle for each feature
**systematic-debugging** → If tests fail, debug systematically
**code-reviewer** → Optional: Review code quality before commit

## Critical Rules

1. **ONE STORY PER ITERATION**: Complete exactly one story, then stop. The loop restarts you.
2. **MUST COMMIT (MANDATORY)**: Every completed story MUST result in a git commit. No exceptions.
3. **MUST PASS BEFORE COMMIT**: Never commit code that fails typecheck or tests.
4. **COMMIT FORMAT**: Use `feat(ralph): [STORY_ID] - [Title]` for all Ralph commits.
5. **NO CREDITS IN COMMITS**: Never add "Co-Authored-By" or any attribution to commits.
6. **PRESERVE HISTORY**: Append to progress.txt, never overwrite.
7. **CHECK PATTERNS FIRST**: Read Codebase Patterns before implementing to avoid repeating mistakes.
8. **EXACT COMPLETION PROMISE**: Output exactly `<promise>COMPLETE</promise>` when all done.

## Monitoring Progress

Users can monitor Ralph's progress:

```bash
# Check story status
cat scripts/ralph/prd.json | jq '.userStories[] | {id, title, passes, blocked}'

# View recent learnings
tail -50 scripts/ralph/progress.txt

# Check recent commits
git log --oneline -10

# Count completed vs remaining
jq '[.userStories[] | select(.passes == false)] | length' scripts/ralph/prd.json
```

## Example Full Iteration

```
Iteration 3:

1. Read prd.json → US-003 is highest priority with passes: false
2. Read progress.txt → Note pattern: "API routes require auth middleware"
3. Verify branch → On "ralph/auth-system"
4. Analyze story US-003: "Add JWT authentication middleware"
5. Invoke test-driven-development skill:
   - Write failing test for middleware
   - Implement middleware
   - Tests pass ✓
6. Invoke security-engineer agent → Review auth implementation ✓
7. Run typecheck → Passes ✓
8. Run tests → All pass (87% coverage) ✓
9. Commit: "feat(ralph): US-003 - Add JWT authentication middleware"
10. Update prd.json: US-003.passes = true
11. Append to progress.txt with JWT pattern learnings
12. Check completion: 7 stories remain with passes: false
13. End response (loop will restart for US-004)
```

## Troubleshooting

### Ralph keeps failing on same story
- Story might be too big → Mark blocked, ask human to split it
- Acceptance criteria unclear → Mark blocked, ask for clarification
- Missing context → Add to AGENTS.md and progress.txt patterns

### Tests keep failing
- Check if dev server needs running
- Verify database is migrated
- Check environment variables
- Review test requirements in AGENTS.md

### Infinite loop / not progressing
- Check if completion criteria achievable
- Verify tests can actually pass (not flaky)
- Max iterations will eventually stop the loop
- Mark story as blocked and move to next

### Git conflicts
- Ralph works on dedicated branch
- If conflicts arise, mark story blocked
- Human resolves conflicts, Ralph continues

## Success Metrics

After Ralph completes:

**Quality metrics:**
- All commits pass typecheck ✓
- All commits pass tests ✓
- Code follows project patterns ✓
- No blocked stories (or clearly documented)

**Efficiency metrics:**
- Stories completed per iteration
- Average time per story
- Token cost per story

**Learning metrics:**
- Reusable patterns discovered
- AGENTS.md updated with gotchas
- progress.txt has valuable context for next time

## Integration

**Called by:**
- `prd-builder` — After PRD generated, via `/ralph-start`
- User directly — When PRD already exists

**Pairs with:**
- `prd-builder` — Creates the PRD to execute
- `task-analysis` — Breaks down stories into steps
- `test-driven-development` — For implementation (MANDATORY)
- `systematic-debugging` — When tests fail
- `git` — For commits after each story (MANDATORY)
- Domain agents — Invoked based on story type
- `code-reviewer` agent — Optional quality review
