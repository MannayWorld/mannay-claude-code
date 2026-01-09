# Story Decomposition Engine

> **Core Principle**: Every story must be implementable in **2-5 minutes** of focused development time (Anthropic guidance for optimal AI-assisted development).

## Overview

This guide provides comprehensive techniques for breaking features into atomic user stories following the ISPI (Incremental Slicing of Product Ideas) framework. Atomic stories enable rapid iteration, easier testing, and faster feedback cycles.

---

## The 10 ISPI Decomposition Techniques

### 1. Workflow Steps
Break features by sequential steps in a user workflow.

**Example Feature**: "User Registration"
- Story 1: Display registration form with email/password fields
- Story 2: Validate email format on form submission
- Story 3: Validate password strength requirements
- Story 4: Create user record in database
- Story 5: Send verification email with token
- Story 6: Verify email token and activate account
- Story 7: Display success message and redirect to dashboard

**When to use**: Features with clear sequential processes (onboarding, checkout, multi-step forms)

---

### 2. Business Rule Variations
Split by different business rules or edge cases.

**Example Feature**: "Discount Calculation"
- Story 1: Apply flat percentage discount to cart total
- Story 2: Apply fixed amount discount to cart total
- Story 3: Apply category-specific discount rules
- Story 4: Apply tiered discount based on cart value
- Story 5: Enforce minimum purchase requirement for discount
- Story 6: Enforce discount expiration date validation
- Story 7: Handle mutually exclusive discount codes

**When to use**: Features with multiple conditional logic branches or rule variations

---

### 3. Major Effort Areas
Decompose by technical complexity or effort clusters.

**Example Feature**: "Product Search"
- Story 1: Implement basic text search query (simple effort)
- Story 2: Add search result pagination (simple effort)
- Story 3: Implement faceted filtering UI (medium effort)
- Story 4: Integrate Elasticsearch full-text search (major effort)
- Story 5: Add search autocomplete suggestions (medium effort)
- Story 6: Implement search result ranking algorithm (major effort)

**When to use**: Features mixing simple and complex technical components

---

### 4. Simple/Complex Split
Separate basic functionality from advanced features.

**Example Feature**: "Data Export"
- Story 1: Export data as CSV with basic fields (simple)
- Story 2: Export data as JSON format (simple)
- Story 3: Export data with custom field selection (complex)
- Story 4: Export large datasets with streaming (complex)
- Story 5: Schedule automated exports (complex)

**When to use**: Features where basic version provides immediate value, advanced features can follow

---

### 5. Data Variations
Split by different data types, formats, or sources.

**Example Feature**: "File Upload"
- Story 1: Upload image files (PNG, JPG)
- Story 2: Upload document files (PDF, DOCX)
- Story 3: Upload video files (MP4, AVI)
- Story 4: Upload from local file system
- Story 5: Upload from URL
- Story 6: Upload from cloud storage (Dropbox, Google Drive)

**When to use**: Features handling multiple data types or input sources

---

### 6. Data Entry Methods
Decompose by how users input or interact with data.

**Example Feature**: "Date Selection"
- Story 1: Date input via text field with format validation
- Story 2: Date input via calendar picker widget
- Story 3: Date input via keyboard shortcuts
- Story 4: Date range selection with start/end dates
- Story 5: Preset date ranges (today, this week, this month)

**When to use**: Features with multiple input modalities or interaction patterns

---

### 7. Individual Operations (CRUD)
Split by Create, Read, Update, Delete operations.

**Example Feature**: "Task Management"
- Story 1: Create new task with title and description
- Story 2: Display list of all tasks
- Story 3: Display single task details
- Story 4: Update task title and description
- Story 5: Update task status (todo, in-progress, done)
- Story 6: Delete task with confirmation
- Story 7: Bulk delete multiple tasks

**When to use**: CRUD-heavy features with data entities

---

### 8. Use-Case Scenarios
Break by specific user personas or scenarios.

**Example Feature**: "Dashboard View"
- Story 1: Admin dashboard with user management widgets
- Story 2: Manager dashboard with team performance metrics
- Story 3: Employee dashboard with personal tasks
- Story 4: Guest dashboard with limited read-only access
- Story 5: Mobile-optimized dashboard layout

**When to use**: Features serving different user types or contexts

---

### 9. Non-Functional Qualities
Separate functional implementation from quality attributes.

**Example Feature**: "API Endpoint"
- Story 1: Implement basic API endpoint functionality
- Story 2: Add request rate limiting
- Story 3: Add response caching
- Story 4: Add authentication/authorization
- Story 5: Add request/response logging
- Story 6: Add error handling and retries
- Story 7: Add API documentation (OpenAPI/Swagger)

**When to use**: Features requiring performance, security, or scalability enhancements

---

### 10. Research Spikes
Isolate research, exploration, or technical investigation.

**Example Feature**: "Real-time Notifications"
- Story 1: **[SPIKE]** Research WebSocket vs SSE vs polling approaches (timeboxed 2 hours)
- Story 2: **[SPIKE]** Prototype WebSocket connection handling (timeboxed 3 hours)
- Story 3: Implement WebSocket server connection
- Story 4: Implement client WebSocket subscription
- Story 5: Send notification events over WebSocket
- Story 6: Handle connection failures and reconnection

**When to use**: Features with technical unknowns or new technology exploration

---

## Story Atomicity Checklist

Every story MUST satisfy ALL criteria:

### Duration
- [ ] **2-5 minutes** of focused development time
- [ ] Can be completed in single, uninterrupted work session
- [ ] No need to "come back later" for dependencies

### Scope
- [ ] **Single responsibility** - one clear purpose
- [ ] Changes confined to 1-3 files (typically)
- [ ] No more than 50-150 lines of code changed
- [ ] Title contains NO "AND" conjunctions

### Testing
- [ ] Unit testable without complex mocking
- [ ] No external service dependencies required
- [ ] Test coverage ≥ 85%
- [ ] Tests run in < 1 second

### Review
- [ ] PR reviewable in 15-30 minutes
- [ ] Changes are self-contained and understandable
- [ ] No architectural decisions required
- [ ] Clear acceptance criteria (3-7 items)

---

## Acceptance Criteria Formatting Rules

### Structure
Use **discrete bullet points**, NOT prose paragraphs.

**❌ BAD (Prose)**:
```
The system should validate the email format and check if it's already registered,
then it should hash the password using bcrypt with 10 rounds and store the user
in the database with timestamps.
```

**✅ GOOD (Discrete bullets)**:
```
- Email format validated against RFC 5322 standard
- Email uniqueness checked against existing users
- Password hashed using bcrypt (10 rounds)
- User record created with email, passwordHash, createdAt
- Function returns user ID on success
```

### Quantity
- **3-7 criteria per story** (sweet spot: 4-5)
- Too few (< 3): Story likely too simple or vague
- Too many (> 7): Story likely too complex, needs decomposition

### Specificity
Include concrete values, formats, and boundaries.

**❌ VAGUE**: "Validate password strength"
**✅ SPECIFIC**: "Password must be 8-64 characters with uppercase, lowercase, number, special character"

**❌ VAGUE**: "Display error message"
**✅ SPECIFIC**: "Display red error text 'Invalid email format' below email field"

**❌ VAGUE**: "Handle errors"
**✅ SPECIFIC**: "Return 400 status with JSON `{error: 'Email already exists'}` if duplicate"

### Mandatory Requirements

**Every story MUST include**:

1. **Test Coverage Requirement**:
   ```
   - Unit tests passing with ≥85% coverage
   ```

2. **TypeScript Type Safety** (for TS projects):
   ```
   - TypeScript: 0 type errors, no 'any' types allowed
   ```

3. **Linting** (if project uses linting):
   ```
   - ESLint: 0 errors, 0 warnings
   ```

4. **Regression Prevention**:
   ```
   - All existing tests still passing
   ```

### Example: Complete Acceptance Criteria

**Story**: "Validate email format on registration form"

**Acceptance Criteria**:
- Email input field accepts text input
- Email validated against RFC 5322 regex pattern
- Invalid email displays error "Please enter a valid email address" below field
- Valid email removes error message and enables Submit button
- Unit tests passing with ≥85% coverage
- TypeScript: 0 type errors, no 'any' types allowed
- All existing tests still passing

---

## Testing Requirements (Mandatory)

Every story MUST include these testing standards in acceptance criteria:

### Unit Tests
```
- Unit tests passing with ≥85% coverage
- Tests cover happy path, edge cases, and error conditions
- Tests run in isolation without external dependencies
```

### Integration Tests (if applicable)
```
- Integration tests passing for API/database interactions
- Test database seeded with required fixtures
```

### TypeScript (for TS projects)
```
- TypeScript: 0 type errors
- No 'any' types used (use proper type definitions)
- All function signatures properly typed
```

### Linting
```
- ESLint: 0 errors, 0 warnings
- Code follows project style guide
```

### Regression
```
- All existing tests still passing
- No breaking changes to public APIs
```

---

## Examples: Good vs Bad Decomposition

### Example 1: User Authentication

**❌ BAD - Monolithic Story**

**Story**: "Implement complete user authentication system"

**Acceptance Criteria**:
- Registration form with validation
- Login form with session management
- Logout functionality
- Password reset flow
- Email verification
- Remember me functionality
- OAuth integration (Google, GitHub)
- Rate limiting on login attempts
- Session timeout handling
- Password strength requirements
- CSRF protection
- Unit and integration tests

**Problems**:
- 12 acceptance criteria (way too many)
- Multiple system components (forms, email, OAuth, security)
- Would take 4+ hours to implement
- Impossible to review effectively
- High risk of bugs and conflicts

---

**✅ GOOD - Atomic Stories (12 stories)**

**Story 1**: "Display registration form with email/password fields"
- Form renders with email input field (type=email)
- Form renders with password input field (type=password)
- Form renders with Submit button (disabled by default)
- Form styled with Tailwind classes per design system
- Unit tests passing with ≥85% coverage
- TypeScript: 0 type errors, no 'any' types allowed

**Story 2**: "Validate email format on registration form"
- Email validated against RFC 5322 regex pattern on blur
- Invalid email displays "Please enter a valid email address" below field
- Valid email removes error message
- Submit button enabled only when email valid
- Unit tests passing with ≥85% coverage
- All existing tests still passing

**Story 3**: "Validate password strength on registration form"
- Password validated for 8-64 character length
- Password must contain uppercase, lowercase, number, special character
- Invalid password displays specific error message
- Password strength indicator shows weak/medium/strong
- Submit button enabled only when password valid
- Unit tests passing with ≥85% coverage

**Story 4**: "Create user record in database on registration"
- `createUser(email, password)` function in `userService.ts`
- Password hashed using bcrypt (10 rounds)
- User record created with email, passwordHash, createdAt, isVerified=false
- Function returns user ID on success
- Function throws error if email already exists
- Unit tests passing with ≥85% coverage

**Story 5**: "Send verification email after registration"
- Generate random verification token (UUID v4)
- Store token in `emailVerificationTokens` table with userId, expiresAt (24h)
- Send email via SendGrid with verification link
- Email template includes user's email and clickable link
- Unit tests passing with ≥85% coverage (mock SendGrid)

**Story 6**: "Verify email token and activate account"
- `GET /api/verify-email?token=xxx` endpoint
- Token validated against database (exists, not expired, not used)
- User's `isVerified` flag set to true
- Token marked as used in database
- Success: redirect to `/login?verified=true`
- Error: display "Invalid or expired verification link"
- Unit tests passing with ≥85% coverage

**Story 7**: "Display login form with email/password fields"
- Form renders with email input field
- Form renders with password input field
- Form renders with "Remember me" checkbox
- Form renders with Submit button
- Unit tests passing with ≥85% coverage

**Story 8**: "Authenticate user credentials on login"
- `authenticateUser(email, password)` function in `authService.ts`
- User fetched from database by email
- Password verified using bcrypt.compare()
- Returns user object (without password) on success
- Returns null on failure (invalid email or password)
- Unit tests passing with ≥85% coverage

**Story 9**: "Create session on successful login"
- Generate session token (UUID v4)
- Store session in `sessions` table with userId, token, expiresAt
- Set `sessionToken` HTTP-only cookie (7 days if "remember me", 1 day otherwise)
- Return 200 with `{userId, email}` JSON
- Unit tests passing with ≥85% coverage

**Story 10**: "Handle login failure with error message"
- Invalid credentials return 401 status
- Response includes `{error: 'Invalid email or password'}`
- Error message displayed below form in red
- Login attempt logged for rate limiting (future story)
- Unit tests passing with ≥85% coverage

**Story 11**: "Implement logout endpoint"
- `POST /api/logout` endpoint
- Session token retrieved from cookie
- Session deleted from database
- Cookie cleared (maxAge=0)
- Return 200 with `{success: true}`
- Unit tests passing with ≥85% coverage

**Story 12**: "Display logout button in navigation"
- Logout button shown only when user authenticated
- Button click sends POST to `/api/logout`
- On success: redirect to `/login`
- On error: display toast notification
- Unit tests passing with ≥85% coverage

---

### Example 2: Product Search

**❌ BAD - Oversized Story**

**Story**: "Build product search with filters and sorting"

**Acceptance Criteria**:
- Search bar with autocomplete
- Filter by category, price range, brand
- Sort by price, rating, popularity
- Pagination
- Search results highlighting
- Mobile responsive design

**Problems**:
- 6+ distinct features bundled together
- Autocomplete alone is complex (requires debouncing, API calls)
- Cannot demo incrementally
- High coupling between features

---

**✅ GOOD - Atomic Stories (8 stories)**

**Story 1**: "Display search input field in header"
- Search input renders in site header
- Input has placeholder "Search products..."
- Input styled per design system
- Unit tests passing with ≥85% coverage

**Story 2**: "Execute search query on submit"
- `searchProducts(query)` function calls `/api/products/search`
- API accepts `query` parameter
- Returns array of products matching query in name/description
- Results displayed in grid layout
- Unit tests passing with ≥85% coverage

**Story 3**: "Add search result pagination"
- API accepts `page` and `limit` parameters (default: page=1, limit=20)
- Pagination controls rendered below results
- Next/Previous buttons disabled appropriately
- Page numbers displayed (current page highlighted)
- Unit tests passing with ≥85% coverage

**Story 4**: "Add category filter dropdown"
- Category dropdown renders with "All Categories" default
- Dropdown populated from `categories` API
- Selection adds `categoryId` parameter to search
- Results update on selection change
- Unit tests passing with ≥85% coverage

**Story 5**: "Add price range filter slider"
- Dual-handle slider for min/max price
- Price range displays above slider ($0 - $1000)
- Slider adds `minPrice` and `maxPrice` parameters
- Results update on slider change (debounced 500ms)
- Unit tests passing with ≥85% coverage

**Story 6**: "Add sort dropdown"
- Sort dropdown with options: Price (Low-High), Price (High-Low), Rating, Newest
- Selection adds `sortBy` and `sortOrder` parameters
- Results update on selection change
- Current sort persisted in URL query params
- Unit tests passing with ≥85% coverage

**Story 7**: "Add search autocomplete suggestions"
- Autocomplete dropdown appears below search input
- Shows top 5 product name matches
- API call debounced 300ms after typing stops
- Arrow keys navigate suggestions, Enter selects
- Unit tests passing with ≥85% coverage

**Story 8**: "Highlight search terms in results"
- Search query terms highlighted in yellow in product names
- Highlighting case-insensitive
- Multiple term matches all highlighted
- HTML entities escaped to prevent XSS
- Unit tests passing with ≥85% coverage

---

## Red Flags: Story Too Large

**STOP and decompose further if**:

### Title Red Flags
- Contains "AND" (e.g., "Create form AND validate AND submit")
- Contains "with" multiple times (e.g., "Dashboard with charts with filters with exports")
- Exceeds 10 words
- Requires semicolon or comma to explain

### Acceptance Criteria Red Flags
- More than 10 items
- Criteria describe multiple user flows
- Criteria span multiple system layers (UI + API + DB + Email)
- Criteria use vague terms ("handle", "manage", "process")

### Technical Red Flags
- Affects 5+ files
- Requires changes in 3+ system components
- Needs multiple database migrations
- Requires new external service integration

### Process Red Flags
- Cannot demo in single session (5-10 minutes)
- Requires complex test setup or fixtures
- Needs coordination with multiple team members
- Cannot be completed without blocking dependencies

### Cognitive Red Flags
- You struggle to write clear acceptance criteria
- You say "first we do X, then Y, then Z..." (workflow steps!)
- You think "this needs a checklist" (multiple stories!)
- PR reviewer would need > 30 minutes to review

---

## Quick Reference: Decomposition Decision Tree

```
START: You have a feature to decompose
│
├─ Can it be done in 2-5 minutes?
│  ├─ YES → ✅ It's already atomic! Write acceptance criteria.
│  └─ NO → Continue...
│
├─ Does it have sequential steps? (login → validate → create session)
│  └─ YES → Use Technique #1: Workflow Steps
│
├─ Does it have multiple business rules? (discounts, permissions, validations)
│  └─ YES → Use Technique #2: Business Rule Variations
│
├─ Does it mix simple and complex parts? (basic + advanced features)
│  └─ YES → Use Technique #4: Simple/Complex Split
│
├─ Does it handle different data types? (images, videos, documents)
│  └─ YES → Use Technique #5: Data Variations
│
├─ Does it involve CRUD operations? (create, read, update, delete)
│  └─ YES → Use Technique #7: Individual Operations
│
├─ Does it serve different user types? (admin, user, guest)
│  └─ YES → Use Technique #8: Use-Case Scenarios
│
├─ Does it have unknown technical complexity?
│  └─ YES → Use Technique #10: Research Spikes (timebox 2-3 hours)
│
└─ Still too large? Combine multiple techniques!
```

---

## Validation Checklist

Before finalizing decomposed stories, verify:

- [ ] Each story completable in 2-5 minutes
- [ ] Each story has 3-7 acceptance criteria
- [ ] Each story includes test coverage requirement (≥85%)
- [ ] Each story includes TypeScript type safety requirement
- [ ] Each story includes "all existing tests passing" requirement
- [ ] No story title contains "AND"
- [ ] Stories can be implemented in any order (or dependencies clearly marked)
- [ ] Stories deliver incremental value
- [ ] Total stories: 8-15 per feature (typical range)

---

## Common Mistakes to Avoid

### Mistake 1: Pseudo-Atomic Stories
**Problem**: Stories look small but hide complexity.

**Example**: "Add error handling"
- Too vague! Which errors? Which components?

**Fix**: Be specific per component:
- "Handle 400 errors in login API with user-friendly messages"
- "Handle network timeouts in product search with retry logic"
- "Handle file upload size exceeded with progress reset"

### Mistake 2: Dependency Hell
**Problem**: Stories tightly coupled, must be done in exact order.

**Example**:
- Story 1: Create database schema
- Story 2: Create API endpoint (BLOCKED by Story 1)
- Story 3: Create UI form (BLOCKED by Story 2)

**Fix**: Use vertical slicing - each story includes DB + API + UI for one small feature.

### Mistake 3: "Implement X" Without Context
**Problem**: Story title too generic.

**Example**: "Implement validation"

**Fix**: Be specific about WHAT and WHERE:
- "Validate email format on registration form"
- "Validate product price is positive number on create form"

### Mistake 4: Mixing Functional and Non-Functional
**Problem**: Bundling feature implementation with quality improvements.

**Example**: "Build API endpoint with rate limiting, caching, and monitoring"

**Fix**: Separate functional from non-functional (Technique #9):
- Story 1: Implement basic API endpoint
- Story 2: Add rate limiting (100 req/min per IP)
- Story 3: Add Redis caching (5 min TTL)
- Story 4: Add DataDog monitoring and alerts

### Mistake 5: Test-After Mindset
**Problem**: Treating tests as separate story.

**Example**:
- Story 1: Implement login function
- Story 2: Write tests for login

**Fix**: Tests are ALWAYS part of the implementation story. Every story's acceptance criteria includes "Unit tests passing with ≥85% coverage".

---

## Summary

**The Golden Rules**:
1. **2-5 minutes** per story (Anthropic guidance)
2. **3-7 acceptance criteria** per story
3. **Single responsibility** (no "AND" in title)
4. **Always include test coverage requirement** (≥85%)
5. **Always include type safety requirement** (TypeScript projects)
6. **Use ISPI techniques** to decompose systematically
7. **Validate atomicity** with checklist before finalizing

**Remember**: Smaller stories = faster feedback, easier testing, lower risk, happier developers.
