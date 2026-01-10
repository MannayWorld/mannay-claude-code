---
name: memory-status
description: Show memory system status and statistics
triggers:
  - "memory status"
  - "show memory stats"
  - "memory info"
---

# Memory Status

Show the current status of the Compound Memory System.

## Instructions

Run this command to check memory system statistics:

```bash
cd "${CLAUDE_PROJECT_ROOT}/.claude/memory" 2>/dev/null || echo "No memory directory found"

if [ -f memory.db ]; then
  echo "=== Memory System Status ==="
  echo ""
  echo "Database: $(du -h memory.db 2>/dev/null | cut -f1)"

  # Count handoffs
  handoffs=$(sqlite3 memory.db "SELECT COUNT(*) FROM handoffs" 2>/dev/null || echo "0")
  echo "Handoffs: $handoffs"

  # Count signatures
  signatures=$(sqlite3 memory.db "SELECT COUNT(*) FROM file_signatures" 2>/dev/null || echo "0")
  echo "Cached Signatures: $signatures"

  # Signature stats
  if [ "$signatures" -gt 0 ]; then
    stats=$(sqlite3 memory.db "SELECT SUM(original_tokens), SUM(signature_tokens) FROM file_signatures" 2>/dev/null)
    original=$(echo "$stats" | cut -d'|' -f1)
    signature=$(echo "$stats" | cut -d'|' -f2)
    if [ -n "$original" ] && [ -n "$signature" ] && [ "$original" -gt 0 ]; then
      savings=$((100 - (signature * 100 / original)))
      echo "Token Savings: ${savings}% (${signature} vs ${original} tokens)"
    fi
  fi

  # Count learnings
  learnings=$(sqlite3 memory.db "SELECT COUNT(*) FROM learnings" 2>/dev/null || echo "0")
  echo "Learnings: $learnings"

  # Session state
  if [ -f session-state.json ]; then
    echo ""
    echo "=== Current Session ==="
    cat session-state.json | node -e "
      let d='';
      process.stdin.on('data', c => d += c);
      process.stdin.on('end', () => {
        try {
          const s = JSON.parse(d);
          console.log('Task:', s.task || 'None');
          console.log('Files Modified:', (s.files_modified || []).length);
          console.log('Decisions:', (s.decisions || []).length);
          console.log('Actions:', s.action_count || 0);
        } catch(e) {}
      });
    " 2>/dev/null
  fi
else
  echo "Memory database not found. It will be created automatically on first use."
fi
```

## Usage

Type `/memory-status` or "show memory stats" to see:
- Database size
- Number of handoffs (session continuity saves)
- Cached file signatures (token optimization)
- Token savings percentage
- Recorded learnings
- Current session state
