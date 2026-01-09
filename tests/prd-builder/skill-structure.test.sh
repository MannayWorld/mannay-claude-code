#!/bin/bash

# Test: PRD Builder Skill Structure
# Verifies all required files and directories exist

set -e

TEST_NAME="PRD Builder Skill Structure"
SKILL_DIR="skills/prd-builder"
TEMPLATE_DIR="$SKILL_DIR/templates"

echo "Running: $TEST_NAME"

# Test 1: Check skill directory exists
if [ ! -d "$SKILL_DIR" ]; then
    echo "FAIL: Skill directory does not exist: $SKILL_DIR"
    exit 1
fi
echo "PASS: Skill directory exists"

# Test 2: Check templates directory exists
if [ ! -d "$TEMPLATE_DIR" ]; then
    echo "FAIL: Templates directory does not exist: $TEMPLATE_DIR"
    exit 1
fi
echo "PASS: Templates directory exists"

# Test 3: Check SKILL.md exists
if [ ! -f "$SKILL_DIR/SKILL.md" ]; then
    echo "FAIL: SKILL.md does not exist"
    exit 1
fi
echo "PASS: SKILL.md exists"

# Test 4: Check README.md exists
if [ ! -f "$SKILL_DIR/README.md" ]; then
    echo "FAIL: README.md does not exist"
    exit 1
fi
echo "PASS: README.md exists"

# Test 5: Check story-template.md exists
if [ ! -f "$TEMPLATE_DIR/story-template.md" ]; then
    echo "FAIL: story-template.md does not exist"
    exit 1
fi
echo "PASS: story-template.md exists"

# Test 6: Check prd-schema.json exists
if [ ! -f "$TEMPLATE_DIR/prd-schema.json" ]; then
    echo "FAIL: prd-schema.json does not exist"
    exit 1
fi
echo "PASS: prd-schema.json exists"

# Test 7: Verify SKILL.md has frontmatter
if ! grep -q "^---$" "$SKILL_DIR/SKILL.md"; then
    echo "FAIL: SKILL.md missing frontmatter"
    exit 1
fi
echo "PASS: SKILL.md has frontmatter"

# Test 8: Verify SKILL.md has key sections
if ! grep -q "## How This Works" "$SKILL_DIR/SKILL.md"; then
    echo "FAIL: SKILL.md missing How This Works section"
    exit 1
fi
echo "PASS: SKILL.md has How This Works section"

echo ""
echo "SUCCESS: All tests passed for $TEST_NAME"
