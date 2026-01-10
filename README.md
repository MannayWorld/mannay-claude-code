# Mannay Claude Code

> Professional Claude Code plugin with smart multi-agent orchestration for modern web development.

[![Version](https://img.shields.io/badge/version-1.5.0-blue.svg)](CHANGELOG.md)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)

## Features

- **13 Skills** - Systematic workflows that auto-activate (TDD, debugging, brainstorming)
- **15 Agents** - Domain specialists for architecture, security, performance
- **20+ Commands** - Quick scaffolding for APIs, components, pages
- **Ralph Mode** - Autonomous execution from PRDs
- **Codex Integration** - GPT code reviews via ChatGPT subscription
- **Memory System** - Persistent state across sessions with token optimization
- **Smart Orchestration** - Multi-agent chaining, intent detection

## Quick Install

```bash
# Add marketplace
/plugin marketplace add MannayWorld/mannay-claude-code

# Install plugin
/plugin install mannay-claude-code

# Update (when new versions available)
/plugin update
```

## What's New in v1.5.0

**Codex Integration - GPT Code Reviews:**
- **Background Reviews** - Get a "second opinion" from GPT on your code
- **No Extra Cost** - Uses your existing ChatGPT subscription via Codex CLI
- **Specialized Flags** - `--security`, `--performance`, `--refactor`

**New Commands:**
- `/gpt-review` - Queue files for GPT code review
- `/gpt-status` - Check review status and daily usage
- `/gpt-results` - View review results

**Setup:** `npm install -g @openai/codex && codex auth`

See [CHANGELOG.md](CHANGELOG.md) for full details.

## Documentation

| Doc | Description |
|-----|-------------|
| [Getting Started](docs/getting-started.md) | New to Mannay? Start here |
| [Quick Start](docs/quick-start.md) | 5-minute installation |
| [Skills Reference](docs/skills.md) | All workflow skills |
| [Agents Reference](docs/agents.md) | All domain agents |
| [Commands Reference](docs/commands.md) | All slash commands |
| [Memory System](docs/memory-system.md) | Persistent session memory |
| [Cheatsheet](docs/cheatsheet.md) | Quick reference |
| [Troubleshooting](docs/troubleshooting.md) | Common issues and fixes |

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
