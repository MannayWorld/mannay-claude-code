# PRD Builder

Interactive PRD generation workflow for Ralph mode.

Transforms vague ideas into Ralph-ready JSON PRDs with atomic user stories.

## Quick Start

```bash
# Trigger the skill
"Build a PRD for [feature name]"

# Or explicitly
"Use prd-builder skill for user authentication feature"
```

## What This Does

6-phase interactive workflow:
1. Requirements Discovery (requirements-analyst)
2. Design Exploration (brainstorming)
3. Technical Planning (feature-planning)
4. Story Decomposition (atomic stories, 2-5 min each)
5. PRD Generation (Ralph JSON format)
6. Quality Validation (schema + atomicity checks)

**Output:** `scripts/ralph/prd.json` ready for `/ralph-start`

## See SKILL.md

Read `skills/prd-builder/SKILL.md` for complete documentation.
