# Getting Started

> New to Mannay Claude Code? This guide explains everything.

## What Is This?

A **development plugin** that makes Claude Code better at building software. Think of it like giving Claude:

- **A brain** - Systematic processes (skills)
- **Expert friends** - Domain specialists (agents)
- **Power tools** - Quick scaffolding (commands)
- **Autopilot** - Optional autonomous execution (Ralph Mode)

## The 3 Layers

### Layer 1: Skills = The Process

**Skills are systematic workflows that auto-activate.**

| Skill | When It Activates | What It Does |
|-------|-------------------|--------------|
| `test-driven-development` | Any code change | RED-GREEN-REFACTOR cycle |
| `systematic-debugging` | Bug or error | 4-phase root cause analysis |
| `brainstorming` | New feature | Design exploration first |
| `git` | Commits/pushes | Conventional commit format |
| `task-analysis` | Task given | Break into actionable steps |
| `feature-planning` | Feature spec | Technical specification |
| `prd-builder` | Ralph PRD | Create execution-ready PRD |

**Example:**
- You say "Add dark mode" → `brainstorming` activates → explores design first
- You say "Fix this bug" → `systematic-debugging` activates → finds root cause

### Layer 2: Agents = The Experts

**Agents are domain specialists invoked by skills or directly.**

| Agent | Expertise |
|-------|-----------|
| `security-engineer` | Auth, validation, OWASP |
| `backend-architect` | APIs, databases, reliability |
| `frontend-architect` | Components, UX, performance |
| `api-designer` | REST, GraphQL, contracts |
| `typescript-pro` | Types, generics, inference |
| `accessibility-specialist` | WCAG, a11y, screen readers |
| `performance-engineer` | Bottlenecks, optimization |
| `code-reviewer` | Quality, SOLID, best practices |

**Example:**
```
Building auth feature:
1. brainstorming explores approach
2. security-engineer reviews for vulnerabilities
3. backend-architect designs API
4. TDD implements with tests
5. code-reviewer checks quality
```

### Layer 3: Commands = Quick Tools

**Commands are slash commands for quick actions.**

```bash
/api-new users endpoint     # Scaffold API route
/component-new UserCard     # Create React component
/page-new dashboard         # Create Next.js page
/lint                       # Run linting
```

See [Commands Reference](commands.md) for full list.

## Smart Orchestration (v1.3.0)

### Mandatory Behaviors

These skills activate **automatically** - you don't need to ask:

| Task Type | Auto-Activates |
|-----------|----------------|
| Writing code | TDD (always) |
| Fixing bugs | Systematic debugging |
| New features | Brainstorming first |

### Multi-Agent Chaining

Tasks use **ALL relevant agents**, not just one:

```
"Add user authentication"
  → brainstorming (approach)
  → security-engineer (vulnerabilities)
  → backend-architect (API design)
  → api-designer (contracts)
  → typescript-pro (types)
  → TDD (implementation)
  → code-reviewer (quality)
```

### Intent Detection

Mannay understands **what you want**, not just keywords:

| You Say | Mannay Understands |
|---------|-------------------|
| "login page" | UI + auth + security + TDD |
| "it's slow" | Debug first → performance analysis |
| "add button" | UI + accessibility + TDD |

## Ralph Mode (Optional)

For autonomous execution when you want Claude to work independently.

### When to Use Ralph

✅ **Good for:**
- Well-defined PRDs with clear stories
- Overnight/weekend work
- Sequential independent tasks

❌ **Not for:**
- Exploratory work
- Major architecture decisions
- Security-critical code needing human review

### Ralph Workflow

```
1. /ralph-init          # Initialize Ralph files
2. /ralph-build         # Create PRD interactively
3. /ralph-start         # Start autonomous loop
4. Come back later      # Work is done with commits
```

## Next Steps

1. [Quick Start](quick-start.md) - Install in 5 minutes
2. [Skills Reference](skills.md) - All skills explained
3. [Cheatsheet](cheatsheet.md) - Quick reference
