---
name: prd-builder
description: "Generate a Product Requirements Document (PRD) for Ralph autonomous execution. Use when planning a feature or project. Triggers on: 'create a prd', 'write prd', 'plan this feature', 'requirements for', 'spec out', 'user stories for', 'break down this feature'."
category: planning
triggers:
  - "create a prd"
  - "write prd"
  - "plan this feature"
  - "requirements for"
  - "spec out"
  - "user stories"
  - "break down this feature"
  - "ralph prd"
---

# PRD Builder - Interactive PRD Generation for Ralph Mode

> **Transform vague ideas into execution-ready PRDs with atomic user stories, clear acceptance criteria, and quality validation.**

---

## The Job

1. Receive a feature description from the user
2. Ask 3-5 essential clarifying questions (with lettered options for quick answers)
3. Generate atomic user stories with verifiable acceptance criteria
4. Output `scripts/ralph/prd.json` ready for `/ralph-start`

**Important:** Do NOT start implementing. Just create the PRD.

---

## Story Size: The #1 Rule

**Each story must be completable in ONE Ralph iteration (~one context window).**

Ralph spawns a fresh instance per iteration with no memory of previous work. If a story is too big, the LLM runs out of context before finishing and produces broken code.

### Right-sized stories:
- Add a database column + migration
- Add a UI component to an existing page
- Update a server action with new logic
- Add a filter dropdown to a list

### Too big (split these):
- "Build the entire dashboard" → Split into: schema, queries, UI components, filters
- "Add authentication" → Split into: schema, middleware, login UI, session handling
- "Refactor the API" → Split into one story per endpoint or pattern

**Rule of thumb:** If you can't describe the change in 2-3 sentences, it's too big.

---

## When to Use

Use this skill when:
- ✅ You want to use Ralph mode but don't have a PRD yet
- ✅ You have a feature idea but need it broken into stories
- ✅ You need atomic user stories (2-5 min tasks) for autonomous execution
- ✅ You want validated PRDs following Anthropic's ralph-wiggum best practices

**DON'T use when:**
- ❌ You already have a well-structured PRD
- ❌ You're doing exploratory research (use brainstorming instead)
- ❌ The feature is a single small task (doesn't need Ralph)

## How This Works

This skill orchestrates a 6-phase interactive workflow:

```
Phase 1: Requirements Discovery (requirements-analyst agent)
    ↓
Phase 2: Design Exploration (brainstorming skill)
    ↓
Phase 3: Technical Planning (feature-planning skill)
    ↓
Phase 4: Story Decomposition (NEW - atomic story breakdown)
    ↓
Phase 5: PRD Generation (NEW - Ralph JSON output)
    ↓
Phase 6: Quality Validation (NEW - schema + atomicity checks)
```

**Output:** `scripts/ralph/prd.json` ready for `/ralph-start`

---

## Phase 1: Requirements Discovery

**Objective:** Understand what the user wants to build through Socratic questioning.

**Process:**

1. **Invoke requirements-analyst agent** with user's initial idea
2. **Ask clarifying questions** (5-10 questions):
   - What problem does this solve?
   - Who are the users?
   - What are the core features?
   - What are the constraints (tech stack, timeline, budget)?
   - What does success look like?
   - Are there existing patterns to follow?
   - What are the edge cases?
   - What should NOT be included?

3. **Document answers** in structured format:
```markdown
## Requirements Discovery

**Problem Statement:** [Clear 1-2 sentence problem]

**Target Users:** [Who will use this]

**Core Features:** [Bulleted list of must-haves]

**Constraints:**
- Tech Stack: [Existing technologies]
- Non-Negotiables: [Hard requirements]
- Out of Scope: [What we're NOT building]

**Success Criteria:** [How we measure success]
```

4. **Validate understanding** with user before proceeding

**Output:** Requirements discovery document saved to `docs/plans/YYYY-MM-DD-<feature>-requirements.md`

---

## Phase 2: Design Exploration

**Objective:** Explore 2-3 design approaches and select the best one.

**Process:**

1. **Invoke brainstorming skill** with requirements document
2. **Generate design options** (2-3 approaches):
   - Option A: [Approach with pros/cons]
   - Option B: [Alternative with trade-offs]
   - Option C: [Third option if applicable]

3. **Present to user** with recommendations:
```markdown
## Design Options

### Option A: [Name]
**Pros:**
- [Benefit 1]
- [Benefit 2]

**Cons:**
- [Limitation 1]
- [Limitation 2]

**Complexity:** [Low/Medium/High]

### Option B: [Name]
[Same structure]

**Recommendation:** Option A because [rationale]
```

4. **User selects** preferred approach
5. **Document decision** with rationale

**Output:** Design document saved to `docs/plans/YYYY-MM-DD-<feature>-design.md`

---

## Phase 3: Technical Planning

**Objective:** Create detailed technical specification with implementation details.

**Process:**

1. **Invoke feature-planning skill** with chosen design
2. **Generate technical spec** including:
   - Architecture overview
   - Data models (with exact field names/types)
   - API specifications (endpoints, request/response formats)
   - Component hierarchy (frontend structure)
   - Testing strategy
   - Security considerations
   - Performance requirements

3. **Invoke relevant agents** for validation:
   - **security-engineer**: Review auth/validation approach
   - **typescript-pro**: Validate type definitions
   - **backend-architect**: Review data model and API design
   - **frontend-architect**: Review component architecture

4. **Refine based on agent feedback**

**Output:** Technical spec saved to `docs/plans/YYYY-MM-DD-<feature>-spec.md`

---

## Phase 4: Story Decomposition (CRITICAL PHASE)

**Objective:** Break technical spec into atomic user stories (2-5 min tasks each).

**Based on Anthropic's Ralph Wiggum guidance and ISPI atomic user stories framework.**

### Story Granularity Rules

**What makes a story atomic?**
> "The smallest demonstrable, working piece of useful functionality" (ISPI definition)

**Duration Target:** 2-5 minutes of implementation time

**Scope:** Single responsibility, one core functionality

**Testing:** Unit tests can validate without complex dependencies

**Review:** Pull request reviewable in 15-30 minutes

### Decomposition Techniques

Use these 10 techniques from ISPI framework:

1. **Workflow Steps** - Break into sequential steps (register → verify email → login)
2. **Business Rule Variations** - Separate different validation rules
3. **Major Effort Areas** - Frontend vs backend vs database
4. **Simple/Complex** - Basic version first, then complexity
5. **Data Variations** - Different input types (email vs OAuth)
6. **Data Entry Methods** - Form vs API vs import
7. **Individual Operations** - Separate CRUD operations (Create ≠ Read ≠ Update ≠ Delete)
8. **Use-Case Scenarios** - Happy path vs error paths
9. **Non-Functional Qualities** - Performance, security as separate stories
10. **Research Spikes** - Separate investigation from implementation

### Story Creation Process

1. **Read technical spec** section by section
2. **For each major feature**, apply decomposition techniques:

**Example: "User Authentication"**

```
❌ BAD (too large):
US-001: Implement user authentication with registration, login, logout,
password reset, email verification, and OAuth

✅ GOOD (atomic stories):
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

3. **Validate story size** - Red flags indicating too large:
   - Multiple "AND" conditions in title
   - Acceptance criteria > 10 items
   - Multiple system components affected
   - Cannot demo in single session
   - Requires complex test setup

4. **Order stories** by priority and dependencies:
   - **P0 (Critical)**: Foundation, blockers, security
   - **P1 (High)**: Core features, major functionality
   - **P2 (Medium)**: Enhancements, polish
   - **P3 (Low)**: Nice-to-haves, technical debt

### Acceptance Criteria Format

**Based on ChatPRD Claude Code guidance:**

**Use discrete bullet points, NOT prose:**

```
✅ GOOD:
- Email input accepts valid email format (regex: /^[^\s@]+@[^\s@]+\.[^\s@]+$/)
- Invalid email shows error: "Please enter a valid email address"
- Error appears below input field in red text
- Form cannot submit with invalid email
- Tests passing (coverage ≥ 85%)
- TypeScript types defined with no 'any'

❌ BAD:
The system should validate email input and show an error message if invalid,
preventing form submission until the user enters a valid email address.
```

**Guidelines:**
- Aim for 3-7 criteria per story (if > 10, story is too large)
- Each criterion is independently verifiable
- Include specific values/formats (not "validate properly")
- Always include test coverage requirement (≥ 80% or ≥ 85%)
- Always include TypeScript type safety requirement
- Include performance thresholds when applicable
- Include accessibility requirements (WCAG 2.1 AA)

### Testing Requirements (Mandatory)

**Every story MUST include:**

```
- [ ] Unit tests passing (coverage ≥ 85%)
- [ ] Integration tests passing (if applicable)
- [ ] TypeScript: 0 type errors, no 'any' types
- [ ] ESLint: 0 errors, 0 warnings
- [ ] All existing tests still passing
```

**From LIDR Academy standards:**
- Test-Driven Development (write tests first)
- 90%+ test coverage across all layers
- Security validation (input sanitization, auth checks)

### Story Template

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
- [ ] Unit tests passing (coverage ≥ 85%)
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

**Process:**

1. For each section of technical spec, create stories using template
2. Apply decomposition techniques to break large features
3. Validate each story meets atomicity criteria
4. Order stories by dependencies and priority
5. Review with user: "I've broken this into [N] stories. Does this granularity look right?"

**Output:** Collection of atomic user stories ready for JSON conversion

---

## Phase 5: PRD Generation

**Objective:** Convert atomic stories into Ralph-ready JSON format.

**Based on Anthropic's official ralph-wiggum plugin template.**

### Ralph JSON Format

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

### JSON Generation Process

1. **Create project metadata**:
   ```json
   {
     "projectName": "[Extract from requirements]",
     "branchName": "ralph/[kebab-case-feature-name]",
     "description": "[One-sentence summary]",
     "created": "[Today's date: YYYY-MM-DD]"
   }
   ```

2. **Convert each story** to JSON:
   - `id`: Sequential (US-001, US-002, ...)
   - `title`: From story template
   - `description`: User story narrative
   - `acceptanceCriteria`: Array of discrete bullets
   - `technicalRequirements`: Object with specific details
   - `dependencies`: Object with dependsOn/blocks arrays
   - `priority`: 1-4 (lower = higher priority)
   - `complexity`: 1-5 (estimate of story complexity)
   - `passes`: false (initially)
   - `notes`: Context from technical spec
   - `blocked`: false (initially)
   - `blockedReason`: "" (initially)

3. **Add completion criteria** (from Anthropic guidance):
   ```json
   {
     "completionPromise": "<promise>COMPLETE</promise>",
     "maxIterations": 20
   }
   ```

4. **Add quality gates**:
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

5. **Save to file**: `scripts/ralph/prd.json`

**Output:** Ralph-ready JSON PRD saved to `scripts/ralph/prd.json`

---

## Phase 6: Quality Validation

**Objective:** Validate PRD meets all quality standards before Ralph execution.

### Validation Checks

**1. JSON Schema Validation**

```bash
# Validate against JSON schema
jq empty scripts/ralph/prd.json
```

Expected: No errors

**2. Story Atomicity Check**

For each story, verify:
- ✅ Acceptance criteria: 3-7 items (not < 3 or > 10)
- ✅ Title contains verb + noun + context
- ✅ Description follows "As a [role], I want to [action] so I can [benefit]"
- ✅ Has test coverage requirement (≥ 80% or ≥ 85%)
- ✅ Has type safety requirement
- ✅ Has linting requirement
- ✅ Priority assigned (1-4)
- ✅ Dependencies documented if any

**3. Dependency Validation**

- ✅ No circular dependencies (US-001 depends on US-002, US-002 depends on US-001)
- ✅ All referenced dependencies exist (US-005 depends on US-999 that doesn't exist)
- ✅ Priority ordering respects dependencies (high-priority story depends on low-priority)

**4. Completion Criteria Check**

- ✅ `completionPromise` is exactly `<promise>COMPLETE</promise>`
- ✅ `maxIterations` is set (recommended: 20-50)
- ✅ Quality gates defined

**5. Story Count Check**

From Anthropic guidance and best practices:
- ⚠️ If < 3 stories: Consider if Ralph is necessary (might be too small)
- ✅ 3-20 stories: Ideal range for Ralph execution
- ⚠️ If > 20 stories: Consider breaking into multiple PRDs or phases

### Validation Report

Generate validation report:

```markdown
## PRD Validation Report

**Project:** [name]
**Total Stories:** [N]
**Date:** [YYYY-MM-DD]

### ✅ Passed Checks
- JSON schema valid
- All stories atomic (3-7 acceptance criteria)
- No circular dependencies
- Completion promise correct
- Quality gates defined

### ⚠️ Warnings
- [Any warnings, e.g., "20+ stories, consider splitting"]

### ❌ Errors
- [Any errors that must be fixed]

### Recommendations
- [Suggestions for improvement]

**Status:** READY FOR RALPH / NEEDS REVISION
```

### Supporting Files Generation

**1. Create progress.txt**

```bash
cp scripts/ralph/templates/progress.txt scripts/ralph/progress.txt
```

**2. Create AGENTS.md** (if doesn't exist)

```bash
cp scripts/ralph/templates/AGENTS.md scripts/ralph/AGENTS.md
```

**3. Create prompt.md** (Ralph execution prompt)

```markdown
# Ralph Execution Prompt

You are Ralph, executing the PRD at `scripts/ralph/prd.json`.

## Instructions

1. Read `scripts/ralph/prd.json`
2. Read `scripts/ralph/progress.txt` (check Codebase Patterns section first)
3. Read `scripts/ralph/AGENTS.md` (if exists)
4. Select highest priority story where `passes: false`
5. Implement that ONE story using TDD
6. Run tests - must pass with coverage ≥ 85%
7. Run linting - must pass with 0 errors
8. Commit with message: `feat: [STORY_ID] - [Story Title]`
9. Update `prd.json`: set story's `passes: true`
10. Append learnings to `progress.txt`

When ALL stories have `passes: true`, output exactly:

<promise>COMPLETE</promise>
```

Save to `scripts/ralph/prompt.md`

**Output:** Validated PRD + supporting files ready for `/ralph-start`

---

## Integration with Existing Skills

**This skill orchestrates:**

1. **requirements-analyst agent** - Phase 1 (discovery)
2. **brainstorming skill** - Phase 2 (design)
3. **feature-planning skill** - Phase 3 (technical spec)
4. **security-engineer agent** - Validation throughout
5. **typescript-pro agent** - Type validation
6. **backend-architect agent** - Data model review
7. **frontend-architect agent** - Component review

**This skill outputs PRD for:**

1. **ralph-mode skill** - Autonomous execution of generated PRD
2. **executing-plans skill** - Manual execution if preferred

---

## Quality Standards

**Story Granularity:**
- Each story: 2-5 minutes implementation time
- Acceptance criteria: 3-7 discrete bullets
- Test coverage: ≥ 85% per story
- No story > 10 acceptance criteria (split if larger)

**PRD Quality:**
- JSON schema valid
- No circular dependencies
- Completion promise exactly: `<promise>COMPLETE</promise>`
- All stories have test/lint requirements
- Priority ordering logical

**Documentation:**
- Requirements doc: Problem, users, features, constraints
- Design doc: Options with pros/cons, selected approach
- Technical spec: Data models, APIs, components
- PRD JSON: Ralph-ready format

---

## User Experience Flow

```
User: "Build a PRD for user profile management"

PRD Builder activates:

Phase 1: Requirements Discovery
  → "What can users do with profiles?"
  → "What fields? (name, email, avatar, bio?)"
  → "Any privacy controls?"
  → User answers 5-10 questions
  → Requirements documented

Phase 2: Design Exploration
  → Option A: Single page with inline editing
  → Option B: View mode + edit modal
  → Option C: Multi-step wizard
  → User selects: "Option A"

Phase 3: Technical Planning
  → API: GET/PUT /api/users/:id
  → Component: ProfilePage, ProfileForm
  → Validation: email, required fields
  → Auth: Protected routes
  → security-engineer reviews
  → typescript-pro validates types

Phase 4: Story Decomposition
  → US-001: Create user profile API endpoint (GET)
  → US-002: Create profile update API (PUT)
  → US-003: Add profile validation schema
  → US-004: Create ProfileForm component
  → US-005: Add avatar upload
  → US-006: Wire form to API
  → US-007: Add loading states
  → US-008: Add error handling
  → [8 atomic stories total]

Phase 5: PRD Generation
  → Converts to JSON format
  → Saves to scripts/ralph/prd.json

Phase 6: Quality Validation
  → JSON schema: ✅ Valid
  → Story atomicity: ✅ All 3-7 criteria
  → Dependencies: ✅ No circular deps
  → Completion promise: ✅ Correct format
  → Story count: ✅ 8 stories (ideal range)
  → Creates progress.txt and prompt.md

Output:
  "✅ PRD ready! Run `/ralph-start` to begin autonomous execution.
   Or review `scripts/ralph/prd.json` and edit if needed."
```

---

## Error Handling

**If requirements unclear:**
- Ask more clarifying questions
- Don't proceed until validated

**If design options tie:**
- Present trade-offs
- Ask user to make decision
- Document rationale

**If story too large (> 10 acceptance criteria):**
- Apply decomposition techniques
- Split into 2+ smaller stories
- Re-validate atomicity

**If circular dependencies detected:**
- Show dependency graph
- Ask user to clarify order
- Restructure stories

**If validation fails:**
- Show validation report with errors
- Ask user to review and approve fixes
- Re-run validation after fixes

---

## Red Flags

**Never:**
- Skip requirements discovery (don't assume what user wants)
- Skip validation checks (invalid JSON will fail Ralph)
- Create stories > 10 acceptance criteria (split them)
- Use prose for acceptance criteria (discrete bullets only)
- Omit test coverage requirements (mandatory for Ralph)
- Skip dependency documentation (Ralph needs execution order)
- Proceed without user confirmation at each phase

**If uncertain:**
- Ask clarifying questions
- Show examples of good vs bad stories
- Offer to split large stories
- Validate atomicity with user

---

## Examples

### Example 1: E-commerce Checkout

**Requirements Discovery:**
```
Problem: Users abandon carts, need streamlined checkout
Users: E-commerce shoppers
Features: Guest checkout, saved addresses, multiple payment methods
Constraints: PCI compliance, existing Stripe integration
```

**Design Selected:**
Option B: Single-page checkout with progress indicator

**Stories Generated (Sample):**
```
US-001: Create checkout API endpoint (POST /api/checkout/init)
US-002: Add cart validation (items exist, stock available)
US-003: Add shipping address form component
US-004: Add payment method selector component
US-005: Integrate Stripe payment intent
US-006: Add order confirmation screen
US-007: Send confirmation email
US-008: Add error handling and retry logic
```

**Validation:**
- 8 stories: ✅ Ideal range
- Each 3-5 criteria: ✅ Atomic
- Dependencies clear: ✅ US-005 depends on US-001
- Test coverage: ✅ All stories have ≥85% requirement

---

## Command Integration

**After PRD generated, offer:**

```
✅ PRD ready at `scripts/ralph/prd.json`

Next steps:

1. Review PRD: `cat scripts/ralph/prd.json | jq`
2. Edit if needed: `[editor] scripts/ralph/prd.json`
3. Start Ralph: `/ralph-start`
4. Monitor progress: `/ralph-status`

Or execute manually with requesting-code-review skill.
```

---

## Integration

**Called by:**
- User directly — For Ralph PRD creation
- `feature-planning` — When Ralph automation desired

**Pairs with:**
- `brainstorming` — Phase 2: Design exploration
- `feature-planning` — Phase 3: Technical planning
- `ralph-mode` — Execute the generated PRD
- `requirements-analyst` agent — Phase 1: Discovery
- Domain agents — Validation throughout

---

## Checklist Before Saving

Before writing prd.json, verify:

- [ ] Asked clarifying questions with lettered options
- [ ] Each story is completable in one iteration (small enough)
- [ ] Stories are ordered by dependency (schema → backend → UI)
- [ ] Every story has "npm run typecheck passes" as criterion
- [ ] UI stories have "Verify in browser" as criterion
- [ ] Acceptance criteria are verifiable (not vague like "works correctly")
- [ ] No story depends on a later story (correct dependency order)
- [ ] 3-20 stories total (ideal range for Ralph)
- [ ] JSON is valid (test with `jq empty scripts/ralph/prd.json`)
