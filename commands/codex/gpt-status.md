---
description: Check Codex review queue status and daily usage
---

# GPT Review Status

Check the status of your Codex code reviews and daily usage.

## Usage

```bash
/gpt-status
```

## What to Do

1. **Check the reviews directory:** `.claude/gpt-reviews/`

2. **Count reviews by reading files:**
   - Count `.md` files for completed reviews
   - Read `usage.json` for today's usage

3. **Display status:**
   ```
   Codex Review Status
   ───────────────────
   Reviews today: [count]
   Daily limit: [limit]

   Recent reviews:
   - [filename] ([type]) - [date]
   - [filename] ([type]) - [date]
   ```

4. **If no reviews exist:**
   ```
   No Codex reviews yet.

   Start with: /gpt-review <file> --security
   ```

## Reading Usage

Check `.claude/gpt-reviews/usage.json`:
```json
{
  "2026-01-10": { "count": 3 }
}
```

Today's date key gives the count. Default limit is 10.

## Listing Recent Reviews

List `.md` files in `.claude/gpt-reviews/` sorted by date:
```bash
ls -lt .claude/gpt-reviews/*.md 2>/dev/null | head -5
```

Parse filenames: `YYYY-MM-DD-[name]-[type].md`
