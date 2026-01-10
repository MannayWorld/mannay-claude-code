#!/usr/bin/env bash
# PreToolUse(Read) hook - intercepts reads for signature caching
# Part of the Compound Memory System

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)"
PLUGIN_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
MEMORY_DIR="${PLUGIN_ROOT}/memory"

# Check if Node.js is available
if ! command -v node &> /dev/null; then
    echo '{"decision": "allow", "message": "Node.js not available"}'
    exit 0
fi

# Check if memory module is installed
if [ ! -d "${MEMORY_DIR}/node_modules" ]; then
    echo '{"decision": "allow", "message": "Memory module not installed"}'
    exit 0
fi

# Run the Node.js handler
cat | node "${MEMORY_DIR}/hooks/pre-read.js" 2>/dev/null || echo '{"decision": "allow", "error": "Handler failed"}'
