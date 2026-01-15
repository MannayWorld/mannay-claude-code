#!/bin/bash
# Install a skill to Claude Code

set -e

SKILL_NAME="$1"
SKILLS_DIR="skills"
CLAUDE_SKILLS_DIR="$HOME/.claude/skills"

if [ -z "$SKILL_NAME" ]; then
    echo "Usage: ./scripts/install-skill.sh <skill-name>"
    echo ""
    echo "Available skills:"
    ls -1 "$SKILLS_DIR"
    exit 1
fi

if [ ! -d "$SKILLS_DIR/$SKILL_NAME" ]; then
    echo "Error: Skill '$SKILL_NAME' not found in $SKILLS_DIR/"
    exit 1
fi

# Create Claude skills directory if needed
mkdir -p "$CLAUDE_SKILLS_DIR"

# Copy skill
cp -r "$SKILLS_DIR/$SKILL_NAME" "$CLAUDE_SKILLS_DIR/"

echo "✓ Installed $SKILL_NAME to $CLAUDE_SKILLS_DIR/$SKILL_NAME"
echo ""
echo "The skill will be available in your next Claude Code session."
