#!/usr/bin/env bash
# UserPromptSubmit hook for Mannay plugin
# Lightweight skill suggestions (not forced evaluation)

set -euo pipefail

# Read the user's prompt from stdin
INPUT=$(cat 2>/dev/null || echo '{}')
PROMPT=$(echo "$INPUT" | grep -o '"user_prompt"[[:space:]]*:[[:space:]]*"[^"]*"' | sed 's/.*: *"//' | sed 's/"$//' || echo "")

# Quick keyword detection for relevant skills
SUGGESTIONS=""

# Check for common patterns (case-insensitive)
PROMPT_LOWER=$(echo "$PROMPT" | tr '[:upper:]' '[:lower:]')

if echo "$PROMPT_LOWER" | grep -qE 'bug|fix|error|broken|not working|issue'; then
    SUGGESTIONS="${SUGGESTIONS}→ /fix or systematic-debugging for bugs\n"
fi

if echo "$PROMPT_LOWER" | grep -qE 'commit|push|pr|pull request|merge|branch'; then
    SUGGESTIONS="${SUGGESTIONS}→ git skill for version control\n"
fi

if echo "$PROMPT_LOWER" | grep -qE 'build|create|add|implement|new feature'; then
    SUGGESTIONS="${SUGGESTIONS}→ brainstorming for new features\n"
fi

if echo "$PROMPT_LOWER" | grep -qE 'plan|spec|prd|requirements'; then
    SUGGESTIONS="${SUGGESTIONS}→ writing-plans or feature-planning\n"
fi

# Only inject if we have suggestions
if [ -n "$SUGGESTIONS" ]; then
    cat <<EOF
{
  "hookSpecificOutput": {
    "hookEventName": "UserPromptSubmit",
    "additionalContext": "Skills that may help:\n${SUGGESTIONS}Use if relevant, skip if not."
  }
}
EOF
else
    # No suggestions - return empty (no injection)
    echo '{}'
fi

exit 0
