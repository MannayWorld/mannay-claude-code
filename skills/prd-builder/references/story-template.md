# Story Template

Standard template for atomic user stories in Ralph PRDs.

## Markdown Template

```markdown
## US-XXX: [Verb] [Noun] [Context]

### Story
As a [role]
I want to [action]
So I can [benefit]

### Acceptance Criteria
- [ ] [Specific, measurable criterion 1]
- [ ] [Specific, measurable criterion 2]
- [ ] [Specific, measurable criterion 3]
- [ ] Unit tests passing (coverage >= 85%)
- [ ] TypeScript: 0 type errors
- [ ] ESLint: 0 errors, 0 warnings

### Technical Requirements
- API endpoint: [exact route]
- Data model: [field names and types]
- Validation: [exact rules]
- Error handling: [specific error messages]

### Dependencies
- DEPENDS ON: [US-XXX if blocked]
- BLOCKS: [US-XXX if this blocks others]

### Priority
P0/P1/P2/P3

### Estimated Complexity
1-5 points (1 = trivial, 5 = complex for atomic story)
```

## JSON Template

```json
{
  "id": "US-XXX",
  "title": "[Verb] [Noun] [Context]",
  "description": "As a [role], I want to [action] so I can [benefit]",
  "acceptanceCriteria": [
    "[Specific, measurable criterion 1]",
    "[Specific, measurable criterion 2]",
    "[Specific, measurable criterion 3]",
    "Unit tests passing (coverage >= 85%)",
    "TypeScript: 0 type errors",
    "ESLint: 0 errors, 0 warnings"
  ],
  "technicalRequirements": {
    "api": "[METHOD] /api/[path]",
    "dataModel": "{ [field]: [type] }",
    "validation": "[Exact rules]",
    "errorHandling": "[Specific error messages]"
  },
  "dependencies": {
    "dependsOn": [],
    "blocks": []
  },
  "priority": 1,
  "complexity": 3,
  "passes": false,
  "notes": "[Context, patterns, gotchas]",
  "blocked": false,
  "blockedReason": ""
}
```

## Examples

### Example 1: API Endpoint Story

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
    "Password hashed with bcrypt (cost factor 12)",
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
    "blocks": ["US-002", "US-007"]
  },
  "priority": 1,
  "complexity": 2,
  "passes": false,
  "notes": "Follow existing auth patterns in /api/auth/login",
  "blocked": false,
  "blockedReason": ""
}
```

### Example 2: UI Component Story

```json
{
  "id": "US-007",
  "title": "Create registration form component",
  "description": "As a new user, I want a registration form so I can enter my account details",
  "acceptanceCriteria": [
    "RegistrationForm component exists in components/auth/",
    "Form has email input with label",
    "Form has password input with label",
    "Form has confirm password input with label",
    "Submit button labeled 'Create Account'",
    "Form is accessible (WCAG 2.1 AA)",
    "Unit tests passing (coverage >= 85%)",
    "TypeScript: 0 type errors"
  ],
  "technicalRequirements": {
    "api": "N/A (UI only)",
    "dataModel": "{ email: string, password: string, confirmPassword: string }",
    "validation": "Client-side email format, password match",
    "errorHandling": "Inline error messages below inputs"
  },
  "dependencies": {
    "dependsOn": ["US-001"],
    "blocks": ["US-009"]
  },
  "priority": 2,
  "complexity": 2,
  "passes": false,
  "notes": "Use existing form patterns from LoginForm component",
  "blocked": false,
  "blockedReason": ""
}
```

### Example 3: Integration Story

```json
{
  "id": "US-009",
  "title": "Wire registration form to API",
  "description": "As a new user, I want my registration form to submit to the API so I can create my account",
  "acceptanceCriteria": [
    "Form submits to POST /api/auth/register",
    "Loading state shown during submission",
    "Success redirects to /login with message",
    "API errors displayed below form",
    "Network errors show retry option",
    "Unit tests passing (coverage >= 85%)",
    "TypeScript: 0 type errors",
    "Verify in browser: registration flow works"
  ],
  "technicalRequirements": {
    "api": "POST /api/auth/register",
    "dataModel": "{ email: string, password: string }",
    "validation": "Server-side validation via API",
    "errorHandling": "Display API error messages"
  },
  "dependencies": {
    "dependsOn": ["US-001", "US-007"],
    "blocks": []
  },
  "priority": 2,
  "complexity": 3,
  "passes": false,
  "notes": "Use react-query mutation pattern from existing code",
  "blocked": false,
  "blockedReason": ""
}
```

## Title Conventions

### Format: [Verb] [Noun] [Context]

| Type | Verbs | Examples |
|------|-------|----------|
| Create | Create, Add, Implement | Create user model, Add login endpoint |
| Update | Update, Modify, Enhance | Update profile API, Modify validation |
| Fix | Fix, Resolve, Correct | Fix auth bug, Resolve race condition |
| Remove | Remove, Delete, Drop | Remove deprecated field |
| Refactor | Refactor, Optimize, Improve | Refactor auth flow |

### Good Titles
- "Create user registration API endpoint"
- "Add email validation to registration form"
- "Implement password hashing with bcrypt"

### Bad Titles
- "User stuff" (too vague)
- "Fix the bug" (which bug?)
- "Make it work" (not specific)

## Acceptance Criteria Best Practices

### Be Specific
```
GOOD: "Returns 400 with error code 'INVALID_EMAIL' for malformed email"
BAD: "Validates email properly"
```

### Be Measurable
```
GOOD: "Response time < 200ms for 95th percentile"
BAD: "Fast response"
```

### Be Verifiable
```
GOOD: "Unit tests passing (coverage >= 85%)"
BAD: "Well tested"
```

### Include All Requirements
Every story should include:
1. Functional requirements (what it does)
2. Test coverage requirement (>= 85%)
3. Type safety requirement (0 TypeScript errors)
4. Lint requirement (0 ESLint errors)
5. UI verification (for frontend stories): "Verify in browser"
