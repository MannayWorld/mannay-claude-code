# Phase 4: Story Decomposition (Critical Phase)

**Objective:** Break technical spec into atomic user stories (2-5 min tasks each).

Based on Anthropic's Ralph Wiggum guidance and ISPI atomic user stories framework.

## The #1 Rule: Story Size

**Each story must be completable in ONE Ralph iteration (~one context window).**

Ralph spawns a fresh instance per iteration with no memory of previous work. If a story is too big, the LLM runs out of context before finishing and produces broken code.

### Right-Sized Stories
- Add a database column + migration
- Add a UI component to an existing page
- Update a server action with new logic
- Add a filter dropdown to a list

### Too Big (Split These)
- "Build the entire dashboard" -> Split into: schema, queries, UI components, filters
- "Add authentication" -> Split into: schema, middleware, login UI, session handling
- "Refactor the API" -> Split into one story per endpoint or pattern

**Rule of thumb:** If you can't describe the change in 2-3 sentences, it's too big.

## Story Atomicity Criteria

**What makes a story atomic?**
> "The smallest demonstrable, working piece of useful functionality" (ISPI definition)

| Criteria | Target |
|----------|--------|
| Duration | 2-5 minutes implementation |
| Scope | Single responsibility, one core functionality |
| Testing | Unit tests can validate without complex dependencies |
| Review | Pull request reviewable in 15-30 minutes |
| Acceptance Criteria | 3-7 items (not < 3 or > 10) |

## 10 Decomposition Techniques

Use these techniques from the ISPI framework:

1. **Workflow Steps** - Break into sequential steps (register -> verify email -> login)
2. **Business Rule Variations** - Separate different validation rules
3. **Major Effort Areas** - Frontend vs backend vs database
4. **Simple/Complex** - Basic version first, then complexity
5. **Data Variations** - Different input types (email vs OAuth)
6. **Data Entry Methods** - Form vs API vs import
7. **Individual Operations** - Separate CRUD operations (Create != Read != Update != Delete)
8. **Use-Case Scenarios** - Happy path vs error paths
9. **Non-Functional Qualities** - Performance, security as separate stories
10. **Research Spikes** - Separate investigation from implementation

## Story Creation Process

### Step 1: Read Technical Spec Section by Section

For each major feature, apply decomposition techniques.

### Step 2: Apply Decomposition

**Example: "User Authentication"**

```
BAD (too large):
US-001: Implement user authentication with registration, login, logout,
password reset, email verification, and OAuth

GOOD (atomic stories):
US-001: Create user registration API endpoint (POST /api/auth/register)
US-002: Add email validation with regex pattern
US-003: Add password hashing with bcrypt (cost factor: 12)
US-004: Create user login API endpoint (POST /api/auth/login)
US-005: Add JWT token generation (RS256, 24h expiry)
US-006: Add rate limiting to login (5 attempts per 15 min)
US-007: Create registration form component
US-008: Create login form component
US-009: Wire registration form to API
US-010: Wire login form to API
US-011: Add form validation and error display
US-012: Add loading states during submission
```

### Step 3: Validate Story Size

**Red flags indicating too large:**
- Multiple "AND" conditions in title
- Acceptance criteria > 10 items
- Multiple system components affected
- Cannot demo in single session
- Requires complex test setup

### Step 4: Order Stories

Order by priority and dependencies:

| Priority | Description |
|----------|-------------|
| P0 (Critical) | Foundation, blockers, security |
| P1 (High) | Core features, major functionality |
| P2 (Medium) | Enhancements, polish |
| P3 (Low) | Nice-to-haves, technical debt |

## Acceptance Criteria Format

Based on ChatPRD Claude Code guidance.

**Use discrete bullet points, NOT prose:**

```
GOOD:
- Email input accepts valid email format (regex: /^[^\s@]+@[^\s@]+\.[^\s@]+$/)
- Invalid email shows error: "Please enter a valid email address"
- Error appears below input field in red text
- Form cannot submit with invalid email
- Tests passing (coverage >= 85%)
- TypeScript types defined with no 'any'

BAD:
The system should validate email input and show an error message if invalid,
preventing form submission until the user enters a valid email address.
```

### Acceptance Criteria Guidelines

- Aim for 3-7 criteria per story (if > 10, story is too large)
- Each criterion is independently verifiable
- Include specific values/formats (not "validate properly")
- Always include test coverage requirement (>= 80% or >= 85%)
- Always include TypeScript type safety requirement
- Include performance thresholds when applicable
- Include accessibility requirements (WCAG 2.1 AA)

## Mandatory Testing Requirements

**Every story MUST include:**

```
- [ ] Unit tests passing (coverage >= 85%)
- [ ] Integration tests passing (if applicable)
- [ ] TypeScript: 0 type errors, no 'any' types
- [ ] ESLint: 0 errors, 0 warnings
- [ ] All existing tests still passing
```

From LIDR Academy standards:
- Test-Driven Development (write tests first)
- 90%+ test coverage across all layers
- Security validation (input sanitization, auth checks)

## Output

Collection of atomic user stories ready for JSON conversion.

**Validation checkpoint:**
```
"I've broken this into [N] stories. Does this granularity look right?

Stories:
1. [US-001]: [Title]
2. [US-002]: [Title]
...

Each story is 2-5 minutes and has 3-7 acceptance criteria."
```

Wait for user confirmation before Phase 5.
