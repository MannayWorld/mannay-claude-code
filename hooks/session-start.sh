#!/usr/bin/env bash
# SessionStart hook for Mannay plugin
# Combines: skill loading + memory restoration

set -euo pipefail

# Determine plugin root directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)"
PLUGIN_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
MEMORY_DIR="${PLUGIN_ROOT}/memory"

# Read stdin for matcher info
INPUT=$(cat 2>/dev/null || echo '{}')

# Read using-mannay content
using_mannay_content=$(cat "${PLUGIN_ROOT}/skills/using-mannay/SKILL.md" 2>/dev/null || echo "")

# Try to get memory context
memory_context=""
if command -v node &> /dev/null && [ -d "${MEMORY_DIR}/node_modules" ]; then
    memory_result=$(echo "$INPUT" | node "${MEMORY_DIR}/hooks/session-start.js" 2>/dev/null || echo '{"context": null}')
    # Extract context from JSON result
    memory_context=$(echo "$memory_result" | node -e "
        let d='';
        process.stdin.setEncoding('utf8');
        process.stdin.on('data', c => d += c);
        process.stdin.on('end', () => {
            try {
                const parsed = JSON.parse(d);
                console.log(parsed.context || '');
            } catch(e) {
                console.log('');
            }
        });
    " 2>/dev/null || echo "")
fi

# Escape outputs for JSON using pure bash
escape_for_json() {
    local input="$1"
    local output=""
    local i char
    for (( i=0; i<${#input}; i++ )); do
        char="${input:$i:1}"
        case "$char" in
            $'\\') output+='\\\\' ;;
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
memory_escaped=$(escape_for_json "$memory_context")

# Build combined context
combined_context="<EXTREMELY_IMPORTANT>\\nYou have Mannay superpowers.\\n\\n**Below is the full content of your 'mannay:using-mannay' skill - your introduction to all available skills, agents, and commands. For all other tools, use the appropriate method (Skill tool, Task tool, or /command syntax):**\\n\\n${using_mannay_escaped}\\n</EXTREMELY_IMPORTANT>"

# Add memory context if available
if [ -n "$memory_context" ]; then
    combined_context="${combined_context}\\n\\n${memory_escaped}"
fi

# Output context injection as JSON
cat <<EOF
{
  "hookSpecificOutput": {
    "hookEventName": "SessionStart",
    "additionalContext": "${combined_context}"
  }
}
EOF

exit 0
