# PRD Quality Validation System

This document defines the validation rules and processes for ensuring PRD quality in the PRD Builder skill.

## Overview

The validation system ensures that generated PRDs meet Ralph mode quality standards before being saved. It performs multiple validation checks across JSON structure, story quality, dependencies, and completion criteria.

## Validation Checks

### 1. JSON Schema Validation

**Purpose:** Ensure the PRD follows the correct JSON structure.

**Process:**
```bash
jq empty scripts/ralph/prd.json
```

**Required Fields:**
- `title` (string)
- `completion_promise` (string)
- `stories` (array)
  - Each story must have:
    - `id` (string)
    - `title` (string)
    - `description` (string)
    - `acceptance_criteria` (array of strings)
    - `dependencies` (array of strings)
    - `status` (string: "pending" | "in_progress" | "completed")

**Error Messages:**
- "Invalid JSON structure: parse error at line X"
- "Missing required field: {field_name}"
- "Invalid field type: {field_name} must be {type}"

### 2. Story Atomicity Checks

**Purpose:** Ensure each story is appropriately sized and well-defined.

**Rules:**
- Each story should have 3-7 acceptance criteria
- Stories with 1-2 criteria may be too small
- Stories with 8+ criteria should be split
- Each acceptance criterion should be specific and testable

**Validation Process:**
```markdown
For each story:
  - Count acceptance criteria
  - Flag if < 3 (consider merging)
  - Flag if > 7 (consider splitting)
  - Check criteria are specific (contain action verbs)
```

**Error Messages:**
- "Story {id} has only {n} acceptance criteria (recommended: 3-7)"
- "Story {id} has {n} acceptance criteria (consider splitting)"
- "Story {id} has vague acceptance criteria: {criterion}"

### 3. Dependency Validation

**Purpose:** Ensure dependencies are valid and acyclic.

**Rules:**
- All dependency IDs must reference existing stories
- No circular dependencies (A → B → A)
- Dependencies should form a DAG (Directed Acyclic Graph)
- Stories without dependencies should be executable first

**Validation Process:**
```markdown
1. Build dependency graph
2. Check all referenced IDs exist
3. Detect cycles using DFS traversal
4. Verify execution order is possible
```

**Error Messages:**
- "Story {id} depends on non-existent story: {dependency_id}"
- "Circular dependency detected: {id1} → {id2} → ... → {id1}"
- "Invalid dependency chain in stories: {ids}"

### 4. Completion Promise Validation

**Purpose:** Ensure the completion promise exactly matches the feature description.

**Rules:**
- Completion promise must be present
- Must be a clear, testable statement
- Should match the original feature request
- Must be achievable by the defined stories

**Validation Process:**
```markdown
1. Check completion promise is not empty
2. Verify it's a single, clear statement
3. Cross-reference with feature description
4. Ensure all stories contribute to the promise
```

**Error Messages:**
- "Completion promise is empty or missing"
- "Completion promise is too vague"
- "Completion promise doesn't match feature description"
- "Stories don't fully satisfy completion promise"

### 5. Story Count Recommendations

**Purpose:** Ensure the PRD is appropriately scoped.

**Ideal Range:** 3-20 stories

**Guidelines:**
- **< 3 stories:** Feature may be too simple for a PRD (consider direct implementation)
- **3-8 stories:** Ideal for small to medium features
- **9-15 stories:** Good for medium features
- **16-20 stories:** Maximum recommended for a single PRD
- **> 20 stories:** Consider breaking into multiple PRDs or epics

**Validation Process:**
```markdown
1. Count total stories
2. Provide recommendation based on count
3. Suggest restructuring if needed
```

**Error Messages:**
- "PRD has only {n} stories (consider direct implementation)"
- "PRD has {n} stories (consider splitting into multiple PRDs)"
- "Large PRD detected: {n} stories may be difficult to manage"

## Validation Report Generation

After running all validation checks, generate a structured validation report:

```markdown
# PRD Validation Report

**PRD Title:** {title}
**Total Stories:** {count}
**Validation Status:** {PASS | FAIL | WARNING}

## JSON Schema: {✓ | ✗}
{error_messages}

## Story Atomicity: {✓ | ✗ | ⚠}
{warnings_and_errors}

## Dependencies: {✓ | ✗}
{error_messages}

## Completion Promise: {✓ | ✗}
{error_messages}

## Story Count: {✓ | ⚠}
{recommendations}

## Summary
- **Errors:** {count} - Must fix before saving
- **Warnings:** {count} - Review recommended
- **Passed:** {count} checks

{Overall recommendation}
```

## Validation Levels

### PASS
- All critical checks pass
- No errors detected
- Warnings (if any) are minor
- PRD ready for Ralph execution

### WARNING
- All critical checks pass
- Non-critical warnings present
- Review recommended but not required
- PRD can be used with caution

### FAIL
- One or more critical checks fail
- Errors must be fixed
- PRD cannot be saved
- Return to relevant phase for corrections

## Integration with PRD Builder

The validation system integrates at two points:

1. **Phase 5 (Story Dependency):** Basic validation after dependency definition
2. **Phase 6 (Final Review):** Comprehensive validation before saving

### Phase 5 Validation (Quick Check)
- JSON structure validation
- Dependency reference validation
- Basic story count check

### Phase 6 Validation (Comprehensive)
- All validation checks
- Generate full validation report
- Require fixes before saving

## Error Recovery

When validation fails:

1. **Identify Phase:** Determine which phase needs revision
2. **Show Specific Errors:** Present detailed error messages
3. **Provide Guidance:** Suggest specific fixes
4. **Offer Options:**
   - Fix automatically (if possible)
   - Return to specific phase
   - Regenerate problematic stories
   - Cancel and start over

## Best Practices

1. **Validate Early:** Run basic checks after each phase
2. **Provide Context:** Show which stories have issues
3. **Be Specific:** Give actionable error messages
4. **Allow Iteration:** Let user refine without restarting
5. **Document Decisions:** Track validation overrides if allowed

## Examples

### Valid PRD
```json
{
  "title": "Add Dark Mode Toggle",
  "completion_promise": "Users can toggle between light and dark themes with persistent preference",
  "stories": [
    {
      "id": "story-1",
      "title": "Create theme context and provider",
      "description": "Set up React context for theme state management",
      "acceptance_criteria": [
        "Theme context created with light/dark state",
        "ThemeProvider wraps application",
        "Current theme accessible via useTheme hook",
        "Theme state persists in localStorage"
      ],
      "dependencies": [],
      "status": "pending"
    },
    {
      "id": "story-2",
      "title": "Build toggle component",
      "description": "Create UI component for theme switching",
      "acceptance_criteria": [
        "Toggle component renders in header",
        "Click toggles between themes",
        "Visual indicator shows current theme",
        "Component is accessible (ARIA labels)"
      ],
      "dependencies": ["story-1"],
      "status": "pending"
    }
  ]
}
```

### Invalid PRD (Circular Dependency)
```json
{
  "stories": [
    {
      "id": "story-1",
      "dependencies": ["story-2"]
    },
    {
      "id": "story-2",
      "dependencies": ["story-1"]
    }
  ]
}
```
**Error:** "Circular dependency detected: story-1 → story-2 → story-1"

### Invalid PRD (Too Few Acceptance Criteria)
```json
{
  "stories": [
    {
      "id": "story-1",
      "acceptance_criteria": [
        "Component works"
      ]
    }
  ]
}
```
**Warning:** "Story story-1 has only 1 acceptance criteria (recommended: 3-7)"

## Version History

- v1.0.0: Initial validation system
