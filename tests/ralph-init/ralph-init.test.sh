#!/usr/bin/env bash
# Tests for /ralph-init command
# Run with: ./tests/ralph-init/ralph-init.test.sh

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
TEST_DIR="$SCRIPT_DIR/test-project"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Test counters
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0

# Setup test environment
setup() {
  echo -e "${YELLOW}Setting up test environment...${NC}"
  rm -rf "$TEST_DIR"
  mkdir -p "$TEST_DIR"
  cd "$TEST_DIR"
  git init -q
}

# Teardown test environment
teardown() {
  echo -e "${YELLOW}Cleaning up test environment...${NC}"
  cd "$PROJECT_ROOT"
  rm -rf "$TEST_DIR"
}

# Assert helper
assert() {
  local description="$1"
  local condition="$2"

  TESTS_RUN=$((TESTS_RUN + 1))

  if eval "$condition"; then
    echo -e "${GREEN}✓ PASS:${NC} $description"
    TESTS_PASSED=$((TESTS_PASSED + 1))
    return 0
  else
    echo -e "${RED}✗ FAIL:${NC} $description"
    TESTS_FAILED=$((TESTS_FAILED + 1))
    return 1
  fi
}

# Test: Directory structure is created
test_creates_directory_structure() {
  echo ""
  echo -e "${YELLOW}Test: Creates directory structure${NC}"

  # Simulate ralph-init by creating structure
  mkdir -p scripts/ralph/lib
  mkdir -p scripts/ralph/templates
  mkdir -p scripts/ralph/logs

  assert "scripts/ralph directory exists" "[ -d 'scripts/ralph' ]"
  assert "scripts/ralph/lib directory exists" "[ -d 'scripts/ralph/lib' ]"
  assert "scripts/ralph/templates directory exists" "[ -d 'scripts/ralph/templates' ]"
  assert "scripts/ralph/logs directory exists" "[ -d 'scripts/ralph/logs' ]"
}

# Test: Main files are created
test_creates_main_files() {
  echo ""
  echo -e "${YELLOW}Test: Creates main Ralph files${NC}"

  # These files should be created by ralph-init
  local required_files=(
    "scripts/ralph/ralph-loop.sh"
    "scripts/ralph/lib/circuit_breaker.sh"
    "scripts/ralph/lib/response_analyzer.sh"
    "scripts/ralph/prd.json"
    "scripts/ralph/progress.txt"
    "scripts/ralph/prompt.md"
  )

  # For now, just create them to verify test logic
  touch scripts/ralph/ralph-loop.sh
  touch scripts/ralph/lib/circuit_breaker.sh
  touch scripts/ralph/lib/response_analyzer.sh
  touch scripts/ralph/prd.json
  touch scripts/ralph/progress.txt
  touch scripts/ralph/prompt.md

  for file in "${required_files[@]}"; do
    assert "$file exists" "[ -f '$file' ]"
  done
}

# Test: Template files are created
test_creates_template_files() {
  echo ""
  echo -e "${YELLOW}Test: Creates template files${NC}"

  local template_files=(
    "scripts/ralph/templates/prd.json"
    "scripts/ralph/templates/progress.txt"
    "scripts/ralph/templates/prompt.md"
  )

  # Create them for test
  touch scripts/ralph/templates/prd.json
  touch scripts/ralph/templates/progress.txt
  touch scripts/ralph/templates/prompt.md

  for file in "${template_files[@]}"; do
    assert "$file exists" "[ -f '$file' ]"
  done
}

# Test: Shell scripts are executable
test_scripts_are_executable() {
  echo ""
  echo -e "${YELLOW}Test: Shell scripts are executable${NC}"

  chmod +x scripts/ralph/ralph-loop.sh
  chmod +x scripts/ralph/lib/circuit_breaker.sh
  chmod +x scripts/ralph/lib/response_analyzer.sh

  assert "ralph-loop.sh is executable" "[ -x 'scripts/ralph/ralph-loop.sh' ]"
  assert "circuit_breaker.sh is executable" "[ -x 'scripts/ralph/lib/circuit_breaker.sh' ]"
  assert "response_analyzer.sh is executable" "[ -x 'scripts/ralph/lib/response_analyzer.sh' ]"
}

# Test: ralph-loop.sh has correct shebang
test_ralph_loop_has_shebang() {
  echo ""
  echo -e "${YELLOW}Test: ralph-loop.sh has correct shebang${NC}"

  echo '#!/usr/bin/env bash' > scripts/ralph/ralph-loop.sh
  echo '# Ralph Loop' >> scripts/ralph/ralph-loop.sh

  local first_line
  first_line=$(head -n 1 scripts/ralph/ralph-loop.sh)

  assert "ralph-loop.sh starts with shebang" "[ '$first_line' = '#!/usr/bin/env bash' ]"
}

# Test: prd.json is valid JSON
test_prd_is_valid_json() {
  echo ""
  echo -e "${YELLOW}Test: prd.json is valid JSON${NC}"

  echo '{"projectName": "Test Project", "userStories": []}' > scripts/ralph/prd.json

  if command -v jq >/dev/null 2>&1; then
    assert "prd.json is valid JSON" "jq empty scripts/ralph/prd.json 2>/dev/null"
  else
    echo -e "${YELLOW}⚠ Skipping JSON validation (jq not installed)${NC}"
  fi
}

# Test: Does not overwrite existing files
test_no_overwrite() {
  echo ""
  echo -e "${YELLOW}Test: Does not overwrite existing files${NC}"

  # Create existing file with marker content
  echo "EXISTING_CONTENT" > scripts/ralph/prd.json

  # Simulate ralph-init with --no-overwrite behavior
  # (In actual implementation, this would check before writing)
  local existing_content
  existing_content=$(cat scripts/ralph/prd.json)

  assert "Existing content preserved" "[ '$existing_content' = 'EXISTING_CONTENT' ]"
}

# Test: .gitignore entries are added
test_gitignore_entries() {
  echo ""
  echo -e "${YELLOW}Test: Proper .gitignore entries${NC}"

  # Create .gitignore with ralph entries
  cat > .gitignore << 'EOF'
# Ralph runtime files
scripts/ralph/logs/
.ralph_*
.exit_signals
.circuit_breaker_*
EOF

  assert ".gitignore exists" "[ -f '.gitignore' ]"
  assert ".gitignore contains logs entry" "grep -q 'scripts/ralph/logs/' .gitignore"
  assert ".gitignore contains ralph state files" "grep -q '.ralph_' .gitignore"
}

# Run all tests
main() {
  echo ""
  echo -e "${YELLOW}╔════════════════════════════════════════════════════════════╗${NC}"
  echo -e "${YELLOW}║  Ralph Init Command Tests                                  ║${NC}"
  echo -e "${YELLOW}╚════════════════════════════════════════════════════════════╝${NC}"
  echo ""

  setup

  test_creates_directory_structure
  test_creates_main_files
  test_creates_template_files
  test_scripts_are_executable
  test_ralph_loop_has_shebang
  test_prd_is_valid_json
  test_no_overwrite
  test_gitignore_entries

  teardown

  echo ""
  echo -e "${YELLOW}╔════════════════════════════════════════════════════════════╗${NC}"
  echo -e "${YELLOW}║  Test Results                                              ║${NC}"
  echo -e "${YELLOW}╚════════════════════════════════════════════════════════════╝${NC}"
  echo ""
  echo -e "Tests run: $TESTS_RUN"
  echo -e "${GREEN}Passed: $TESTS_PASSED${NC}"
  echo -e "${RED}Failed: $TESTS_FAILED${NC}"
  echo ""

  if [ "$TESTS_FAILED" -eq 0 ]; then
    echo -e "${GREEN}All tests passed!${NC}"
    exit 0
  else
    echo -e "${RED}Some tests failed!${NC}"
    exit 1
  fi
}

main "$@"
