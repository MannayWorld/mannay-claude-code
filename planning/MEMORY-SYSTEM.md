# Compound Memory System

Zero-infrastructure persistent memory for Claude Code sessions.

## Features

### 1. Session Continuity
Automatic state preservation across context compactions:
- **PreCompact Hook**: Saves session state before context window fills
- **SessionStart Hook**: Restores state after compaction
- Tracks: files modified, decisions made, todos, last action

### 2. Token Optimization
Tree-sitter-powered signature extraction for large files:
- **PreToolUse(Read) Hook**: Intercepts file reads
- Extracts function/class/interface signatures
- Caches in SQLite with content hash
- **60-80% token savings** on large files

### 3. Semantic Learning
Cross-session knowledge accumulation:
- **SessionEnd Hook**: Extracts learnings from session
- Categories: patterns, architecture, decisions, fixes, tips
- **FTS5 search** for relevant recall
- Deduplication to avoid redundancy

## Architecture

```
hooks/
├── session-start.sh    # Loads using-mannay + restores memory
├── pre-compact.sh      # Saves handoff before compaction
├── post-tool-track.sh  # Tracks file changes and decisions
├── pre-read.sh         # Signature caching for large files
└── session-end.sh      # Extracts learnings on exit

memory/
├── store/              # SQLite operations
│   ├── init.js         # Database schema
│   └── sqlite.js       # CRUD operations
├── state/              # Session state tracking
│   └── session-state.js
├── parser/             # Tree-sitter parsing
│   ├── languages.js    # Language configs
│   └── extract-signatures.js
├── learning/           # Learning extraction
│   └── extract.js
└── hooks/              # Node.js hook handlers
    ├── pre-compact.js
    ├── session-start.js
    ├── post-tool-track.js
    ├── pre-read.js
    └── session-end.js
```

## Database Schema

```sql
-- Session handoffs (continuity)
handoffs (
  session_id TEXT UNIQUE,
  trigger TEXT,       -- 'auto' or 'manual'
  task TEXT,
  status TEXT,
  state_json TEXT,    -- Full session state
  resumed_at TEXT
)

-- File signatures (token optimization)
file_signatures (
  path TEXT PRIMARY KEY,
  language TEXT,
  signature TEXT,     -- Extracted signature
  hash TEXT,          -- Content hash
  original_tokens INT,
  signature_tokens INT
)

-- Learnings (semantic memory)
learnings (
  content TEXT,
  tags TEXT,
  source_task TEXT,
  recall_count INT
)
```

## Usage

### Automatic (Zero Setup)
The system works automatically through hooks:
1. Session state is tracked as you work
2. Before compaction, state is saved as handoff
3. After compaction, previous session is restored
4. On session end, learnings are extracted

### CLI Commands
- `/memory-status` - Show system statistics
- `/memory-learnings` - Show recent learnings

### Manual Check
```bash
# Check database
cd .claude/memory
sqlite3 memory.db "SELECT COUNT(*) FROM handoffs"
sqlite3 memory.db "SELECT COUNT(*) FROM file_signatures"
sqlite3 memory.db "SELECT COUNT(*) FROM learnings"
```

## Supported Languages

For signature extraction:
- TypeScript (.ts, .tsx)
- JavaScript (.js, .jsx, .mjs, .cjs)
- Python (.py)

## Installation

The memory system is included with mannay-claude-code. Dependencies are installed automatically:

```bash
cd memory && npm install
```

Required: Node.js 18+

## How It Works

### Token Optimization Flow
```
File Read Request
      ↓
PreToolUse(Read) Hook
      ↓
File > 100 lines?
      ↓
Yes → Check signature cache
      ↓
Cache hit? → Return cached signature
      ↓
Cache miss → Extract with Tree-sitter → Cache → Return signature
```

### Session Continuity Flow
```
Working on task...
      ↓
PostToolUse tracks files, decisions
      ↓
Context getting full → PreCompact saves handoff
      ↓
Context compacted
      ↓
SessionStart restores handoff + recalls learnings
      ↓
Continue working...
```

### Learning Extraction Flow
```
Session ends
      ↓
SessionEnd hook fires
      ↓
Extract learnings from decisions/blockers
      ↓
Categorize (pattern, architecture, fix, tip)
      ↓
Deduplicate against existing
      ↓
Save to database with FTS
```

## Performance

- Hook execution: <100ms
- Signature extraction: <500ms
- Token savings: 60-80% on large files
- Database: SQLite with WAL mode for concurrency

## Troubleshooting

### Memory not working?
1. Check Node.js is installed: `node --version`
2. Check dependencies: `cd memory && npm install`
3. Check database: `ls -la .claude/memory/`

### Signatures not caching?
1. File must be >100 lines
2. Must be supported language (.ts, .js, .py)
3. Tree-sitter must be installed

### Learnings not accumulating?
1. Session must have >3 actions
2. Decisions must be meaningful (not just commits)
3. Check SessionEnd hook is configured
