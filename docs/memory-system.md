# Memory System

> Persistent memory for Claude Code sessions with automatic state preservation and cross-session learning.

## Overview

The Compound Memory System gives Mannay Claude Code persistent memory across sessions. It works automatically in the background, requiring no configuration.

**Key Benefits:**
- **Session Continuity** - Pick up exactly where you left off after context compaction
- **Token Savings** - 60-80% fewer tokens when reading large files
- **Cross-Session Learning** - Accumulates knowledge from your development patterns

## How It Works

### Session Continuity

When your context window fills up and Claude compacts, your session state is automatically preserved and restored.

**What's Preserved:**
- Current task description
- Files you've modified
- Decisions made during the session
- Todos and blockers
- Last action performed

**Example:**
```
Working on auth feature...
  ↓
Context compacts
  ↓
New session starts with:
  "Continuing: Add user authentication
   Modified: auth.ts, middleware.ts
   Decision: Using JWT with refresh tokens
   Last action: Created token validation"
```

### Token Optimization

Large files are automatically summarized to their signatures (function names, class definitions, interfaces) before being loaded into context.

**How it works:**
- Files over 100 lines are analyzed
- Tree-sitter extracts function/class/interface signatures
- Signatures are cached for instant retrieval
- Full file is still available when needed

**Supported Languages:**
- TypeScript (.ts, .tsx)
- JavaScript (.js, .jsx, .mjs, .cjs)
- Python (.py)

**Example:**
```
Reading: src/lib/auth.ts (500 lines)
  ↓
Extracted: Function signatures only (50 lines)
  ↓
Token savings: 75%
```

### Cross-Session Learning

At the end of each session, meaningful learnings are extracted and stored for future recall.

**Categories:**
- **Patterns** - Recurring code patterns in your project
- **Architecture** - Structural decisions and conventions
- **Fixes** - Solutions to problems encountered
- **Tips** - Project-specific best practices

**Example learnings:**
```
"This project uses Zod for validation with custom error messages"
"Database queries use connection pooling with max 10 connections"
"Auth tokens expire after 15 minutes, refresh tokens after 7 days"
```

## Commands

### /memory-status

Check the memory system status and statistics.

```bash
/memory-status
```

**Shows:**
- Database size
- Number of saved handoffs
- Cached file signatures
- Token savings percentage
- Recorded learnings
- Current session state

---

### /memory-learnings

View recent learnings accumulated across sessions.

```bash
/memory-learnings
```

**Shows:**
- 10 most recent learnings
- Tags and categories
- Recall count (how often used)
- Total learning count

**Search learnings:**
```
"What have I learned about authentication?"
```

---

## Automatic Behavior

The memory system runs automatically through hooks:

| Hook | When | What |
|------|------|------|
| `session-start` | New session | Restores previous state, recalls learnings |
| `post-tool-track` | After actions | Tracks files and decisions |
| `pre-compact` | Before compaction | Saves handoff with full state |
| `pre-read` | Reading files | Caches signatures for large files |
| `session-end` | Session ends | Extracts and stores learnings |

## File Locations

```
.claude/memory/
  memory.db           # SQLite database
  session-state.json  # Current session state
```

## Requirements

- Node.js 18+
- Dependencies installed automatically

## Troubleshooting

### Memory not working?

1. Check Node.js is installed: `node --version`
2. Check dependencies: `cd memory && npm install`
3. Verify database exists: `ls -la .claude/memory/`

### Signatures not caching?

- File must be over 100 lines
- Must be a supported language (.ts, .js, .py)
- Tree-sitter dependencies must be installed

### Learnings not accumulating?

- Session must have more than 3 actions
- Decisions must be meaningful (not just commits)
- Session must end normally (not terminated)

## Privacy

All memory data is stored locally in your project's `.claude/memory/` directory. Nothing is sent externally. Add `.claude/memory/` to your `.gitignore` if you don't want to commit session data.
