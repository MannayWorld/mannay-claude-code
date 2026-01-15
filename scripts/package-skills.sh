#!/bin/bash
# Package skills for distribution

set -e

SKILLS_DIR="skills"
DIST_DIR="dist/skills"

# Create dist directory
mkdir -p "$DIST_DIR"

echo "Packaging skills for distribution..."

for skill_dir in "$SKILLS_DIR"/*/; do
    skill_name=$(basename "$skill_dir")

    # Skip if no SKILL.md
    if [ ! -f "${skill_dir}SKILL.md" ]; then
        echo "⚠ Skipping $skill_name (no SKILL.md)"
        continue
    fi

    # Create zip
    zip_file="$DIST_DIR/${skill_name}.zip"

    # Package skill (exclude node_modules, .git, dist)
    (cd "$SKILLS_DIR" && zip -r "../$zip_file" "$skill_name" \
        -x "*.git*" \
        -x "*node_modules/*" \
        -x "*dist/*" \
        -x "*.DS_Store")

    echo "✓ Packaged $skill_name → $zip_file"
done

echo ""
echo "Done! Packages available in $DIST_DIR/"
ls -la "$DIST_DIR"
