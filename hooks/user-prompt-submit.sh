#!/usr/bin/env bash
# UserPromptSubmit hook for Mannay plugin
# Forces skill evaluation BEFORE every response for 84% activation reliability

set -euo pipefail

# Output JSON with forced evaluation instruction
cat <<'EOF'
{
  "hookSpecificOutput": {
    "hookEventName": "UserPromptSubmit",
    "additionalContext": "<CRITICAL-INSTRUCTION>\n\n**BEFORE responding to the user's message, you MUST complete this 3-step process:**\n\n## Step 1: Evaluate Each Skill\n\nFor each Mannay skill, answer YES or NO with brief reasoning:\n\n- **mannay:test-driven-development**: Does this involve writing/modifying code?\n- **mannay:systematic-debugging**: Is this a bug report, error, or unexpected behavior?\n- **mannay:brainstorming**: Is this a new feature, design decision, or creative work?\n- **mannay:task-analysis**: Did user provide a task to implement with /new-task?\n- **mannay:feature-planning**: Is this feature planning with /feature-plan?\n- **mannay:writing-plans**: Do we have requirements and need detailed implementation plan?\n- **mannay:executing-plans**: Is there an existing plan to execute?\n- **mannay:requesting-code-review**: Should code be reviewed before proceeding?\n- **mannay:api-testing**: Is this about testing an API endpoint?\n\n## Step 2: Activate Matching Skills\n\n**CRITICAL:** The evaluation in Step 1 is WORTHLESS unless you ACTIVATE the skills here.\n\nFor each skill that got YES in Step 1, you MUST use the Skill tool:\n```\nSkill(\"mannay:skill-name\")\n```\n\n## Step 3: Proceed with Implementation\n\nONLY after completing Steps 1-2, proceed with the user's request following the activated skill's instructions.\n\n---\n\n**Why this matters:** Without forced evaluation, skills activate only ~20% of the time. With this process, activation rate is ~84%.\n\n**If no skills apply:** Say \"No skills match this request\" and proceed directly.\n\n</CRITICAL-INSTRUCTION>"
  }
}
EOF

exit 0
