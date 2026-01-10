---
name: memory-learnings
description: Show recent learnings from the memory system
triggers:
  - "show learnings"
  - "memory learnings"
  - "what have I learned"
---

# Memory Learnings

Display recent learnings stored in the Compound Memory System.

## Instructions

Run this command to see recent learnings:

```bash
cd "${CLAUDE_PROJECT_ROOT}/.claude/memory" 2>/dev/null

if [ -f memory.db ]; then
  echo "=== Recent Learnings ==="
  echo ""

  sqlite3 -header -column memory.db "
    SELECT
      substr(content, 1, 80) || CASE WHEN length(content) > 80 THEN '...' ELSE '' END as learning,
      tags,
      recall_count as recalls,
      date(created_at) as date
    FROM learnings
    ORDER BY created_at DESC
    LIMIT 10
  " 2>/dev/null || echo "No learnings found."

  echo ""
  total=$(sqlite3 memory.db "SELECT COUNT(*) FROM learnings" 2>/dev/null || echo "0")
  echo "Total learnings: $total"
else
  echo "Memory database not found."
fi
```

## Search Learnings

To search for specific learnings:

```bash
cd "${CLAUDE_PROJECT_ROOT}/.claude/memory" 2>/dev/null

if [ -f memory.db ]; then
  # Replace SEARCH_TERM with your search query
  sqlite3 -header -column memory.db "
    SELECT
      l.content,
      l.tags,
      l.recall_count
    FROM learnings l
    JOIN learnings_fts ON l.id = learnings_fts.rowid
    WHERE learnings_fts MATCH 'SEARCH_TERM*'
    LIMIT 5
  " 2>/dev/null
fi
```

## Usage

- `/memory-learnings` - Show 10 most recent learnings
- Ask "what have I learned about [topic]" to search specific learnings
