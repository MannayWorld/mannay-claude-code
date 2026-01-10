# Quick Start

> Install and start using Mannay Claude Code in 5 minutes.

## Installation

```bash
claude /plugin install mannay/mannay-claude-code
```

## Verify Installation

```bash
claude /plugin list
# Should show: mannay-claude-code
```

## What You Get

### 13 Skills (Workflows)

| Skill | Purpose |
|-------|---------|
| `test-driven-development` | RED-GREEN-REFACTOR (mandatory for code) |
| `systematic-debugging` | 4-phase root cause analysis |
| `brainstorming` | Design exploration |
| `git` | Conventional commits |
| `task-analysis` | Task breakdown |
| `feature-planning` | Technical specs |
| `prd-builder` | Ralph PRD creation |
| `ralph-mode` | Autonomous execution |
| `writing-plans` | Implementation plans |
| `executing-plans` | Plan execution |
| `requesting-code-review` | Code review workflow |
| `api-testing` | API test generation |
| `frontend-design` | Distinctive UI creation |

### 15 Agents (Specialists)

**Architecture:** tech-stack-researcher, system-architect, backend-architect, frontend-architect, api-designer, requirements-analyst

**Quality:** code-reviewer, typescript-pro, accessibility-specialist, refactoring-expert, performance-engineer, security-engineer

**Documentation:** technical-writer, learning-guide, deep-research-agent

### 20+ Commands

**API:** `/api-new`, `/api-backend-setup`, `/api-test`, `/api-protect`

**UI:** `/component-new`, `/page-new`, `/page-new-react`

**Supabase:** `/types-gen`, `/edge-function-new`

**Quality:** `/lint`, `/code-cleanup`, `/code-optimize`, `/code-explain`

**Planning:** `/new-task`, `/feature-plan`, `/docs-generate`

**Ralph:** `/ralph-init`, `/ralph-build`, `/ralph-start`, `/ralph-status`, `/ralph-stop`

**Memory:** `/memory-status`, `/memory-learnings`

## Try It Out

### Example 1: Create a Component

```
You: Create a UserCard component with avatar and name
```

Mannay will:
1. Activate `brainstorming` → explore design
2. Activate `frontend-design` → distinctive UI
3. Invoke `accessibility-specialist` → WCAG compliance
4. Activate `TDD` → write tests first
5. Create the component
6. Activate `git` → conventional commit

### Example 2: Fix a Bug

```
You: The login is broken, users can't sign in
```

Mannay will:
1. Activate `systematic-debugging` → find root cause
2. Invoke `security-engineer` → check for security issues
3. Invoke `backend-architect` → review auth flow
4. Activate `TDD` → write regression test
5. Fix the bug
6. Activate `git` → commit the fix

### Example 3: Quick Scaffold

```
You: /api-new POST /api/users create user endpoint
```

Immediately scaffolds:
- API route with validation
- TypeScript types
- Error handling
- Test file

## Next Steps

- [Getting Started](getting-started.md) - Full explanation
- [Skills Reference](skills.md) - All skills
- [Commands Reference](commands.md) - All commands
