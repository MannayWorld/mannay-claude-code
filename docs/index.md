# Mannay Claude Code

> Professional Claude Code plugin with smart multi-agent orchestration for modern web development.

## What Is This?

A development plugin that makes Claude Code better at building software:

- **Skills** - Systematic workflows that auto-activate (TDD, debugging, brainstorming)
- **Agents** - Domain experts for specialized tasks (15 specialists)
- **Commands** - Quick tools for scaffolding (20+ commands)
- **Ralph Mode** - Autonomous execution from PRDs

## Quick Links

- [Getting Started](getting-started.md) - New to Mannay? Start here
- [Quick Start](quick-start.md) - 5-minute installation
- [Skills Reference](skills.md) - All workflow skills
- [Agents Reference](agents.md) - All domain agents
- [Commands Reference](commands.md) - All slash commands
- [Memory System](memory-system.md) - Persistent session memory
- [Cheatsheet](cheatsheet.md) - Quick reference card

## Key Features

### Smart Orchestration (v1.3.0)

**Mandatory Behaviors** - Core skills auto-activate:
- Writing code? → TDD activates automatically
- Bug or error? → Systematic debugging activates
- New feature? → Brainstorming activates first

**Multi-Agent Chaining** - Tasks use ALL relevant agents:
```
"Add user auth" → security-engineer + backend-architect + api-designer + TDD
```

**Intent Detection** - Understands what you want, not just keywords:
```
"login page" → Knows you need UI + auth + security + TDD
```

### The 3 Layers

| Layer | What | When |
|-------|------|------|
| **Skills** | Systematic workflows | Auto-activate based on task |
| **Agents** | Domain expertise | Invoked by skills or directly |
| **Commands** | Quick scaffolding | `/command-name` |

### Ralph Mode (Optional)

Autonomous execution for when you want Claude to work independently:
1. Create PRD with `/ralph-build`
2. Start with `/ralph-start`
3. Claude executes stories, commits after each one
4. Come back to completed work

### Codex Integration (v1.5.0)

Get a "second opinion" from GPT using your existing ChatGPT subscription:
- **No Extra Cost** - Uses Codex CLI with ChatGPT auth
- **Specialized Reviews** - Security, performance, refactoring
- **Background Execution** - Non-blocking, results saved to files

```bash
/gpt-review src/auth.ts --security
/gpt-status
/gpt-results
```

### Memory System (v1.4.0)

Persistent memory that works automatically:
- **Session Continuity** - Resume after context compaction
- **Token Optimization** - 60-80% savings on large files
- **Cross-Session Learning** - Remembers patterns and decisions

Check with `/memory-status` or see [Memory System](memory-system.md) for details.

## Installation

```bash
claude /plugin install mannay/mannay-claude-code
```

## Version

Current: **v1.5.0** - See [CHANGELOG](https://github.com/mannay/mannay-claude-code/blob/main/CHANGELOG.md) for details.

## Links

- [GitHub Repository](https://github.com/mannay/mannay-claude-code)
- [Report Issues](https://github.com/mannay/mannay-claude-code/issues)
