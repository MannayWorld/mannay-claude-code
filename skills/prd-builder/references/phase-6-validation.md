# Phase 6: Quality Validation

**Objective:** Validate PRD meets all quality standards before Ralph execution.

## Validation Checks

### 1. JSON Schema Validation

```bash
# Validate JSON is well-formed
jq empty scripts/ralph/prd.json
```

Expected: No errors

### 2. Story Atomicity Check

For each story, verify:

| Check | Criteria |
|-------|----------|
| Acceptance criteria count | 3-7 items (not < 3 or > 10) |
| Title format | Contains verb + noun + context |
| Description format | "As a [role], I want to [action] so I can [benefit]" |
| Test coverage | Has >= 80% or >= 85% requirement |
| Type safety | Has TypeScript requirement |
| Linting | Has lint requirement |
| Priority | Assigned (1-4) |
| Dependencies | Documented if any |

### 3. Dependency Validation

- No circular dependencies (US-001 depends on US-002, US-002 depends on US-001)
- All referenced dependencies exist (US-005 depends on US-999 that doesn't exist)
- Priority ordering respects dependencies (high-priority story depends on low-priority)

### 4. Completion Criteria Check

- `completionPromise` is exactly `<promise>COMPLETE</promise>`
- `maxIterations` is set (recommended: 20-50)
- Quality gates defined

### 5. Story Count Check

From Anthropic guidance and best practices:

| Count | Status | Action |
|-------|--------|--------|
| < 3 | Warning | Consider if Ralph is necessary (might be too small) |
| 3-20 | Ideal | Proceed with Ralph execution |
| > 20 | Warning | Consider breaking into multiple PRDs or phases |

## Validation Report Template

```markdown
## PRD Validation Report

**Project:** [name]
**Total Stories:** [N]
**Date:** [YYYY-MM-DD]

### Passed Checks
- JSON schema valid
- All stories atomic (3-7 acceptance criteria)
- No circular dependencies
- Completion promise correct
- Quality gates defined

### Warnings
- [Any warnings, e.g., "20+ stories, consider splitting"]

### Errors
- [Any errors that must be fixed]

### Recommendations
- [Suggestions for improvement]

**Status:** READY FOR RALPH / NEEDS REVISION
```

## Supporting Files Generation

### 1. Create progress.txt

```bash
cp scripts/ralph/templates/progress.txt scripts/ralph/progress.txt
```

Or create new:

```markdown
# Ralph Progress

## Current Story
[Will be updated by Ralph]

## Completed Stories
[List of completed US-XXX]

## Codebase Patterns
[Patterns discovered during execution]

## Learnings
[Insights from implementation]
```

### 2. Create AGENTS.md (if doesn't exist)

```bash
cp scripts/ralph/templates/AGENTS.md scripts/ralph/AGENTS.md
```

### 3. Create prompt.md (Ralph execution prompt)

```markdown
# Ralph Execution Prompt

You are Ralph, executing the PRD at `scripts/ralph/prd.json`.

## Instructions

1. Read `scripts/ralph/prd.json`
2. Read `scripts/ralph/progress.txt` (check Codebase Patterns section first)
3. Read `scripts/ralph/AGENTS.md` (if exists)
4. Select highest priority story where `passes: false`
5. Implement that ONE story using TDD
6. Run tests - must pass with coverage >= 85%
7. Run linting - must pass with 0 errors
8. Commit with message: `feat: [STORY_ID] - [Story Title]`
9. Update `prd.json`: set story's `passes: true`
10. Append learnings to `progress.txt`

When ALL stories have `passes: true`, output exactly:

<promise>COMPLETE</promise>
```

Save to `scripts/ralph/prompt.md`

## Error Handling

### If JSON Invalid
- Show syntax error location
- Suggest fix
- Re-generate affected section

### If Story Too Large
- Identify stories with > 10 acceptance criteria
- Apply decomposition techniques
- Split into smaller stories

### If Circular Dependencies
- Show dependency graph
- Ask user to clarify order
- Restructure stories

### If Validation Fails
- Show validation report with errors
- Ask user to review and approve fixes
- Re-run validation after fixes

## Output

**Files created:**
- `scripts/ralph/prd.json` - Validated PRD
- `scripts/ralph/progress.txt` - Progress tracking
- `scripts/ralph/prompt.md` - Execution prompt
- `scripts/ralph/AGENTS.md` - Agent guidance (if needed)

**Status:** READY FOR RALPH / NEEDS REVISION

## Final Checkpoint

```
"PRD Validation Complete:

- JSON schema: [PASS/FAIL]
- Story atomicity: [PASS/FAIL]
- Dependencies: [PASS/FAIL]
- Completion promise: [PASS/FAIL]
- Story count: [N] stories [OK/WARNING]

Status: [READY FOR RALPH / NEEDS REVISION]

Run `/ralph-start` to begin autonomous execution.
Or review `scripts/ralph/prd.json` and edit if needed."
```
