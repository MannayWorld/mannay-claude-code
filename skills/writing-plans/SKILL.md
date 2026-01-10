---
name: writing-plans
description: Use when you have a spec or requirements for a multi-step task, before touching code
---

# Writing Plans

## Overview

Write comprehensive implementation plans assuming the engineer has zero context for our codebase and questionable taste. Document everything they need to know: which files to touch for each task, code, testing, docs they might need to check, how to test it. Give them the whole plan as bite-sized tasks. DRY. YAGNI. TDD. Frequent commits.

Assume they are a skilled developer, but know almost nothing about our toolset or problem domain. Assume they don't know good test design very well.

**Announce at start:** "I'm using the writing-plans skill to create the implementation plan."

**Save plans to:** `planning/YYYY-MM-DD-<feature-name>.md`

## Framework Detection

**Before planning, detect project framework:**
- Read package.json to identify Next.js, Vite, CRA, or other
- Note framework version and key dependencies
- Adjust plan to use framework-specific patterns:
  - **Next.js**: App Router vs Pages Router, Server/Client Components, API routes
  - **Vite**: Fast builds, client-side patterns, backend integration
  - **CRA**: React Router, client-side state, API integration

## Bite-Sized Task Granularity

**Each step is one action (2-5 minutes):**
- "Write the failing test" - step
- "Run it to make sure it fails" - step
- "Implement the minimal code to make the test pass" - step
- "Run the tests and make sure they pass" - step
- "Commit" - step

## Plan Document Header

**Every plan MUST start with this header:**

```markdown
# [Feature Name] Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use mannay:executing-plans to implement this plan task-by-task.

**Goal:** [One sentence describing what this builds]

**Architecture:** [2-3 sentences about approach]

**Tech Stack:** [Key technologies/libraries, framework version]

**Framework:** [Next.js App Router / Vite / CRA / etc.]

**Quantified Standards:**
- Performance: [target Lighthouse score, bundle size limits]
- Testing: [coverage target, test types]
- Accessibility: [WCAG level]
- Security: [validation requirements, auth patterns]

---
```

## Task Structure

```markdown
### Task N: [Component Name]

**Files:**
- Create: `exact/path/to/file.ts` (or .tsx, .js, etc.)
- Modify: `exact/path/to/existing.ts:123-145`
- Test: `tests/exact/path/to/test.ts`

**Framework Patterns:**
- [Next.js: Server Component with data fetching]
- [Vite: Client-side with state management]
- [etc.]

**Step 1: Write the failing test**

```typescript
describe('SpecificFeature', () => {
  it('should handle specific behavior', () => {
    const result = functionUnderTest(input)
    expect(result).toEqual(expected)
  })
})
```

**Step 2: Run test to verify it fails**

Run: `pnpm test tests/path/test.ts`
Expected: FAIL with "functionUnderTest is not defined"

**Step 3: Write minimal implementation**

```typescript
export function functionUnderTest(input: InputType): ReturnType {
  return expected
}
```

**Step 4: Run test to verify it passes**

Run: `pnpm test tests/path/test.ts`
Expected: PASS (1/1 passing)

**Step 5: Commit**

```bash
git add tests/path/test.ts src/path/file.ts
git commit -m "feat: add specific feature"
```
```

## Agent and Command Integration

**Reference relevant Mannay tools in plans:**

**Domain Expertise Agents:**
- backend-architect - Data integrity, security, fault tolerance
- frontend-architect - UI/UX, accessibility, performance
- security-engineer - Auth, validation, OWASP compliance
- performance-engineer - Optimization, bottleneck elimination
- typescript-pro - Advanced type patterns, type safety
- api-designer - REST/GraphQL/tRPC contract design

**Quick Commands:**
- `/api-new` - Scaffold new API endpoint with validation
- `/component-new` - Create React component with TypeScript
- `/page-new` - Create Next.js page with App Router
- `/page-new-react` - Create React Router page (Vite/CRA)
- `/api-test` - Generate API endpoint tests
- `/types-gen` - Generate Supabase types (if using Supabase)

**Example integration in plan:**
```markdown
Task 3: API Endpoint Design
- Use api-designer agent to create contract-first API spec
- Then use /api-new command to scaffold endpoint
```

## Remember

- Exact file paths always
- Complete code in plan (not "add validation")
- Exact commands with expected output
- Always use `pnpm` (not npm) for package operations
- Reference relevant skills/agents/commands
- DRY, YAGNI, TDD, frequent commits
- Framework-appropriate patterns

## Execution Handoff

After saving the plan, offer execution choice:

**"Plan complete and saved to `planning/<filename>.md`. Two execution options:**

**1. Subagent-Driven (this session)** - I dispatch fresh subagent per task, review between tasks, fast iteration

**2. Parallel Session (separate)** - Open new session with executing-plans, batch execution with checkpoints

**Which approach?"**

**If Subagent-Driven chosen:**
- **REQUIRED SUB-SKILL:** Use mannay:requesting-code-review
- Stay in this session
- Fresh subagent per task + code review

**If Parallel Session chosen:**
- Guide them to open new session
- **REQUIRED SUB-SKILL:** New session uses mannay:executing-plans
