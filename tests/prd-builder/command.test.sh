#!/bin/bash

# PRD Builder Command Tests
# Tests the ralph-build command registration and structure

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

assert_contains() {
    TESTS_RUN=$((TESTS_RUN + 1))
    if grep -q "$2" "$1"; then
        echo -e "${GREEN}✓${NC} File contains: $2"
        TESTS_PASSED=$((TESTS_PASSED + 1))
        return 0
    else
        echo -e "${RED}✗${NC} File does not contain: $2"
        return 1
    fi
}

# Test 1: Command file exists
echo "Test 1: ralph-build command file exists"
assert_file_exists "$PROJECT_ROOT/commands/ralph/ralph-build.md"

# Test 2: Command has frontmatter with name
echo ""
echo "Test 2: Command has name in frontmatter"
assert_contains "$PROJECT_ROOT/commands/ralph/ralph-build.md" "name:"

# Test 3: Command has description
echo ""
echo "Test 3: Command has description"
assert_contains "$PROJECT_ROOT/commands/ralph/ralph-build.md" "description:"

# Test 4: Command has category
echo ""
echo "Test 4: Command has category"
assert_contains "$PROJECT_ROOT/commands/ralph/ralph-build.md" "category:"

# Test 5: Command mentions PRD Builder skill
echo ""
echo "Test 5: Command references PRD Builder skill"
assert_contains "$PROJECT_ROOT/commands/ralph/ralph-build.md" "prd-builder"

# Test 6: Command describes 6-phase workflow
echo ""
echo "Test 6: Command describes workflow phases"
assert_contains "$PROJECT_ROOT/commands/ralph/ralph-build.md" "Phase"

# Summary
echo ""
echo "=================================="
echo "Tests passed: $TESTS_PASSED/$TESTS_RUN"
if [ $TESTS_PASSED -eq $TESTS_RUN ]; then
    echo -e "${GREEN}All command tests passed!${NC}"
    exit 0
else
    echo -e "${RED}Some command tests failed.${NC}"
    exit 1
fi
