# Mannay Claude Code

> Professional Claude Code plugin with smart multi-agent orchestration for modern web development.

[![Version](https://img.shields.io/badge/version-1.3.0-blue.svg)](CHANGELOG.md)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)

## Features

- **13 Skills** - Systematic workflows that auto-activate (TDD, debugging, brainstorming)
- **15 Agents** - Domain specialists for architecture, security, performance
- **20+ Commands** - Quick scaffolding for APIs, components, pages
- **Ralph Mode** - Autonomous execution from PRDs
- **Smart Orchestration** - Multi-agent chaining, intent detection

## Quick Install

```bash
claude /plugin install mannay/mannay-claude-code
```

## What's New in v1.3.0

**Smart Orchestration:**
- Mandatory behaviors auto-activate (TDD, debugging, brainstorming)
- Multi-agent chaining - tasks use ALL relevant agents
- Intent detection - understands what you want, not just keywords

**New Skills:**
- `git` - Comprehensive git with conventional commits
- `frontend-design` - Distinctive UI avoiding AI aesthetics
- `compound-engineering` - Plan → Work → Review → Compound loop

**Integration Sections:**
- All skills now have `Called by` and `Pairs with` for clear orchestration

See [CHANGELOG.md](CHANGELOG.md) for full details.

## Documentation

| Doc | Description |
|-----|-------------|
| [Getting Started](docs/getting-started.md) | New to Mannay? Start here |
| [Quick Start](docs/quick-start.md) | 5-minute installation |
| [Skills Reference](docs/skills.md) | All workflow skills |
| [Agents Reference](docs/agents.md) | All domain agents |
| [Commands Reference](docs/commands.md) | All slash commands |
| [Cheatsheet](docs/cheatsheet.md) | Quick reference |

## Quick Examples

### Creating a Feature

```
You: Add user authentication
```

Mannay automatically:
1. Activates `brainstorming` → explores approach
2. Invokes `security-engineer` → reviews for vulnerabilities
3. Invokes `backend-architect` → designs API
4. Activates `TDD` → writes tests first
5. Activates `git` → conventional commit

### Quick Scaffolding

```bash
/api-new POST /api/users     # Create API endpoint
/component-new UserCard      # Create React component
/page-new dashboard          # Create Next.js page
```

### Ralph Mode (Autonomous)

```bash
/ralph-init                  # Initialize
/ralph-build                 # Create PRD interactively
/ralph-start                 # Run autonomously
```

## Architecture

```
Skills (Workflows)     → Auto-activate based on task
    ↓
Agents (Specialists)   → Invoked by skills
    ↓
Commands (Tools)       → Quick scaffolding
    ↓
Ralph (Autonomous)     → PRD-driven execution
```

## Requirements

- Claude Code 2.0.13+
- Works with Next.js, React, Vite, CRA

## License

MIT - Use freely in your projects.

## Author

Created by Mannay

---

**[Full Documentation](docs/index.md)** | **[Changelog](CHANGELOG.md)** | **[Report Issues](https://github.com/mannay/mannay-claude-code/issues)**
