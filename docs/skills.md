# Skills Reference

> Complete reference for all Mannay skills (systematic workflows).

## Overview

Skills are **systematic workflows** that auto-activate based on task type. They ensure best practices and quality standards.

```
┌─────────────────────────────────────────────────────────────────────┐
│                          USER REQUEST                                │
│                    "Add user authentication"                         │
└─────────────────────────────────┬───────────────────────────────────┘
                                  │
                                  ▼
┌─────────────────────────────────────────────────────────────────────┐
│                         USING-MANNAY                                 │
│                    (Meta-Orchestrator)                               │
│                                                                      │
│   1. Detect task type: NEW FEATURE                                  │
│   2. Activate mandatory skill: brainstorming                        │
│   3. Identify domains: auth, API, security                          │
│   4. Queue agents: security-engineer, backend-architect, api-designer│
└─────────────────────────────────┬───────────────────────────────────┘
                                  │
          ┌───────────────────────┼───────────────────────┐
          │                       │                       │
          ▼                       ▼                       ▼
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│  BRAINSTORMING  │───►│  TASK-ANALYSIS  │───►│  WRITING-PLANS  │
│  Design first   │    │  Break it down  │    │  Detailed steps │
└─────────────────┘    └─────────────────┘    └─────────────────┘
                                                       │
                                                       ▼
┌─────────────────────────────────────────────────────────────────────┐
│                    IMPLEMENTATION PHASE                              │
│                                                                      │
│   ┌─────────────────────────────────────────────────────────────┐  │
│   │                         TDD CYCLE                            │  │
│   │    Write Test ──► Run (Fail) ──► Code ──► Run (Pass) ──► ♻️ │  │
│   └─────────────────────────────────────────────────────────────┘  │
│                              │                                      │
│   ┌──────────────────────────┼──────────────────────────┐          │
│   │                          │                          │          │
│   ▼                          ▼                          ▼          │
│ ┌────────────────┐  ┌────────────────┐  ┌────────────────┐        │
│ │security-engineer│  │backend-architect│  │  api-designer  │        │
│ │ Review auth    │  │ Schema design  │  │ Endpoint specs │        │
│ └────────────────┘  └────────────────┘  └────────────────┘        │
│                                                                      │
└─────────────────────────────────────────────────────────────────────┘
                                  │
                                  ▼
┌─────────────────────────────────────────────────────────────────────┐
│                          GIT COMMIT                                  │
│              feat(auth): add user authentication                     │
└─────────────────────────────────────────────────────────────────────┘
```

---

## Skill Categories

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                               SKILLS                                         │
├─────────────────┬────────────────┬────────────────┬────────────────────────┤
│   MANDATORY     │   PLANNING     │   EXECUTION    │    QUALITY/DESIGN      │
│   (Auto-On)     │                │                │                        │
├─────────────────┼────────────────┼────────────────┼────────────────────────┤
│ • TDD           │ • task-analysis│ • executing-   │ • code-review          │
│ • debugging     │ • feature-     │   plans        │ • api-testing          │
│ • brainstorming │   planning     │ • ralph-mode   │ • frontend-design      │
│ • git           │ • writing-plans│                │ • adaptive-design (*)  │
│ • adaptive-     │ • prd-builder  │                │ • ui-animation (*)     │
│   design (*)    │                │                │ • compound-eng         │
│ • ui-animation  │                │                │ • web-design-guidelines│
│   (*)           │                │                │ • react-best-practices │
└─────────────────┴────────────────┴────────────────┴────────────────────────┘
                     (*) MANDATORY for any visual work
```

---

## Mandatory Skills (Auto-Activate)

These activate **automatically** - no trigger needed:

### test-driven-development

**Activates:** Any code change

**Process:** RED-GREEN-REFACTOR
1. Write failing test
2. Verify it fails
3. Write minimal code to pass
4. Verify it passes
5. Refactor
6. Commit

**Integration:**
- Called by: `brainstorming`, `feature-planning`, `task-analysis`
- Pairs with: `systematic-debugging`, `code-reviewer`, `git`

---

### systematic-debugging

**Activates:** Any bug, error, or unexpected behavior

**Process:** 4-Phase Root Cause Analysis
1. **Phase 1:** Root cause investigation
2. **Phase 2:** Pattern analysis
3. **Phase 3:** Hypothesis and testing
4. **Phase 4:** Implementation with TDD

**Integration:**
- Called by: Any skill encountering errors
- Pairs with: `test-driven-development`, `git`

---

### brainstorming

**Activates:** New feature or significant change

**Process:**
1. Understand project context
2. Ask clarifying questions (one at a time)
3. Propose 2-3 approaches
4. Present design in sections
5. Invoke relevant agents
6. Document decision

**Integration:**
- Called by: `prd-builder`, `feature-planning`
- Pairs with: `task-analysis`, `writing-plans`, `feature-planning`

---

### git

**Activates:** Commits, pushes, branches, PRs

**Process:** Conventional commits
- Format: `type(scope): description`
- Types: feat, fix, docs, style, refactor, perf, test, build, ci, chore
- NO Co-Authored-By or credits

**Integration:**
- Called by: All implementation skills
- Pairs with: All skills after code changes

---

## Planning Skills

### task-analysis

**Triggers:** "implement this", "build this", "break this down"

**Process:**
1. Detect project context
2. Analyze task complexity
3. Create implementation plan
4. Recommend agents

**Integration:**
- Called by: User directly, `brainstorming`
- Pairs with: `writing-plans`, `executing-plans`, `TDD`

---

### feature-planning

**Triggers:** "plan this feature", "feature spec"

**Process:**
1. Feature breakdown (user stories, requirements)
2. Technical specification
3. Implementation plan (6 phases)
4. Invoke relevant agents

**Integration:**
- Called by: User, `brainstorming`, `task-analysis`
- Pairs with: `prd-builder`, `writing-plans`, `TDD`

---

### writing-plans

**Triggers:** "write a plan", "detailed plan"

**Process:**
1. Analyze requirements
2. Create step-by-step plan
3. Define verification criteria
4. Structure for execution

**Integration:**
- Called by: `task-analysis`, `feature-planning`
- Pairs with: `executing-plans`

---

### executing-plans

**Triggers:** "execute this plan", "implement the plan"

**Process:**
1. Load plan
2. Execute in batches
3. Verify after each batch
4. Report progress

**Integration:**
- Called by: After plan written
- Pairs with: `writing-plans`, `TDD`, `git`

---

## PRD & Ralph Skills

### prd-builder

**Triggers:** "create a prd", "write prd", "spec out"

**Process:** 6 Phases
1. Requirements discovery
2. Design exploration
3. Technical planning
4. Story decomposition
5. PRD generation (JSON)
6. Quality validation

**Integration:**
- Called by: User directly
- Pairs with: `brainstorming`, `ralph-mode`

---

### ralph-mode

**Triggers:** "run ralph", "start ralph", "autonomous mode"

**Process:** 7 Phases per iteration
1. Context loading
2. Story selection
3. Story execution (TDD)
4. Verification
5. **Commit (mandatory)**
6. Update files
7. Completion check

**Integration:**
- Called by: `prd-builder` via `/ralph-start`
- Pairs with: `TDD`, `git`, domain agents

---

## Quality Skills

### requesting-code-review

**Triggers:** "review this code", "code review"

**Process:** Two-stage review
1. Spec compliance review
2. Code quality review

**Integration:**
- Pairs with: `TDD`, `git`

---

### api-testing

**Triggers:** "test this api", "api tests"

**Process:**
1. Happy path tests
2. Error cases
3. Edge cases
4. Security tests

**Integration:**
- Pairs with: `TDD`, `api-designer`

---

## Design Skills

### frontend-design

**Triggers:** "build a page", "create component", "design UI"

**Process:**
- Distinctive visual design
- Avoid generic "AI aesthetics"
- Tone palette and typography
- Accessibility built-in

**Integration:**
- Pairs with: `adaptive-design`, `ui-animation`, `frontend-architect`, `accessibility-specialist`

---

### adaptive-design (MANDATORY for visual)

**Activates:** Any visual component, page, or UI element

**Process:**
1. Design with real data (not idealized mocks)
2. Test edge cases: empty, minimal, maximum content
3. Use constraint-based layouts, not fixed pixels
4. Handle missing images, long text, overflow
5. Responsive across 320px - 2560px viewports

**Key Principles:**
- Data informs and constrains design
- Edge cases surface during design, not development
- Use `clamp()`, `minmax()`, container queries
- Test with real names, real images, real text

**Integration:**
- Called by: `frontend-design`, `component-new`, `page-new`
- Pairs with: `ui-animation`, `web-design-guidelines`, `frontend-architect`

---

### ui-animation (MANDATORY for visual)

**Activates:** Any visual component, page, or UI element

**Process:**
1. Apply precise timing (all UI < 300ms except drawers)
2. Use correct easing (90% ease-out)
3. Animate only transform + opacity
4. Set correct transform-origin
5. Respect `prefers-reduced-motion`

**Quick Reference:**
```
Button press:     scale(0.97), 150ms, ease-out
Tooltip:          scale(0.97), 125ms, ease-out
Modal:            scale(0.93), 200ms, ease-out
Dropdown:         scale(0.93), 180ms, ease-out
Drawer (iOS):     500ms, cubic-bezier(0.32, 0.72, 0, 1)
Toast dismiss:    4 seconds (pause when inactive)
```

**Integration:**
- Called by: `frontend-design`, `component-new`, `page-new`
- Pairs with: `adaptive-design`, `web-design-guidelines`, `react-best-practices`

---

### compound-engineering

**Triggers:** "systematic development", "compound work"

**Process:** 4-Phase Loop
1. Plan (40%)
2. Work (20%)
3. Review (20%)
4. Compound (20%)

Each unit of work makes future work easier.

---

### web-design-guidelines

**Triggers:** "ui design", "ux review", "design audit", "accessibility check"

**Impact:** HIGH

**Process:**
- Audit UI against 11 rule categories
- Color contrast (WCAG AA 4.5:1)
- Typography (16px min body)
- Touch targets (44px min)
- Visual hierarchy and whitespace
- Responsive design patterns

**Integration:**
- Pairs with: `frontend-architect`, `accessibility-specialist`, `frontend-design`

---

### react-best-practices

**Triggers:** "React", "Next.js", "performance", "re-render", "bundle size"

**Impact:** CRITICAL

**Process:** 45 rules across 8 priority categories
1. Eliminating Waterfalls (CRITICAL) - async patterns, Promise.all
2. Bundle Size Optimization (CRITICAL) - dynamic imports, barrel avoidance
3. Server-Side Performance (HIGH) - React.cache(), LRU caching
4. Client-Side Data Fetching (MEDIUM-HIGH) - SWR deduplication
5. Re-render Optimization (MEDIUM) - memo, state patterns
6. Rendering Performance (MEDIUM) - content-visibility, SVG
7. JavaScript Performance (LOW-MEDIUM) - loops, caching
8. Advanced Patterns (LOW) - refs, callbacks

**Integration:**
- Pairs with: `frontend-architect`, `performance-engineer`, `code-reviewer`

---

## Orchestrator

### using-mannay

**Purpose:** Meta-orchestrator for all skills and agents

**Behavior:**
- Detects task type
- Activates mandatory skills
- Chains relevant agents
- Applies intent detection

**Integration:**
- Orchestrates all skills and agents
