---
name: prd-builder
description: "Generate a Product Requirements Document (PRD) for Ralph autonomous execution. Use when planning a feature or project. Triggers on: 'create a prd', 'write prd', 'plan this feature', 'requirements for', 'spec out', 'user stories for', 'break down this feature'."
impact: MEDIUM
context: fork
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

# PRD Builder

> Transform vague ideas into execution-ready PRDs with atomic user stories.

## Overview

Interactive 6-phase workflow that generates Ralph-ready PRDs from feature ideas.

**Input:** Feature description from user
**Output:** `scripts/ralph/prd.json` ready for `/ralph-start`

## Prerequisites

- Feature idea or requirements to plan
- Understanding that this creates a PRD (does NOT implement)

## When to Use

| Use When | Don't Use When |
|----------|----------------|
| Need a PRD for Ralph mode | Already have a well-structured PRD |
| Feature needs atomic story breakdown | Doing exploratory research (use brainstorming) |
| Planning 3+ story feature | Single small task (doesn't need Ralph) |

## The #1 Rule: Story Size

**Each story must be completable in ONE Ralph iteration.**

Ralph spawns fresh per iteration with no memory. Too-big stories produce broken code.

| Right-Sized | Too Big (Split) |
|-------------|-----------------|
| Add database column + migration | Build entire dashboard |
| Add UI component to page | Add authentication |
| Update server action | Refactor entire API |

**Rule:** If you can't describe the change in 2-3 sentences, it's too big.

## Instructions

### Phase Overview

```
Phase 1: Requirements Discovery  -> Ask 5-10 clarifying questions
Phase 2: Design Exploration      -> Explore 2-3 design approaches
Phase 3: Technical Planning      -> Create detailed technical spec
Phase 4: Story Decomposition     -> Break into atomic stories (2-5 min each)
Phase 5: PRD Generation          -> Convert to Ralph JSON format
Phase 6: Quality Validation      -> Validate and create supporting files
```

### Phase 1: Requirements Discovery

Ask 5-10 clarifying questions with lettered options for quick answers.

**Key questions:**
- What problem does this solve?
- Who are the users?
- What are the core features?
- What should NOT be included?

See `references/phase-1-discovery.md` for detailed question templates.

### Phase 2: Design Exploration

Generate 2-3 design options with pros/cons and recommend one.

See `references/phase-2-design.md` for design option templates.

### Phase 3: Technical Planning

Create detailed technical spec: data models, APIs, components.

Invoke domain agents for validation (security-engineer, typescript-pro).

See `references/phase-3-technical.md` for spec templates.

### Phase 4: Story Decomposition (Critical)

Break tech spec into atomic stories using 10 decomposition techniques.

**Atomicity criteria:**
- 2-5 minutes implementation
- 3-7 acceptance criteria
- Single responsibility
- Unit testable

See `references/phase-4-decomposition.md` for detailed breakdown rules.

### Phase 5: PRD Generation

Convert stories to Ralph JSON format.

See `references/phase-5-generation.md` for JSON schema.

### Phase 6: Quality Validation

Validate JSON, check dependencies, create supporting files.

See `references/phase-6-validation.md` for validation checklist.

## Output Format

### Primary Output

**File:** `scripts/ralph/prd.json`

```json
{
  "projectName": "Feature Name",
  "branchName": "ralph/feature-slug",
  "description": "One-sentence description",
  "created": "YYYY-MM-DD",
  "userStories": [...],
  "completionPromise": "<promise>COMPLETE</promise>",
  "maxIterations": 20,
  "qualityGates": {
    "testCoverage": 85,
    "typeErrors": 0,
    "lintErrors": 0
  }
}
```

### Supporting Files

- `scripts/ralph/progress.txt` - Progress tracking
- `scripts/ralph/prompt.md` - Execution prompt

## Story Template (Quick Reference)

```json
{
  "id": "US-001",
  "title": "[Verb] [Noun] [Context]",
  "description": "As a [role], I want to [action] so I can [benefit]",
  "acceptanceCriteria": [
    "Specific criterion 1",
    "Specific criterion 2",
    "Unit tests passing (coverage >= 85%)",
    "TypeScript: 0 type errors"
  ],
  "priority": 1,
  "complexity": 3,
  "passes": false
}
```

See `references/story-template.md` for full template and examples.

## Error Handling

| Issue | Action |
|-------|--------|
| Requirements unclear | Ask more questions, don't proceed |
| Story too large (>10 criteria) | Split using decomposition techniques |
| Circular dependencies | Show graph, ask user to clarify |
| JSON validation fails | Show errors, fix and re-validate |

## Quality Standards

| Check | Requirement |
|-------|-------------|
| Story count | 3-20 stories (ideal range) |
| Acceptance criteria | 3-7 per story |
| Test coverage | >= 85% per story |
| Completion promise | Exactly `<promise>COMPLETE</promise>` |

## Examples

### E-commerce Checkout (8 Stories)

```
US-001: Create checkout API endpoint
US-002: Add cart validation
US-003: Add shipping address form
US-004: Add payment method selector
US-005: Integrate Stripe payment
US-006: Add order confirmation
US-007: Send confirmation email
US-008: Add error handling
```

See existing PRDs in `scripts/ralph/` for more examples.

## Integration

**Orchestrates:**
- requirements-analyst agent (Phase 1)
- brainstorming skill (Phase 2)
- feature-planning skill (Phase 3)
- Domain agents for validation

**Outputs to:**
- ralph-mode skill (autonomous execution)
- executing-plans skill (manual execution)

## Checklist Before Saving

- [ ] Asked clarifying questions with lettered options
- [ ] Each story completable in one iteration
- [ ] Stories ordered by dependency
- [ ] Every story has test/typecheck criteria
- [ ] UI stories have "Verify in browser" criterion
- [ ] 3-20 stories total
- [ ] JSON is valid

## Resources

- `references/phase-1-discovery.md` - Requirements questions
- `references/phase-2-design.md` - Design option templates
- `references/phase-3-technical.md` - Technical spec template
- `references/phase-4-decomposition.md` - Story breakdown rules
- `references/phase-5-generation.md` - JSON schema
- `references/phase-6-validation.md` - Validation checklist
- `references/story-template.md` - Story template and examples
- `templates/prd-schema.json` - JSON schema file
- `lib/validator.md` - Validation logic
- `lib/story-decomposer.md` - Decomposition logic
- `lib/prd-generator.md` - Generation logic

## Next Steps After PRD

```
1. Review PRD: cat scripts/ralph/prd.json | jq
2. Edit if needed
3. Start Ralph: /ralph-start
4. Monitor: /ralph-status
```
