# Memory System

> Persistent memory for Claude Code sessions with automatic state preservation and cross-session learning.

## Overview

The Compound Memory System gives Mannay Claude Code persistent memory across sessions. It works automatically in the background, requiring no configuration.

**Key Benefits:**
- **Session Continuity** - Pick up exactly where you left off after context compaction
- **Token Savings** - 60-80% fewer tokens when reading large files
- **Cross-Session Learning** - Accumulates knowledge from your development patterns

---

## Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                    Claude Code Session                          │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌──────────────┐    ┌──────────────┐    ┌──────────────┐      │
│  │   Session    │    │    Token     │    │   Semantic   │      │
│  │  Continuity  │    │ Optimization │    │   Learning   │      │
│  └──────┬───────┘    └──────┬───────┘    └──────┬───────┘      │
│         │                   │                   │               │
│         ▼                   ▼                   ▼               │
│  ┌──────────────────────────────────────────────────────┐      │
│  │                   SQLite Database                     │      │
│  │  ┌──────────┐  ┌──────────┐  ┌──────────────────┐   │      │
│  │  │ Handoffs │  │Signatures│  │ Learnings (FTS5) │   │      │
│  │  └──────────┘  └──────────┘  └──────────────────┘   │      │
│  └──────────────────────────────────────────────────────┘      │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

---

## How It Works

### Session Continuity

When your context window fills up and Claude compacts, your session state is automatically preserved and restored.

```
┌─────────────────────┐
│  Working on task... │
│  Files modified     │
│  Decisions made     │
└─────────┬───────────┘
          │
          ▼
┌─────────────────────┐
│  Context fills up   │
│  PreCompact Hook    │──────────┐
└─────────┬───────────┘          │
          │                      ▼
          │            ┌─────────────────┐
          │            │  Save Handoff   │
          │            │  - Task state   │
          │            │  - Files list   │
          │            │  - Decisions    │
          │            │  - Last action  │
          │            └─────────────────┘
          ▼
┌─────────────────────┐
│  Context compacts   │
└─────────┬───────────┘
          │
          ▼
┌─────────────────────┐          ┌─────────────────┐
│  New session starts │◄─────────│  Load Handoff   │
│  SessionStart Hook  │          │  Recall context │
└─────────┬───────────┘          └─────────────────┘
          │
          ▼
┌─────────────────────┐
│  "Continuing:       │
│   Add user auth     │
│   Modified: 3 files │
│   Last: validation" │
└─────────────────────┘
```

**What's Preserved:**
- Current task description
- Files you've modified
- Decisions made during the session
- Todos and blockers
- Last action performed

---

### Token Optimization

Large files are automatically summarized to their signatures (function names, class definitions, interfaces) before being loaded into context.

```
┌────────────────────────────────────────────────────────────────┐
│                        File Read Request                        │
│                     (src/lib/auth.ts - 500 lines)              │
└───────────────────────────────┬────────────────────────────────┘
                                │
                                ▼
                    ┌───────────────────────┐
                    │  File > 100 lines?    │
                    └───────────┬───────────┘
                                │
                    ┌───────────┴───────────┐
                    │ YES                   │ NO
                    ▼                       ▼
        ┌───────────────────┐    ┌───────────────────┐
        │  Check Signature  │    │  Return Full File │
        │      Cache        │    └───────────────────┘
        └─────────┬─────────┘
                  │
        ┌─────────┴─────────┐
        │ HIT              │ MISS
        ▼                   ▼
┌───────────────┐  ┌───────────────────────────┐
│ Return Cached │  │   Tree-sitter Extract     │
│   Signature   │  │   - Functions             │
└───────────────┘  │   - Classes               │
                   │   - Interfaces            │
                   │   - Exports               │
                   └─────────────┬─────────────┘
                                 │
                                 ▼
                   ┌─────────────────────────┐
                   │   Cache & Return        │
                   │   Signature (50 lines)  │
                   │   Token savings: 75%    │
                   └─────────────────────────┘
```

**Supported Languages:**

| Language | Extensions | What's Extracted |
|----------|------------|------------------|
| TypeScript | `.ts`, `.tsx` | Functions, classes, interfaces, types, exports |
| JavaScript | `.js`, `.jsx`, `.mjs`, `.cjs` | Functions, classes, exports |
| Python | `.py` | Functions, classes, methods |

---

### Cross-Session Learning

At the end of each session, meaningful learnings are extracted and stored for future recall.

```
┌─────────────────────────────────────────────────────────────────┐
│                       Session Ends                              │
└───────────────────────────────┬─────────────────────────────────┘
                                │
                                ▼
                    ┌───────────────────────┐
                    │   SessionEnd Hook     │
                    │   Extract learnings   │
                    └───────────┬───────────┘
                                │
                                ▼
┌───────────────────────────────────────────────────────────────┐
│                     Analyze Session                            │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐        │
│  │  Decisions   │  │   Blockers   │  │    Fixes     │        │
│  │    Made      │  │  Encountered │  │    Applied   │        │
│  └──────────────┘  └──────────────┘  └──────────────┘        │
└───────────────────────────────┬───────────────────────────────┘
                                │
                                ▼
                    ┌───────────────────────┐
                    │    Categorize         │
                    │  ┌─────────────────┐  │
                    │  │ pattern         │  │
                    │  │ architecture    │  │
                    │  │ fix             │  │
                    │  │ tip             │  │
                    │  └─────────────────┘  │
                    └───────────┬───────────┘
                                │
                                ▼
                    ┌───────────────────────┐
                    │   Deduplicate &       │
                    │   Store with FTS5     │
                    └───────────────────────┘
```

**Learning Categories:**

| Category | Description | Example |
|----------|-------------|---------|
| **Pattern** | Recurring code patterns | "Uses Zod for validation with custom errors" |
| **Architecture** | Structural decisions | "Database queries use connection pooling" |
| **Fix** | Problem solutions | "Resolved by clearing the Next.js cache" |
| **Tip** | Best practices | "Auth tokens expire after 15 minutes" |

---

## Hook Lifecycle

```
SESSION START ─────────────────────────────────────────────► SESSION END
      │                                                            │
      ▼                                                            ▼
┌──────────────┐                                        ┌──────────────┐
│ session-start│                                        │ session-end  │
│ - Load state │                                        │ - Extract    │
│ - Recall     │                                        │   learnings  │
│   learnings  │                                        │ - Store new  │
└──────────────┘                                        └──────────────┘
      │                                                            ▲
      ▼                                                            │
┌─────────────────────────────────────────────────────────────────┐
│                         WORKING                                  │
│                                                                  │
│  ┌──────────────┐        ┌──────────────┐        ┌────────────┐│
│  │  post-tool   │◄──────►│   pre-read   │        │ pre-compact││
│  │  - Track     │        │  - Signature │        │ - Save     ││
│  │    files     │        │    caching   │        │   handoff  ││
│  │  - Track     │        │  - Token     │        │ - Preserve ││
│  │    decisions │        │    savings   │        │   state    ││
│  └──────────────┘        └──────────────┘        └────────────┘│
│         ▲                       ▲                       ▲       │
│         │                       │                       │       │
│         └───────────────────────┼───────────────────────┘       │
│                                 │                               │
│                          During Session                         │
└─────────────────────────────────────────────────────────────────┘
```

---

## Commands

### /memory-status

Check the memory system status and statistics.

```bash
/memory-status
```

**Output example:**
```
=== Memory System Status ===
Database: .claude/memory/memory.db (156 KB)

Handoffs:      3 saved
Signatures:    12 cached (avg 72% savings)
Learnings:     8 stored

Current Session:
  Task: Implementing user authentication
  Files: 4 modified
  Decisions: 3 made
```

---

### /memory-learnings

View recent learnings accumulated across sessions.

```bash
/memory-learnings
```

**Output example:**
```
=== Recent Learnings ===

1. [pattern] This project uses Zod for validation with custom error messages
   Recalls: 3 | Date: 2026-01-10

2. [architecture] Auth tokens expire after 15 minutes, refresh after 7 days
   Recalls: 2 | Date: 2026-01-10

3. [fix] Database connection issue resolved by increasing pool timeout
   Recalls: 1 | Date: 2026-01-09

Total learnings: 8
```

**Search learnings:**
```
"What have I learned about authentication?"
```

---

## File Locations

```
project/
└── .claude/
    └── memory/
        ├── memory.db           # SQLite database (WAL mode)
        └── session-state.json  # Current session state
```

---

## Requirements

- **Node.js 18+** - For hook execution
- **Dependencies** - Installed automatically on first use

---

## Troubleshooting

### Memory not working?

```bash
# 1. Check Node.js version
node --version  # Should be 18+

# 2. Install dependencies
cd .claude/plugins/mannay-claude-code/memory && npm install

# 3. Verify database
ls -la .claude/memory/
```

### Signatures not caching?

| Issue | Solution |
|-------|----------|
| Small files | Only files >100 lines are cached |
| Unsupported language | Only .ts, .js, .py supported |
| Missing Tree-sitter | Run `npm install` in memory folder |

### Learnings not accumulating?

| Issue | Solution |
|-------|----------|
| Short session | Need >3 actions to extract learnings |
| No decisions | Simple file reads don't generate learnings |
| Abnormal termination | Session must end normally |

---

## Privacy

All memory data is stored locally in your project's `.claude/memory/` directory. Nothing is sent externally.

**To exclude from git:**
```bash
echo ".claude/memory/" >> .gitignore
```
