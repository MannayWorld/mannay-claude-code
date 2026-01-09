#!/bin/bash

# PRD Builder Validation Tests
# Tests the quality validation system for PRD generation

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

# Test 1: Validator documentation exists
echo "Test 1: Validator documentation file exists"
assert_file_exists "$PROJECT_ROOT/skills/prd-builder/lib/validator.md"

# Test 2: Validator contains JSON schema validation
echo ""
echo "Test 2: Validator contains JSON schema validation"
assert_contains "$PROJECT_ROOT/skills/prd-builder/lib/validator.md" "jq empty"

# Test 3: Validator contains story atomicity checks
echo ""
echo "Test 3: Validator contains story atomicity checks"
assert_contains "$PROJECT_ROOT/skills/prd-builder/lib/validator.md" "3-7 acceptance criteria"

# Test 4: Validator contains dependency validation
echo ""
echo "Test 4: Validator contains dependency validation"
assert_contains "$PROJECT_ROOT/skills/prd-builder/lib/validator.md" "circular"

# Test 5: Validator contains completion promise validation
echo ""
echo "Test 5: Validator contains completion promise validation"
assert_contains "$PROJECT_ROOT/skills/prd-builder/lib/validator.md" "completion promise"

# Test 6: Validator contains story count recommendations
echo ""
echo "Test 6: Validator contains story count recommendations"
assert_contains "$PROJECT_ROOT/skills/prd-builder/lib/validator.md" "3-20"

# Test 7: Validator contains validation report generation
echo ""
echo "Test 7: Validator contains validation report section"
assert_contains "$PROJECT_ROOT/skills/prd-builder/lib/validator.md" "validation report"

# Test 8: Validator contains error messages
echo ""
echo "Test 8: Validator contains error messages section"
assert_contains "$PROJECT_ROOT/skills/prd-builder/lib/validator.md" "error"

# Summary
echo ""
echo "=================================="
echo "Tests passed: $TESTS_PASSED/$TESTS_RUN"
if [ $TESTS_PASSED -eq $TESTS_RUN ]; then
    echo -e "${GREEN}All validation tests passed!${NC}"
    exit 0
else
    echo -e "${RED}Some validation tests failed.${NC}"
    exit 1
fi
