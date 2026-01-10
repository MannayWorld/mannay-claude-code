# Codex Background Agent Integration

> **For Claude:** REQUIRED SUB-SKILL: Use mannay:writing-plans to create implementation plan after design approval.

**Goal:** Enable background GPT code reviews using user's existing ChatGPT subscription via Codex CLI as MCP server.

**The Job:** Let users get a "second opinion" from GPT on their code without leaving Claude Code, using their existing ChatGPT subscription (no extra API cost).

---

## Overview

This feature adds optional Codex CLI integration to mannay-claude-code, allowing users to queue background code reviews that run asynchronously while they continue working with Claude.

### Key Benefits

- **No extra cost** - Uses existing ChatGPT subscription via Codex CLI
- **Non-blocking** - Reviews run in background, results available when ready
- **Dual-AI perspective** - Get different insights from GPT's analysis
- **User-controlled** - Opt-in only, configurable limits

---

## Architecture

```
┌─────────────────────────────────────────────────────────────────────┐
│                        Claude Code Session                          │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│  User: /gpt-review src/auth.ts --security                          │
│                                                                     │
│         │                                                           │
│         ▼                                                           │
│  ┌──────────────────┐                                              │
│  │  Pre-flight      │                                              │
│  │  - Check limits  │                                              │
│  │  - Show warning  │                                              │
│  │  - Confirm queue │                                              │
│  └────────┬─────────┘                                              │
│           │                                                         │
│           ▼                                                         │
│  ┌──────────────────┐      ┌──────────────────────────────────┐   │
│  │  Review Queue    │─────►│  Background Process              │   │
│  │  (SQLite)        │      │  ┌────────────────────────────┐  │   │
│  │                  │      │  │  Codex MCP Server          │  │   │
│  │  - file path     │      │  │  (codex mcp-server)        │  │   │
│  │  - review type   │      │  │                            │  │   │
│  │  - custom prompt │      │  │  Uses: ChatGPT subscription│  │   │
│  │  - status        │      │  └────────────────────────────┘  │   │
│  │  - result        │      └──────────────────────────────────┘   │
│  └──────────────────┘                                              │
│                                                                     │
│  User: /gpt-status                                                 │
│  > 2 reviews complete, 1 pending                                   │
│                                                                     │
│  User: /gpt-results                                                │
│  > Summary inline + full details in .claude/gpt-reviews/           │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

---

## Design Decisions

| Aspect | Decision | Rationale |
|--------|----------|-----------|
| **Trigger** | User-initiated only | Prevents accidental subscription usage |
| **Usage visibility** | Pre-flight warning + local tracking | User always knows what they're spending |
| **Background execution** | Queue multiple reviews | Non-blocking, batch results |
| **Review focus** | Specialized flags + custom prompts | Flexibility for different needs |
| **Results presentation** | Summary inline + full saved to file | Quick overview + deep dive option |

---

## Commands

### `/gpt-review <file> [options]`

Queue a file for GPT review.

**Syntax:**
```bash
/gpt-review <file> [--security|--performance|--refactor|--all] ["custom prompt"]
```

**Examples:**
```bash
/gpt-review src/auth.ts --security
/gpt-review src/api/payment.ts --security --performance
/gpt-review src/utils.ts "Check for edge cases in error handling"
/gpt-review src/components/Form.tsx --refactor "Focus on accessibility"
```

**Flags:**
| Flag | Focus Area |
|------|------------|
| `--security` | Vulnerabilities, input validation, secrets exposure |
| `--performance` | Bottlenecks, memory leaks, optimization opportunities |
| `--refactor` | Code clarity, DRY violations, naming, structure |
| `--all` | Comprehensive review (all areas) |

**Pre-flight Output:**
```
Codex Review Request
────────────────────
File: src/auth.ts (142 lines)
Type: Security review
Today's usage: 3/10 reviews

This will use your ChatGPT subscription.
Queue this review? (y/n)
```

### `/gpt-status`

Check queue status.

**Output:**
```
Codex Review Queue
──────────────────
Completed: 2
Pending: 1
Failed: 0

Today's usage: 4/10 reviews

Recent:
✓ src/auth.ts (security) - 2 min ago
✓ src/api/users.ts (performance) - 5 min ago
◷ src/components/Form.tsx (refactor) - processing...
```

### `/gpt-results [file]`

Get review results.

**Without file (all results):**
```
Codex Review Results
────────────────────

## src/auth.ts (Security Review)
⚠️ 2 issues found

1. [HIGH] Password comparison uses timing-unsafe equality
   Line 45: if (password === storedHash)
   Fix: Use crypto.timingSafeEqual()

2. [MEDIUM] JWT secret loaded from environment without validation
   Line 12: const secret = process.env.JWT_SECRET
   Fix: Add validation and fallback handling

Full details: .claude/gpt-reviews/2026-01-10-auth-security.md

## src/api/users.ts (Performance Review)
✓ No major issues found

Minor suggestions saved to: .claude/gpt-reviews/2026-01-10-users-performance.md
```

**With file:**
```bash
/gpt-results src/auth.ts
```
Opens the full review file.

---

## Configuration

### Settings (`.claude/settings.json`)

```json
{
  "codex_integration": {
    "enabled": false,
    "daily_limit": 10,
    "auto_confirm": false,
    "save_reviews": true,
    "review_directory": ".claude/gpt-reviews"
  }
}
```

| Setting | Default | Description |
|---------|---------|-------------|
| `enabled` | `false` | Must be explicitly enabled |
| `daily_limit` | `10` | Max reviews per day (0 = unlimited) |
| `auto_confirm` | `false` | Skip pre-flight confirmation |
| `save_reviews` | `true` | Save full results to files |
| `review_directory` | `.claude/gpt-reviews` | Where to save review files |

### First-Time Setup

When user first runs `/gpt-review` with Codex not configured:

```
Codex Integration Setup
───────────────────────

This feature uses Codex CLI with your ChatGPT subscription.

Setup steps:
1. Install Codex CLI: npm install -g @openai/codex
2. Authenticate: codex auth
   (Choose "Sign in with ChatGPT")
3. Enable in settings: Add "codex_integration": { "enabled": true }

Run /gpt-review again after setup.
```

---

## File Storage

```
project/
└── .claude/
    ├── settings.json          # Codex settings
    └── gpt-reviews/
        ├── queue.json         # Review queue state
        ├── usage.json         # Daily usage tracking
        └── 2026-01-10-auth-security.md
        └── 2026-01-10-users-performance.md
```

### Queue State (`queue.json`)

```json
{
  "reviews": [
    {
      "id": "abc123",
      "file": "src/auth.ts",
      "type": "security",
      "custom_prompt": null,
      "status": "completed",
      "queued_at": "2026-01-10T14:30:00Z",
      "completed_at": "2026-01-10T14:31:23Z",
      "result_file": "2026-01-10-auth-security.md"
    }
  ]
}
```

### Usage Tracking (`usage.json`)

```json
{
  "2026-01-10": {
    "count": 4,
    "reviews": ["abc123", "def456", "ghi789", "jkl012"]
  }
}
```

---

## Error Handling

| Scenario | Behavior |
|----------|----------|
| Codex not installed | Show setup instructions |
| Codex not authenticated | Prompt to run `codex auth` |
| Daily limit reached | Show warning, suggest tomorrow or increase limit |
| Codex request fails | Retry once, then mark as failed with error |
| File not found | Reject immediately with clear message |
| File too large (>1000 lines) | Warn user, suggest splitting or specific line range |

### Error Messages

**Limit reached:**
```
Daily review limit reached (10/10)

Options:
1. Wait until tomorrow (resets at midnight)
2. Increase limit in settings: "daily_limit": 20
```

**Codex failure:**
```
Review failed: src/auth.ts

Error: Codex request timed out after 60s
Status: Will retry automatically

Check /gpt-status for updates.
```

---

## Implementation Notes

### MCP Server Integration

Codex CLI can run as MCP server:
```bash
codex mcp-server
```

This exposes two tools:
- `codex` - Send prompts to Codex
- `codex-reply` - Continue conversation

### Background Execution

Reviews run via background Task agent:
1. User queues review with `/gpt-review`
2. Background agent spawns with Codex MCP access
3. Agent sends review prompt to Codex
4. Results saved to file
5. Queue status updated

### Review Prompts

**Security prompt template:**
```
Review this code for security vulnerabilities:

File: {filename}
```{language}
{code}
```

Focus on:
- Input validation and sanitization
- Authentication/authorization issues
- Secrets exposure
- Injection vulnerabilities (SQL, XSS, etc.)
- Insecure dependencies

Format: List issues with severity (HIGH/MEDIUM/LOW), line numbers, and fixes.
```

**Performance prompt template:**
```
Review this code for performance issues:

File: {filename}
```{language}
{code}
```

Focus on:
- Unnecessary re-renders or computations
- Memory leaks
- N+1 queries or inefficient data fetching
- Bundle size impact
- Missing caching opportunities

Format: List issues with impact level and optimization suggestions.
```

**Refactor prompt template:**
```
Review this code for refactoring opportunities:

File: {filename}
```{language}
{code}
```

Focus on:
- DRY violations
- Complex conditionals
- Unclear naming
- Missing abstractions
- Code organization

Format: List suggestions with before/after examples.
```

---

## Privacy & Security

- **Local only** - All data stored in `.claude/gpt-reviews/`
- **No telemetry** - No usage data sent anywhere
- **User consent** - Pre-flight confirmation before each review
- **Gitignore recommended** - Add `.claude/gpt-reviews/` to .gitignore

---

## Future Enhancements (Not in V1)

- [ ] Review entire directories
- [ ] Compare Claude vs GPT suggestions
- [ ] Auto-suggest reviews for changed files
- [ ] Integration with PR workflow
- [ ] Custom review templates

---

## Dependencies

- **Codex CLI** - `@openai/codex` (user installs separately)
- **ChatGPT subscription** - For Codex authentication
- **SQLite** - Already used by memory system

---

## Summary

This design enables optional GPT code reviews using the user's existing ChatGPT subscription. Key principles:

1. **User control** - Opt-in, limits, confirmations
2. **Non-blocking** - Background queue, batch results
3. **Flexible** - Specialized flags + custom prompts
4. **Transparent** - Clear usage tracking, saved results
5. **Safe** - Local storage, no external data sharing
