---
description: View GPT code review results
---

# GPT Review Results

View the results of your Codex code reviews.

## Usage

```bash
/gpt-results              # Show all recent results
/gpt-results [filename]   # Show specific file's review
```

## Arguments

$ARGUMENTS

## What to Do

### If no filename provided (show all):

1. **List all review files** in `.claude/gpt-reviews/*.md`

2. **For each file, show summary:**
   ```
   Codex Review Results
   ────────────────────

   ## [original-file] ([review-type])
   Date: [date from filename]

   [First 15 lines of content as summary]

   Full details: .claude/gpt-reviews/[filename].md

   ---
   ```

3. **If no results:**
   ```
   No review results found.

   Run a review first: /gpt-review <file> --security
   ```

### If filename provided:

1. **Find matching review file** in `.claude/gpt-reviews/`
   - Match by original filename in the review filename
   - Example: `src/auth.ts` → `*-auth-*.md`

2. **Read and display full content:**
   ```
   [Full content of the review file]
   ```

3. **If not found:**
   ```
   No review found for: [filename]

   Available reviews:
   - [list of review files]
   ```

## File Location

All results stored in: `.claude/gpt-reviews/`

Filename format: `YYYY-MM-DD-[basename]-[type].md`

Example: `2026-01-10-auth-security.md`
