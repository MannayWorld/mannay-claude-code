#!/usr/bin/env bash
# Ralph Mode Integration Tests
# Tests all components of Ralph Mode implementation

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Test counters
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0

# Base directory
BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

# Helper functions
print_test_header() {
    echo -e "\n${YELLOW}Running: $1${NC}"
}

assert_file_exists() {
    TESTS_RUN=$((TESTS_RUN + 1))
    if [[ -f "$1" ]]; then
        echo -e "${GREEN}✓${NC} File exists: $1"
        TESTS_PASSED=$((TESTS_PASSED + 1))
        return 0
    else
        echo -e "${RED}✗${NC} File missing: $1"
        TESTS_FAILED=$((TESTS_FAILED + 1))
        return 1
    fi
}

assert_file_executable() {
    TESTS_RUN=$((TESTS_RUN + 1))
    if [[ -x "$1" ]]; then
        echo -e "${GREEN}✓${NC} File is executable: $1"
        TESTS_PASSED=$((TESTS_PASSED + 1))
        return 0
    else
        echo -e "${RED}✗${NC} File is not executable: $1"
        TESTS_FAILED=$((TESTS_FAILED + 1))
        return 1
    fi
}

assert_contains() {
    TESTS_RUN=$((TESTS_RUN + 1))
    local file="$1"
    local pattern="$2"
    local description="$3"

    if grep -q "$pattern" "$file"; then
        echo -e "${GREEN}✓${NC} $description"
        TESTS_PASSED=$((TESTS_PASSED + 1))
        return 0
    else
        echo -e "${RED}✗${NC} $description (pattern not found: $pattern)"
        TESTS_FAILED=$((TESTS_FAILED + 1))
        return 1
    fi
}

assert_json_valid() {
    TESTS_RUN=$((TESTS_RUN + 1))
    local file="$1"

    if command -v jq >/dev/null 2>&1; then
        if jq . "$file" >/dev/null 2>&1; then
            echo -e "${GREEN}✓${NC} Valid JSON: $file"
            TESTS_PASSED=$((TESTS_PASSED + 1))
            return 0
        else
            echo -e "${RED}✗${NC} Invalid JSON: $file"
            TESTS_FAILED=$((TESTS_FAILED + 1))
            return 1
        fi
    else
        echo -e "${YELLOW}⊘${NC} jq not installed, skipping JSON validation for $file"
        TESTS_RUN=$((TESTS_RUN - 1))
        return 0
    fi
}

print_summary() {
    echo -e "\n${YELLOW}=== Test Summary ===${NC}"
    echo -e "Tests Run:    $TESTS_RUN"
    echo -e "${GREEN}Tests Passed: $TESTS_PASSED${NC}"
    if [[ $TESTS_FAILED -gt 0 ]]; then
        echo -e "${RED}Tests Failed: $TESTS_FAILED${NC}"
    else
        echo -e "${GREEN}Tests Failed: $TESTS_FAILED${NC}"
    fi

    if [[ $TESTS_FAILED -eq 0 ]]; then
        echo -e "\n${GREEN}✓ All tests passed!${NC}"
        exit 0
    else
        echo -e "\n${RED}✗ Some tests failed${NC}"
        exit 1
    fi
}

# Start tests
echo -e "${YELLOW}=== Ralph Mode Integration Tests ===${NC}"
echo -e "Base directory: $BASE_DIR\n"

# Test 1: Skill file exists
print_test_header "Test 1: Ralph Mode skill file exists"
assert_file_exists "$BASE_DIR/skills/ralph-mode/SKILL.md"

# Test 2: Stop hook exists
print_test_header "Test 2: Stop hook exists"
assert_file_exists "$BASE_DIR/hooks/ralph-stop.sh"
assert_file_executable "$BASE_DIR/hooks/ralph-stop.sh"

# Test 3: Commands exist
print_test_header "Test 3: Ralph commands exist"
assert_file_exists "$BASE_DIR/commands/ralph/ralph-start.md"
assert_file_exists "$BASE_DIR/commands/ralph/ralph-status.md"
assert_file_exists "$BASE_DIR/commands/ralph/ralph-stop.md"

# Test 4: Templates exist
print_test_header "Test 4: Ralph templates exist"
assert_file_exists "$BASE_DIR/scripts/ralph/templates/prd.json"
assert_file_exists "$BASE_DIR/scripts/ralph/templates/progress.txt"

# Test 5: Skill registered in plugin.json
print_test_header "Test 5: Ralph skill registered in plugin.json"
assert_contains "$BASE_DIR/.claude-plugin/plugin.json" "ralph-mode" "Ralph skill is registered"
assert_contains "$BASE_DIR/.claude-plugin/plugin.json" "Autonomous loop execution" "Ralph skill has description"

# Test 6: Commands registered in plugin.json
print_test_header "Test 6: Ralph commands registered in plugin.json"
assert_contains "$BASE_DIR/.claude-plugin/plugin.json" "ralph-start" "ralph-start command registered"
assert_contains "$BASE_DIR/.claude-plugin/plugin.json" "ralph-status" "ralph-status command registered"
assert_contains "$BASE_DIR/.claude-plugin/plugin.json" "ralph-stop" "ralph-stop command registered"

# Test 7: Version updated
print_test_header "Test 7: Plugin version is 1.0.0"
assert_contains "$BASE_DIR/.claude-plugin/plugin.json" '"version": "1.0.0"' "Version is 1.0.0"

# Test 8: JSON files are valid
print_test_header "Test 8: JSON files are valid"
assert_json_valid "$BASE_DIR/.claude-plugin/plugin.json"
assert_json_valid "$BASE_DIR/hooks/hooks.json"
assert_json_valid "$BASE_DIR/scripts/ralph/templates/prd.json"

# Test 9: Stop hook is registered
print_test_header "Test 9: Stop hook is registered in hooks.json"
assert_contains "$BASE_DIR/hooks/hooks.json" "Stop" "Stop hook is registered"
assert_contains "$BASE_DIR/hooks/hooks.json" "ralph-stop.sh" "Stop hook path is correct"

# Test 10: Documentation exists
print_test_header "Test 10: Ralph mode documentation exists"
assert_contains "$BASE_DIR/README.md" "Ralph Mode" "Ralph Mode documented in README"
assert_contains "$BASE_DIR/skills/ralph-mode/SKILL.md" "Autonomous" "SKILL.md contains autonomous description"

# Print summary
print_summary
