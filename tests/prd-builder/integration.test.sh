#!/bin/bash
set -e

echo "Running PRD Builder integration tests..."

TESTS_PASSED=0
TESTS_FAILED=0

# Test 1: Skill files exist
echo "Test 1: Skill structure..."
if [ -f "skills/prd-builder/SKILL.md" ] && \
   [ -f "skills/prd-builder/README.md" ] && \
   [ -f "skills/prd-builder/templates/prd-schema.json" ]; then
    echo "  ✅ Skill structure complete"
    ((TESTS_PASSED++))
else
    echo "  ❌ Skill structure incomplete"
    ((TESTS_FAILED++))
fi

# Test 2: Command exists
echo "Test 2: Command structure..."
if [ -f "commands/ralph/ralph-build.md" ]; then
    echo "  ✅ Command exists"
    ((TESTS_PASSED++))
else
    echo "  ❌ Command missing"
    ((TESTS_FAILED++))
fi

# Test 3: JSON schema is valid
echo "Test 3: JSON schema validation..."
if jq empty skills/prd-builder/templates/prd-schema.json 2>/dev/null; then
    echo "  ✅ JSON schema valid"
    ((TESTS_PASSED++))
else
    echo "  ❌ JSON schema invalid"
    ((TESTS_FAILED++))
fi

# Test 4: Plugin registration
echo "Test 4: Plugin registration..."
if jq -e '.skills[] | select(.name == "prd-builder")' .claude-plugin/plugin.json >/dev/null && \
   jq -e '.commands[] | select(.name == "ralph-build")' .claude-plugin/plugin.json >/dev/null; then
    echo "  ✅ Plugin registration complete"
    ((TESTS_PASSED++))
else
    echo "  ❌ Plugin registration incomplete"
    ((TESTS_FAILED++))
fi

# Test 5: Documentation updated
echo "Test 5: Documentation..."
if grep -q "prd-builder" README.md && \
   grep -q "ralph-build" CHEATSHEET.md && \
   grep -q "PRD Creation" WORKFLOWS.md; then
    echo "  ✅ Documentation updated"
    ((TESTS_PASSED++))
else
    echo "  ❌ Documentation incomplete"
    ((TESTS_FAILED++))
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Integration Test Summary"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Passed: $TESTS_PASSED"
echo "Failed: $TESTS_FAILED"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if [ $TESTS_FAILED -eq 0 ]; then
    echo "✅ All integration tests passed"
    exit 0
else
    echo "❌ Some integration tests failed"
    exit 1
fi
