---
description: Queue a file for background GPT code review using Codex CLI
---

# GPT Code Review

Queue a file for background GPT review using your ChatGPT subscription via Codex CLI.

## Arguments

$ARGUMENTS

## Usage

```bash
/gpt-review <file> [--security|--performance|--refactor] ["custom prompt"]
```

## Examples

```bash
/gpt-review src/auth.ts --security
/gpt-review src/api/payment.ts --performance
/gpt-review src/utils.ts "Check for edge cases"
/gpt-review src/components/Form.tsx --refactor
```

## Review Types

| Flag | Focus |
|------|-------|
| `--security` | Vulnerabilities, input validation, secrets |
| `--performance` | Bottlenecks, memory leaks, optimization |
| `--refactor` | DRY, naming, structure, clarity |
| (none) | Comprehensive review |

## What to Do

1. **Parse the arguments** to extract:
   - File path (required)
   - Review type flag (optional, default: comprehensive)
   - Custom prompt (optional)

2. **Validate prerequisites:**
   - Check if Codex CLI is installed: `which codex`
   - Check if file exists
   - Check daily usage limit

3. **Show pre-flight warning:**
   ```
   Codex Review Request
   ────────────────────
   File: [filename] ([line count] lines)
   Type: [review type]
   Today's usage: [X]/[limit] reviews

   This will use your ChatGPT subscription.
   Queuing review...
   ```

4. **Run the review directly with Codex:**
   ```bash
   codex "[review prompt based on type]

   File: [filename]
   ```[language]
   [file content]
   ```"
   ```

5. **Save the result** to `.claude/gpt-reviews/YYYY-MM-DD-[filename]-[type].md`

6. **Report completion:**
   ```
   Review complete!
   Results saved to: .claude/gpt-reviews/[filename].md

   Summary:
   [First 10 lines of result]

   Use /gpt-results to see full details.
   ```

## Review Prompts

**Security:**
```
Review this code for security vulnerabilities.
Focus on: input validation, authentication issues, secrets exposure, injection vulnerabilities (SQL, XSS, etc.), insecure dependencies.
Format: List issues with severity (HIGH/MEDIUM/LOW), line numbers, and suggested fixes.
```

**Performance:**
```
Review this code for performance issues.
Focus on: unnecessary computations, memory leaks, N+1 queries, missing caching opportunities, bundle size impact.
Format: List issues with impact level and optimization suggestions.
```

**Refactor:**
```
Review this code for refactoring opportunities.
Focus on: DRY violations, complex conditionals, unclear naming, missing abstractions, code organization.
Format: List suggestions with before/after examples where helpful.
```

## Error Handling

- **Codex not installed:** Show installation instructions
- **File not found:** Error with clear message
- **Daily limit reached:** Show limit and suggest increasing
- **Codex fails:** Show error, suggest retry

## First-Time Setup Message

If Codex CLI is not found:
```
Codex CLI not found. Setup required:

1. Install: npm install -g @openai/codex
2. Authenticate: codex auth
   (Choose "Sign in with ChatGPT")
3. Try again: /gpt-review [file]
```

## Storage

Results are saved to `.claude/gpt-reviews/`:
- `YYYY-MM-DD-[filename]-[type].md` - Full review results
- `usage.json` - Daily usage tracking
