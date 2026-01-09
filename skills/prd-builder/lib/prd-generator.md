# PRD JSON Generator

This document specifies how to convert decomposed user stories into Ralph-ready JSON format matching Anthropic's ralph-wiggum template.

## Ralph JSON Format Specification

Based on Anthropic's official ralph-wiggum plugin template, PRDs must follow this exact structure:

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
        "Unit tests passing (coverage ≥ 85%)",
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

## Field-by-Field Mapping

### Project Metadata

**projectName** (string, required)
- Extract from requirements discovery phase
- Should be descriptive and concise
- Example: "User Authentication System", "Payment Processing API"

**branchName** (string, required, must match pattern: `^ralph/[a-z0-9-]+$`)
- Format: `ralph/<feature-slug>`
- Use kebab-case
- Example: "ralph/user-auth", "ralph/payment-api"

**description** (string, required)
- One-sentence summary of what this PRD accomplishes
- Should answer: "What will be built?"
- Example: "Implement secure user authentication with OAuth2 and JWT tokens"

**created** (string, required, must match pattern: `^\\d{4}-\\d{2}-\\d{2}$`)
- Format: YYYY-MM-DD
- Use today's date when generating PRD
- Example: "2026-01-07"

### User Stories Array

**userStories** (array, required, minItems: 1)
Each story object must include:

**id** (string, required, must match pattern: `^US-\\d{3}$`)
- Sequential numbering: US-001, US-002, US-003, etc.
- Zero-padded to 3 digits
- Example: "US-001", "US-042"

**title** (string, required)
- Format: "verb + noun + context"
- Should be action-oriented
- Example: "Create user login endpoint", "Implement password hashing"

**description** (string, required)
- Format: "As a [role], I want to [action] so I can [benefit]"
- Must follow user story narrative structure
- Example: "As a developer, I want to implement JWT token generation so I can secure API endpoints"

**acceptanceCriteria** (array, required, minItems: 3, maxItems: 10)
- Each criterion must be specific and measurable
- MUST include quality checks:
  - Test coverage: "Unit tests passing (coverage ≥ 85%)" or "Tests passing (coverage ≥ 80%)"
  - Type safety: "TypeScript: 0 type errors" (for TS projects)
  - Linting: "ESLint: 0 errors, 0 warnings" (adjust for project linter)
- Example:
  ```json
  [
    "Login endpoint accepts email and password",
    "Returns JWT token on successful authentication",
    "Returns 401 error for invalid credentials",
    "Unit tests passing (coverage ≥ 85%)",
    "TypeScript: 0 type errors",
    "ESLint: 0 errors, 0 warnings"
  ]
  ```

**technicalRequirements** (object, optional)
- Provides specific implementation details
- Common fields:
  - `api`: API endpoint specification
  - `dataModel`: Data structure/schema
  - `validation`: Validation rules
  - `errorHandling`: Error message specifications
- Example:
  ```json
  {
    "api": "POST /api/auth/login",
    "dataModel": "{ email: string, password: string }",
    "validation": "Email must be valid format, password min 8 chars",
    "errorHandling": "401: Invalid credentials, 500: Server error"
  }
  ```

**dependencies** (object, optional)
- Tracks story relationships
- Fields:
  - `dependsOn`: Array of story IDs that must be completed first
  - `blocks`: Array of story IDs that are blocked by this story
- Example:
  ```json
  {
    "dependsOn": ["US-001", "US-002"],
    "blocks": ["US-005"]
  }
  ```

**priority** (integer, required, range: 1-4)
- 1 = Highest priority (critical path)
- 2 = High priority (important features)
- 3 = Medium priority (nice-to-have)
- 4 = Low priority (optional/future)

**complexity** (integer, optional, range: 1-5)
- Estimate of story complexity
- 1 = Trivial (minutes)
- 2 = Simple (< 30 min)
- 3 = Moderate (30-60 min)
- 4 = Complex (1-2 hours)
- 5 = Very complex (max for atomic story)

**passes** (boolean, required)
- Initial value: `false`
- Set to `true` by Ralph when story is complete
- DO NOT set to true manually

**notes** (string, optional)
- Context, patterns, gotchas from technical spec
- Implementation hints
- Links to documentation
- Example: "Use bcrypt for password hashing. See /docs/security.md for standards"

**blocked** (boolean, optional)
- Initial value: `false`
- Set to `true` if story cannot proceed
- Used during execution, not in initial PRD

**blockedReason** (string, optional)
- Initial value: `""`
- Explanation if blocked is true
- Used during execution, not in initial PRD

### Completion Promise

**completionPromise** (string, required, MUST BE EXACT)
- CRITICAL: Must be exactly `<promise>COMPLETE</promise>`
- No variations allowed - Ralph looks for this exact string
- This is how Ralph knows when to stop

**CORRECT:**
```json
"completionPromise": "<promise>COMPLETE</promise>"
```

**INCORRECT:**
```json
"completionPromise": "COMPLETE"
"completionPromise": "<promise>complete</promise>"
"completionPromise": "All stories complete"
```

### Max Iterations

**maxIterations** (integer, optional, range: 1-100)
- Recommended: 20-50
- Prevents infinite loops
- Ralph will stop after this many iterations even if not complete

### Quality Gates

**qualityGates** (object, optional)
- Defines quality standards for the entire PRD
- Common fields:
  - `testCoverage`: Minimum test coverage percentage (recommended: 85)
  - `typeErrors`: Maximum allowed type errors (recommended: 0)
  - `lintErrors`: Maximum allowed lint errors (recommended: 0)
  - `securityChecks`: Whether security validation is required (recommended: true)

Example:
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

## JSON Generation Process

Follow these steps to convert decomposed stories into Ralph JSON:

### Step 1: Create Project Metadata

Extract from requirements discovery and design phases:

```json
{
  "projectName": "[Extract from requirements]",
  "branchName": "ralph/[kebab-case-feature-name]",
  "description": "[One-sentence summary from requirements]",
  "created": "[Today's date: YYYY-MM-DD]"
}
```

### Step 2: Convert Each Story to JSON

For each atomic user story from decomposition phase:

1. Assign sequential ID (US-001, US-002, ...)
2. Use title from story template
3. Use description from story narrative
4. Convert acceptance criteria to array (ensure 3-10 items)
5. Add quality criteria to acceptance criteria:
   - Test coverage requirement
   - Type safety requirement (if applicable)
   - Linting requirement
6. Extract technical requirements into structured object
7. Map dependencies (dependsOn/blocks)
8. Assign priority (1-4 based on importance)
9. Estimate complexity (1-5 based on effort)
10. Set passes to false
11. Add notes from technical spec
12. Set blocked to false
13. Set blockedReason to ""

### Step 3: Add Completion Criteria

```json
{
  "completionPromise": "<promise>COMPLETE</promise>",
  "maxIterations": 20
}
```

### Step 4: Add Quality Gates

Based on project requirements:

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

### Step 5: Validate JSON

1. Validate against schema: `skills/prd-builder/templates/prd-schema.json`
2. Run: `jq empty scripts/ralph/prd.json`
3. Check all required fields present
4. Verify completion promise is exact match

### Step 6: Save to File

Save to: `scripts/ralph/prd.json`

## Complete Example

Here's a complete example PRD for a user authentication feature:

```json
{
  "projectName": "User Authentication System",
  "branchName": "ralph/user-auth",
  "description": "Implement secure user authentication with email/password login and JWT tokens",
  "created": "2026-01-07",
  "userStories": [
    {
      "id": "US-001",
      "title": "Create user registration endpoint",
      "description": "As a developer, I want to create a user registration API endpoint so users can create new accounts",
      "acceptanceCriteria": [
        "POST /api/auth/register endpoint created",
        "Accepts email and password in request body",
        "Validates email format and password strength (min 8 chars)",
        "Hashes password using bcrypt before storing",
        "Returns 201 with user ID on success",
        "Returns 400 for invalid input, 409 if user exists",
        "Unit tests passing (coverage ≥ 85%)",
        "TypeScript: 0 type errors",
        "ESLint: 0 errors, 0 warnings"
      ],
      "technicalRequirements": {
        "api": "POST /api/auth/register",
        "dataModel": "{ email: string, password: string }",
        "validation": "Email regex validation, password min 8 chars with complexity rules",
        "errorHandling": "400: Invalid input, 409: User already exists, 500: Server error"
      },
      "dependencies": {
        "dependsOn": [],
        "blocks": ["US-002", "US-003"]
      },
      "priority": 1,
      "complexity": 3,
      "passes": false,
      "notes": "Use bcrypt with salt rounds = 10. Store only hashed passwords. See /docs/security.md for password policy",
      "blocked": false,
      "blockedReason": ""
    },
    {
      "id": "US-002",
      "title": "Create user login endpoint",
      "description": "As a developer, I want to create a user login API endpoint so users can authenticate",
      "acceptanceCriteria": [
        "POST /api/auth/login endpoint created",
        "Accepts email and password in request body",
        "Validates credentials against database",
        "Generates JWT token on successful authentication",
        "Returns 200 with JWT token and user data",
        "Returns 401 for invalid credentials",
        "Unit tests passing (coverage ≥ 85%)",
        "TypeScript: 0 type errors",
        "ESLint: 0 errors, 0 warnings"
      ],
      "technicalRequirements": {
        "api": "POST /api/auth/login",
        "dataModel": "{ email: string, password: string }",
        "validation": "Email must exist, password must match hashed value",
        "errorHandling": "401: Invalid credentials, 500: Server error"
      },
      "dependencies": {
        "dependsOn": ["US-001"],
        "blocks": ["US-003"]
      },
      "priority": 1,
      "complexity": 3,
      "passes": false,
      "notes": "Use jsonwebtoken library. Token expiry: 24 hours. Include user ID in payload",
      "blocked": false,
      "blockedReason": ""
    },
    {
      "id": "US-003",
      "title": "Implement JWT token verification middleware",
      "description": "As a developer, I want to create middleware to verify JWT tokens so I can protect authenticated routes",
      "acceptanceCriteria": [
        "Middleware function extracts token from Authorization header",
        "Verifies token signature and expiration",
        "Attaches decoded user data to request object",
        "Returns 401 if token is missing or invalid",
        "Returns 403 if token is expired",
        "Unit tests passing (coverage ≥ 85%)",
        "TypeScript: 0 type errors",
        "ESLint: 0 errors, 0 warnings"
      ],
      "technicalRequirements": {
        "api": "Middleware for Express/Fastify",
        "dataModel": "Authorization: Bearer <token>",
        "validation": "Token must be valid JWT, not expired",
        "errorHandling": "401: Missing or invalid token, 403: Token expired"
      },
      "dependencies": {
        "dependsOn": ["US-002"],
        "blocks": []
      },
      "priority": 1,
      "complexity": 2,
      "passes": false,
      "notes": "Apply to all routes that require authentication. Use same secret as login endpoint",
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

## Validation Checklist

Before saving the PRD, verify:

- [ ] All required fields present (projectName, branchName, description, created, userStories, completionPromise)
- [ ] branchName matches pattern: `ralph/[a-z0-9-]+`
- [ ] created matches pattern: `YYYY-MM-DD`
- [ ] At least 1 user story
- [ ] Each story has required fields (id, title, description, acceptanceCriteria, priority, passes)
- [ ] Story IDs match pattern: `US-\\d{3}` and are sequential
- [ ] Each story has 3-10 acceptance criteria
- [ ] Quality criteria included in acceptance criteria (tests, types, linting)
- [ ] Priority is 1-4
- [ ] Complexity is 1-5 (if present)
- [ ] completionPromise is EXACTLY `<promise>COMPLETE</promise>`
- [ ] No circular dependencies
- [ ] All dependency references exist
- [ ] JSON is valid (run `jq empty prd.json`)

## Common Mistakes to Avoid

1. **Wrong completion promise format**
   - WRONG: `"completionPromise": "COMPLETE"`
   - RIGHT: `"completionPromise": "<promise>COMPLETE</promise>"`

2. **Too few acceptance criteria**
   - WRONG: 2 criteria
   - RIGHT: 3-10 criteria including quality gates

3. **Missing quality criteria**
   - WRONG: Only functional criteria
   - RIGHT: Include test coverage, type safety, linting

4. **Non-sequential story IDs**
   - WRONG: US-001, US-003, US-002
   - RIGHT: US-001, US-002, US-003

5. **Invalid branch name**
   - WRONG: `ralph/Feature_Name`
   - RIGHT: `ralph/feature-name`

6. **Circular dependencies**
   - WRONG: US-001 depends on US-002, US-002 depends on US-001
   - RIGHT: Linear or tree dependency structure

7. **Non-atomic stories**
   - WRONG: "Build entire authentication system" (complexity 5+)
   - RIGHT: "Create user registration endpoint" (complexity 2-3)
