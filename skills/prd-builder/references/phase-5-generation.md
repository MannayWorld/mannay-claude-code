# Phase 5: PRD Generation

**Objective:** Convert atomic stories into Ralph-ready JSON format.

Based on Anthropic's official ralph-wiggum plugin template.

## Ralph JSON Schema

```json
{
  "projectName": "Feature Name",
  "branchName": "ralph/<feature-slug>",
  "description": "One-sentence description of what this accomplishes",
  "created": "YYYY-MM-DD",
  "userStories": [
    {
      "id": "US-001",
      "title": "Story title (verb noun context)",
      "description": "As a [role], I want to [action] so I can [benefit]",
      "acceptanceCriteria": [
        "Criterion 1 (specific, measurable)",
        "Criterion 2",
        "Criterion 3",
        "Unit tests passing (coverage >= 85%)",
        "TypeScript: 0 type errors",
        "ESLint: 0 errors, 0 warnings"
      ],
      "technicalRequirements": {
        "api": "POST /api/endpoint",
        "dataModel": "{ field: type }",
        "validation": "Exact rules",
        "errorHandling": "Specific error messages"
      },
      "dependencies": {
        "dependsOn": ["US-000"],
        "blocks": ["US-002"]
      },
      "priority": 1,
      "complexity": 3,
      "passes": false,
      "notes": "Context, patterns, gotchas",
      "blocked": false,
      "blockedReason": ""
    }
  ],
  "completionPromise": "<promise>COMPLETE</promise>",
  "maxIterations": 20,
  "qualityGates": {
    "testCoverage": 85,
    "typeErrors": 0,
    "lintErrors": 0,
    "securityChecks": true
  }
}
```

## JSON Generation Process

### Step 1: Create Project Metadata

```json
{
  "projectName": "[Extract from requirements]",
  "branchName": "ralph/[kebab-case-feature-name]",
  "description": "[One-sentence summary]",
  "created": "[Today's date: YYYY-MM-DD]"
}
```

### Step 2: Convert Each Story to JSON

| Field | Description |
|-------|-------------|
| `id` | Sequential (US-001, US-002, ...) |
| `title` | From story template |
| `description` | User story narrative |
| `acceptanceCriteria` | Array of discrete bullets |
| `technicalRequirements` | Object with specific details |
| `dependencies` | Object with dependsOn/blocks arrays |
| `priority` | 1-4 (lower = higher priority) |
| `complexity` | 1-5 (estimate of story complexity) |
| `passes` | false (initially) |
| `notes` | Context from technical spec |
| `blocked` | false (initially) |
| `blockedReason` | "" (initially) |

### Step 3: Add Completion Criteria

From Anthropic guidance:

```json
{
  "completionPromise": "<promise>COMPLETE</promise>",
  "maxIterations": 20
}
```

### Step 4: Add Quality Gates

```json
{
  "qualityGates": {
    "testCoverage": 85,
    "typeErrors": 0,
    "lintErrors": 0,
    "securityChecks": true
  }
}
```

### Step 5: Save to File

**Path:** `scripts/ralph/prd.json`

## Story JSON Example

```json
{
  "id": "US-001",
  "title": "Create user registration API endpoint",
  "description": "As a new user, I want to register an account so I can access the application",
  "acceptanceCriteria": [
    "POST /api/auth/register endpoint exists",
    "Accepts email and password in request body",
    "Returns 201 with user object (without password) on success",
    "Returns 400 with validation errors for invalid input",
    "Returns 409 if email already exists",
    "Unit tests passing (coverage >= 85%)",
    "TypeScript: 0 type errors"
  ],
  "technicalRequirements": {
    "api": "POST /api/auth/register",
    "dataModel": "{ email: string, password: string }",
    "validation": "Email format, password min 8 chars",
    "errorHandling": "Zod validation errors, duplicate email check"
  },
  "dependencies": {
    "dependsOn": [],
    "blocks": ["US-002", "US-003"]
  },
  "priority": 1,
  "complexity": 2,
  "passes": false,
  "notes": "Use existing auth patterns from /api/auth/login",
  "blocked": false,
  "blockedReason": ""
}
```

## Priority Values

| Value | Level | Use For |
|-------|-------|---------|
| 1 | P0 (Critical) | Foundation, blockers, security |
| 2 | P1 (High) | Core features, major functionality |
| 3 | P2 (Medium) | Enhancements, polish |
| 4 | P3 (Low) | Nice-to-haves, technical debt |

## Complexity Values

| Value | Level | Description |
|-------|-------|-------------|
| 1 | Trivial | Config change, simple update |
| 2 | Simple | Single file, clear implementation |
| 3 | Medium | Multiple files, some decisions |
| 4 | Complex | Multiple systems, careful design |
| 5 | Very Complex | Novel problem, research needed |

## Output

**File:** `scripts/ralph/prd.json`

Ralph-ready JSON PRD saved and ready for Phase 6 validation.
