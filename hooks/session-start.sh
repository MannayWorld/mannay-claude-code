#!/usr/bin/env bash
# SessionStart hook for Mannay plugin

set -euo pipefail

# Determine plugin root directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)"
PLUGIN_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

# Read using-mannay content
using_mannay_content=$(cat "${PLUGIN_ROOT}/skills/using-mannay/SKILL.md" 2>&1 || echo "Error reading using-mannay skill")

# Escape outputs for JSON using pure bash
escape_for_json() {
    local input="$1"
    local output=""
    local i char
    for (( i=0; i<${#input}; i++ )); do
        char="${input:$i:1}"
        case "$char" in
            $'\\') output='\\\\' ;;
            '"') output+='\"' ;;
            $'\n') output+='\n' ;;
            $'\r') output+='\r' ;;
            $'\t') output+='\t' ;;
            *) output+="$char" ;;
        esac
    done
    printf '%s' "$output"
}

using_mannay_escaped=$(escape_for_json "$using_mannay_content")

# Output context injection as JSON
cat <<EOF
{
  "hookSpecificOutput": {
    "hookEventName": "SessionStart",
    "additionalContext": "<EXTREMELY_IMPORTANT>\\nYou have Mannay superpowers.\\n\\n**Below is the full content of your 'mannay:using-mannay' skill - your introduction to all available skills, agents, and commands. For all other tools, use the appropriate method (Skill tool, Task tool, or /command syntax):**\\n\\n${using_mannay_escaped}\\n</EXTREMELY_IMPORTANT>"
  }
}
EOF

exit 0
