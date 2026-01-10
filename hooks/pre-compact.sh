#!/usr/bin/env bash
# PreCompact hook - saves session state before context compaction
# Part of the Compound Memory System

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)"
PLUGIN_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
MEMORY_DIR="${PLUGIN_ROOT}/memory"

# Check if Node.js is available
if ! command -v node &> /dev/null; then
    echo '{"status": "skipped", "message": "Node.js not available"}'
    exit 0
fi

# Check if memory module is installed
if [ ! -d "${MEMORY_DIR}/node_modules" ]; then
    echo '{"status": "skipped", "message": "Memory module not installed. Run: cd memory && npm install"}'
    exit 0
fi

# Run the Node.js handler
cat | node "${MEMORY_DIR}/hooks/pre-compact.js" 2>/dev/null || echo '{"status": "error", "message": "Handler failed"}'
