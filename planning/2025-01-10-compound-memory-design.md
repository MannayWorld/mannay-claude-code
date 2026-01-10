# Compound Memory System - Design Document

**Date:** 2025-01-10
**Status:** Approved
**Author:** Mannay + Claude

---

## Overview

A continuous learning and context optimization system for mannay-claude-code that provides:
- **90%+ token savings** on file reads via signature caching
- **Seamless session continuity** via automatic handoffs
- **Cross-session learning** via semantic memory recall
- **Zero user setup** - everything works automatically on plugin install

### Philosophy

> "Learn continuously, optimize automatically, zero setup"

Inspired by Continuous-Claude-v3, but without the infrastructure complexity:
- No PostgreSQL required (SQLite + LanceDB files)
- No background daemon (hooks handle everything)
- No Docker setup (pure Node.js)

---

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    COMPOUND MEMORY SYSTEM                    │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐      │
│  │   PARSER     │  │   MEMORY     │  │  CONTINUITY  │      │
│  │              │  │              │  │              │      │
│  │ Tree-sitter  │  │  LanceDB     │  │   SQLite     │      │
│  │ Signatures   │  │  Vectors     │  │   Handoffs   │      │
│  │ 50+ langs    │  │  Semantic    │  │   State      │      │
│  └──────────────┘  └──────────────┘  └──────────────┘      │
│         │                 │                 │               │
│         └────────────────┼─────────────────┘               │
│                          │                                  │
│                  ┌───────▼───────┐                         │
│                  │    HOOKS      │                         │
│                  │               │                         │
│                  │ SessionStart  │                         │
│                  │ PreCompact    │                         │
│                  │ SessionEnd    │                         │
│                  │ PreToolUse    │                         │
│                  └───────────────┘                         │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

---

## Module 1: Parser (Token Savings)

### Purpose
Reduce token consumption by 90%+ when reading files by caching signatures.

### How It Works

```
File Request: "Read src/auth/login.ts" (2000 lines, ~25k tokens)
         ↓
PreToolUse Hook Intercepts
         ↓
Check signature cache in SQLite
         ↓
┌─ Cache HIT ──→ Return signature (50 lines, ~600 tokens) ──→ 97% savings
│
└─ Cache MISS ─→ Run Tree-sitter ─→ Extract signatures ─→ Cache ─→ Return
```

### Technology
- **Tree-sitter** for AST parsing (50+ languages supported)
- **SQLite** for signature cache storage

### Supported Languages (Day 1)

| Language | Tree-sitter Grammar | Priority |
|----------|-------------------|----------|
| TypeScript/JavaScript | tree-sitter-typescript | High |
| Python | tree-sitter-python | High |
| Go | tree-sitter-go | Medium |
| Rust | tree-sitter-rust | Medium |

### Cache Schema

```sql
CREATE TABLE file_signatures (
  path TEXT PRIMARY KEY,
  language TEXT,
  signature TEXT,
  hash TEXT,
  original_tokens INTEGER,
  signature_tokens INTEGER,
  created_at TIMESTAMP,
  accessed_at TIMESTAMP
);
```

---

## Module 2: Memory (Semantic Learning)

### Purpose
Store and recall learnings across sessions with semantic search.

### How It Works

```
Learning Extracted: "JWT refresh tokens should use httpOnly cookies"
         ↓
Generate Embedding (Ollama or Claude Haiku)
         ↓
Store in LanceDB with metadata
         ↓
... new session starts ...
         ↓
User task: "implement authentication"
         ↓
Semantic search: find related learnings
         ↓
Inject: "Previous learning: JWT refresh tokens should use httpOnly cookies"
```

### Technology
- **LanceDB** for vector storage (file-based, no server)
- **Ollama** for local embeddings (with Haiku fallback)

### Embedding Strategy

1. Try Ollama local embeddings (free, fast)
2. Fallback to Claude Haiku keyword extraction (~$0.0005/learning)

### Learning Extraction

Triggered by SessionEnd hook:
```python
def extract_learnings(session_state):
    # Use Haiku to extract learnings
    response = claude.messages.create(
        model="claude-haiku-4",
        messages=[{
            "role": "user",
            "content": f"""Extract 3-5 key learnings from this session:
            Task: {session_state['task']}
            Decisions: {session_state['decisions']}
            Format: One learning per line, actionable and specific."""
        }]
    )
    for learning in response.split('\n'):
        store_learning(learning)
```

---

## Module 3: Continuity (Handoffs & State)

### Purpose
Seamless session continuity - never lose context on compaction.

### How It Works

```
During Session:
  State tracked in real-time → session-state.json

Before Compaction (PreCompact hook):
  State → Handoff → SQLite

After Compaction (SessionStart hook):
  Load handoff → Inject as context → Continue seamlessly
```

### Session State Format

```json
{
  "session_id": "2025-01-10-14-30",
  "task": "Implement user authentication with JWT",
  "status": "in_progress",
  "files_modified": ["src/auth/login.ts"],
  "files_read": ["src/types/user.ts"],
  "decisions": [
    "Using JWT over sessions for stateless auth",
    "Storing refresh token in httpOnly cookie"
  ],
  "todos": [
    {"id": 1, "content": "Add rate limiting", "status": "pending"}
  ],
  "blockers": [],
  "last_action": "Edited src/auth/middleware.ts"
}
```

### Handoff Schema

```sql
CREATE TABLE handoffs (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  session_id TEXT UNIQUE,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  trigger TEXT,
  task TEXT,
  status TEXT,
  state_json TEXT,
  summary TEXT,
  resumed_at TIMESTAMP
);
```

---

## Hooks Integration

### Hook Registry

| Hook | Trigger | Function |
|------|---------|----------|
| SessionStart | startup, resume, compact | Load handoff + recall memories |
| PreCompact | auto, manual | Save handoff to SQLite |
| SessionEnd | session ends | Extract learnings via Haiku |
| PreToolUse(Read) | file read | Check signature cache |
| PostToolUse | Write, Edit, Read, TodoWrite | Track state changes |

---

## File Structure

```
mannay-claude-code/
├── memory/
│   ├── hooks/
│   │   ├── hooks.json
│   │   ├── session-start.js
│   │   ├── session-end.js
│   │   ├── pre-compact.js
│   │   ├── pre-read.js
│   │   └── post-tool-track.js
│   ├── parser/
│   │   ├── extract-signatures.js
│   │   └── languages/
│   ├── store/
│   │   ├── sqlite.js
│   │   ├── lancedb.js
│   │   └── init.js
│   ├── embeddings/
│   │   ├── ollama.js
│   │   ├── haiku.js
│   │   └── index.js
│   └── package.json
└── ... (existing plugin files)
```

### Runtime Data

```
~/.claude/projects/<project-hash>/memory/
├── memory.db              # SQLite
├── vectors.lance/         # LanceDB
├── session-state.json     # Current state
└── signatures/            # Cached signatures
```

---

## Implementation Phases

| Phase | Scope | Effort | Delivers |
|-------|-------|--------|----------|
| **Phase 1** | Continuity | 1-2 days | Handoffs, state tracking, auto-restore |
| **Phase 2** | Token optimization | 2-3 days | Tree-sitter parser, signature cache |
| **Phase 3** | Semantic memory | 2-3 days | LanceDB, learning extraction, recall |
| **Phase 4** | Polish | 1-2 days | Error handling, edge cases, docs |

**Total: ~7-10 days**

---

## Success Metrics

| Metric | Target |
|--------|--------|
| Token reduction | ≥80% on file reads |
| Session continuity | 100% handoff success |
| Learning recall | ≥3 relevant memories per session |
| Setup time | 0 seconds (auto-init) |
| Performance overhead | <100ms per hook |

---

## Dependencies

```json
{
  "dependencies": {
    "tree-sitter": "^0.21.0",
    "tree-sitter-typescript": "^0.21.0",
    "tree-sitter-python": "^0.21.0",
    "better-sqlite3": "^9.0.0",
    "vectordb": "^0.4.0"
  }
}
```

---

## Risk Mitigation

| Risk | Mitigation |
|------|------------|
| Tree-sitter install fails | Fallback to basic line counting |
| LanceDB corrupts | SQLite backup of learnings |
| Ollama not installed | Fallback to Haiku keywords |
| Hook timeout | Async operations |
| Large codebase | Lazy indexing |

---

## Comparison: Continuous-Claude-v3 vs Our Approach

| Feature | Continuous-Claude-v3 | Our Approach |
|---------|---------------------|--------------|
| Token savings | Custom 5-layer AST | Tree-sitter (same result) |
| Semantic search | PostgreSQL + pgvector | LanceDB (file-based) |
| Learning extraction | Background daemon | SessionEnd hook |
| Setup required | Docker + Postgres | None |
| Complexity | High | Low |

**Same outcomes, simpler implementation.**
