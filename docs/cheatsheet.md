# Cheatsheet

> Quick reference for Mannay Claude Code.

## Mandatory Behaviors

| Task | Auto-Activates |
|------|----------------|
| Writing code | TDD |
| Bug/error | Systematic debugging |
| New feature | Brainstorming |
| Git operations | Git skill |
| Context compaction | Memory handoff |

## Skills Quick Reference

| Skill | Trigger |
|-------|---------|
| `test-driven-development` | Any code change |
| `systematic-debugging` | "fix", "bug", "broken" |
| `brainstorming` | "new feature", "add", "create" |
| `git` | "commit", "push", "branch" |
| `task-analysis` | "implement", "build this" |
| `feature-planning` | "plan feature", "spec" |
| `prd-builder` | "create prd", "ralph prd" |
| `ralph-mode` | "run ralph", "autonomous" |

## Agent Quick Reference

| Agent | Domain |
|-------|--------|
| `security-engineer` | Auth, OWASP, validation |
| `backend-architect` | API, database, reliability |
| `frontend-architect` | Components, UX, performance |
| `api-designer` | REST, GraphQL, contracts |
| `typescript-pro` | Types, generics |
| `accessibility-specialist` | WCAG, a11y |
| `performance-engineer` | Optimization |
| `code-reviewer` | Quality, SOLID |

## Commands Quick Reference

**API:**
```bash
/api-new POST /api/users
/api-test /api/users
/api-protect /api/admin
```

**UI:**
```bash
/component-new UserCard
/page-new dashboard
/page-new-react settings
```

**Quality:**
```bash
/lint
/code-cleanup src/file.ts
/code-optimize src/file.ts
```

**Ralph:**
```bash
/ralph-init
/ralph-build
/ralph-start
/ralph-status
```

**Codex (GPT Reviews):**
```bash
/gpt-review src/file.ts --security
/gpt-status
/gpt-results
```

**Memory:**
```bash
/memory-status
/memory-learnings
```

## Conventional Commits

```
type(scope): description

feat:     New feature
fix:      Bug fix
docs:     Documentation
style:    Formatting
refactor: Code restructure
perf:     Performance
test:     Tests
build:    Build/deps
ci:       CI/CD
chore:    Maintenance
```

**Examples:**
```bash
git commit -m "feat(auth): add JWT refresh token"
git commit -m "fix(api): handle null response"
git commit -m "docs(readme): update installation"
```

## Agent Chains

| Task | Chain |
|------|-------|
| Auth feature | security → backend → api → typescript → TDD |
| UI component | frontend → accessibility → TDD |
| API endpoint | api-designer → backend → security → TDD |
| Performance | debug → performance → frontend/backend → TDD |

## Quality Standards

| Metric | Target |
|--------|--------|
| Test coverage | ≥80% |
| Lighthouse | ≥95 |
| Accessibility | WCAG 2.1 AA |
| Bundle size | <50KB gzipped |
| TypeScript | No `any` |

## Ralph Workflow

```
1. /ralph-init        # Setup files
2. /ralph-build       # Create PRD
3. /ralph-start       # Run autonomously
4. /ralph-status      # Check progress
```

**Story size rule:** Must complete in ONE iteration (~1 context window)

## File Locations

```
skills/           # Workflow skills
agents/           # Domain agents
commands/         # Slash commands
scripts/ralph/    # Ralph files
  prd.json        # PRD stories
  progress.txt    # Execution log
  prompt.md       # Iteration prompt
  AGENTS.md       # Codebase guidance
.claude/memory/   # Memory system
  memory.db       # SQLite database
  session-state.json  # Current session
```

## Memory System

**Automatic Features:**
- Session continuity across compaction
- Token optimization (60-80% savings)
- Cross-session learning

**Stored in:** `.claude/memory/memory.db`

**Check status:** `/memory-status`
