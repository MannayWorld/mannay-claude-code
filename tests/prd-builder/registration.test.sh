#!/bin/bash

# PRD Builder Registration Tests
# Tests the plugin registration for PRD Builder skill and command

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

# Test counter
TESTS_RUN=0
TESTS_PASSED=0

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Test helper functions
assert_file_exists() {
    TESTS_RUN=$((TESTS_RUN + 1))
    if [ -f "$1" ]; then
        echo -e "${GREEN}✓${NC} File exists: $1"
        TESTS_PASSED=$((TESTS_PASSED + 1))
        return 0
    else
        echo -e "${RED}✗${NC} File not found: $1"
        return 1
    fi
}

assert_json_contains() {
    TESTS_RUN=$((TESTS_RUN + 1))
    local file=$1
    local jq_query=$2
    local expected=$3

    if ! command -v jq &> /dev/null; then
        echo -e "${RED}✗${NC} jq not installed, skipping test: $jq_query"
        return 1
    fi

    local actual=$(jq -r "$jq_query" "$file" 2>/dev/null)
    if [ "$actual" = "$expected" ]; then
        echo -e "${GREEN}✓${NC} JSON contains: $jq_query = $expected"
        TESTS_PASSED=$((TESTS_PASSED + 1))
        return 0
    else
        echo -e "${RED}✗${NC} JSON mismatch: $jq_query"
        echo "  Expected: $expected"
        echo "  Actual:   $actual"
        return 1
    fi
}

assert_json_array_contains() {
    TESTS_RUN=$((TESTS_RUN + 1))
    local file=$1
    local jq_query=$2
    local expected_item=$3

    if ! command -v jq &> /dev/null; then
        echo -e "${RED}✗${NC} jq not installed, skipping test"
        return 1
    fi

    if jq -e "$jq_query | any(. == \"$expected_item\")" "$file" &> /dev/null; then
        echo -e "${GREEN}✓${NC} JSON array contains: $expected_item"
        TESTS_PASSED=$((TESTS_PASSED + 1))
        return 0
    else
        echo -e "${RED}✗${NC} JSON array does not contain: $expected_item"
        return 1
    fi
}

# Test 1: plugin.json exists
echo "Test 1: plugin.json file exists"
assert_file_exists "$PROJECT_ROOT/.claude-plugin/plugin.json"

# Test 2: Version is 1.0.0
echo ""
echo "Test 2: Plugin version is 1.0.0"
assert_json_contains "$PROJECT_ROOT/.claude-plugin/plugin.json" ".version" "1.0.0"

# Test 3: PRD Builder skill is registered
echo ""
echo "Test 3: prd-builder skill is registered"
if command -v jq &> /dev/null; then
    TESTS_RUN=$((TESTS_RUN + 1))
    if jq -e '.skills[] | select(.name == "prd-builder")' "$PROJECT_ROOT/.claude-plugin/plugin.json" &> /dev/null; then
        echo -e "${GREEN}✓${NC} prd-builder skill is registered"
        TESTS_PASSED=$((TESTS_PASSED + 1))
    else
        echo -e "${RED}✗${NC} prd-builder skill is not registered"
    fi
fi

# Test 4: ralph-build command is registered
echo ""
echo "Test 4: ralph-build command is registered"
if command -v jq &> /dev/null; then
    TESTS_RUN=$((TESTS_RUN + 1))
    if jq -e '.commands[] | select(.name == "ralph-build")' "$PROJECT_ROOT/.claude-plugin/plugin.json" &> /dev/null; then
        echo -e "${GREEN}✓${NC} ralph-build command is registered"
        TESTS_PASSED=$((TESTS_PASSED + 1))
    else
        echo -e "${RED}✗${NC} ralph-build command is not registered"
    fi
fi

# Test 5: Skill file exists at correct path
echo ""
echo "Test 5: prd-builder skill file exists at root-level path"
TESTS_RUN=$((TESTS_RUN + 1))
if [ -f "$PROJECT_ROOT/skills/prd-builder/SKILL.md" ]; then
    echo -e "${GREEN}✓${NC} prd-builder skill file exists at skills/prd-builder/SKILL.md"
    TESTS_PASSED=$((TESTS_PASSED + 1))
else
    echo -e "${RED}✗${NC} prd-builder skill file not found at skills/prd-builder/SKILL.md"
fi

# Test 6: Command file exists at correct path
echo ""
echo "Test 6: ralph-build command file exists at root-level path"
TESTS_RUN=$((TESTS_RUN + 1))
if [ -f "$PROJECT_ROOT/commands/ralph/ralph-build.md" ]; then
    echo -e "${GREEN}✓${NC} ralph-build command file exists at commands/ralph/ralph-build.md"
    TESTS_PASSED=$((TESTS_PASSED + 1))
else
    echo -e "${RED}✗${NC} ralph-build command file not found at commands/ralph/ralph-build.md"
fi

# Summary
echo ""
echo "=================================="
echo "Tests passed: $TESTS_PASSED/$TESTS_RUN"
if [ $TESTS_PASSED -eq $TESTS_RUN ]; then
    echo -e "${GREEN}All registration tests passed!${NC}"
    exit 0
else
    echo -e "${RED}Some registration tests failed.${NC}"
    exit 1
fi
