---
name: task-analysis
description: "Analyze task complexity and create an actionable implementation plan. Use when given a task without a plan. Triggers on: 'implement this', 'build this feature', 'add this functionality', 'how long will this take', 'break this down', 'what's involved in'."
triggers:
  - "implement this"
  - "build this feature"
  - "add this"
  - "how long will this take"
  - "break this down"
  - "what's involved"
  - "create a plan"
---

# Task Analysis

Analyze task complexity and create a clear, actionable implementation plan.

**Announce at start:** "I'm using the task-analysis skill to analyze this task."

## When to Use

Use this skill when:
- User provides a task description without a detailed plan
- You need to break down a complex task into steps
- You need to estimate time and identify risks
- Task complexity is unclear

**Do NOT use if:**
- User already has a detailed plan (use mannay:executing-plans instead)
- Task is creative/exploratory (use mannay:brainstorming instead)
- Task is already broken down into steps

## Process

### Step 1: Detect Project Context

Before analyzing:
- Read package.json to detect framework (Next.js, Vite, CRA)
- Check existing patterns in codebase
- Note framework version and key dependencies
- Identify relevant Mannay agents that might help

### Step 2: Analyze Task

Use this framework:

**Task Breakdown:**
- Understand requirements
- Identify dependencies
- List affected files/components
- Estimate complexity (Small/Medium/Large/Very Large)

**Complexity Scale:**
- **Small**: 1-2 hours (simple bug fix, minor feature)
- **Medium**: Half day to 1 day (new component, API endpoint)
- **Large**: 2-5 days (complex feature, multiple integrations)
- **Very Large**: 1+ week (major refactor, new subsystem)

**Risk Assessment:**
Identify potential blockers:
- Unknown dependencies
- API limitations
- Data migration needs
- Breaking changes
- Third-party service issues
- Framework constraints

**INVOKE Relevant Agents (MANDATORY):**

Based on what the task involves, INVOKE these agents using the Task tool:

| Task Involves | INVOKE These Agents |
|---------------|---------------------|
| Database, data models, APIs | `backend-architect` + `api-designer` |
| UI components, pages | `frontend-architect` + `frontend-design` |
| User input, forms | `accessibility-specialist` |
| Auth, passwords, security | `security-engineer` + `backend-architect` |
| Complex TypeScript types | `typescript-pro` |
| Performance concerns | `performance-engineer` |
| Code quality review | `code-reviewer` |

**Example:** For a "user dashboard" task:
```
1. INVOKE frontend-architect → Component structure
2. INVOKE frontend-design → Visual design approach
3. INVOKE accessibility-specialist → WCAG requirements
4. INVOKE backend-architect → API design (if data needed)
```

Do NOT just mention agents. Actually invoke them with the Task tool during analysis.

### Step 3: Create Implementation Plan

Create sequential, logical steps following TDD:

**Phase Structure:**
1. **Setup/Preparation**
   - Install dependencies (use pnpm)
   - Configuration changes
   - Environment setup

2. **Test-First Development** (use mannay:test-driven-development)
   - Write failing tests FIRST
   - Implement minimal code to pass tests
   - Refactor

3. **Integration**
   - Connect components
   - API integration
   - State management

4. **Quality Assurance**
   - Test coverage (≥80%)
   - Performance validation
   - Accessibility checks (WCAG 2.1 AA)
   - Security review

5. **Documentation & Deployment**
   - Update docs
   - Create PR
   - Deploy

### Step 4: Output Analysis

**Format:**

```markdown
### Task Analysis
- **Type**: [Bug Fix / Feature / Refactor / Infrastructure]
- **Complexity**: [Small / Medium / Large / Very Large]
- **Estimated Time**: X hours/days
- **Priority**: [High / Medium / Low]
- **Framework**: [Next.js 14 / Vite 5 / CRA / etc.]

### Recommended Approach

**Mannay Tools:**
- Use mannay:test-driven-development for implementation
- Consider [agent-name] agent for [reason]
- Use /[command] for [quick scaffolding]

### Implementation Plan

**Phase 1: [Name]** (Time estimate)
- [ ] Write failing test for X
- [ ] Implement X
- [ ] Verify test passes
- [ ] Commit

**Phase 2: [Name]** (Time estimate)
- [ ] Write failing test for Y
- [ ] Implement Y
- [ ] Verify test passes
- [ ] Commit

### Files to Modify/Create
```
app/api/route.ts (create)
components/Component.tsx (modify)
lib/utils.ts (modify)
tests/component.test.tsx (create)
```

### Dependencies
```bash
pnpm install package-name
```

### Framework-Specific Considerations
- [Next.js: Server Component vs Client Component decision]
- [Vite: Bundle size impact, code splitting]
- [Edge Runtime compatibility if Next.js]

### Testing Strategy
- Unit tests for utilities (≥80% coverage)
- Integration tests for API
- Component tests for UI
- E2E test for critical paths

### Quantified Standards
- Performance: Lighthouse score ≥95
- Accessibility: WCAG 2.1 AA compliance
- Security: Input validation, no OWASP Top 10 vulnerabilities
- Bundle size: <50KB gzipped for client-side code

### Potential Issues
- Issue 1 and mitigation
- Issue 2 and mitigation

### Next Steps
1. If approved, use mannay:writing-plans for detailed implementation
2. OR use mannay:brainstorming if design needs exploration
3. Start with Phase 1, Step 1 if proceeding directly
4. Use pnpm for all package operations
5. Commit frequently after each passing test
```

## Integration

**Called by:**
- User directly — When given a task to implement
- `brainstorming` — After design, to break into steps

**Pairs with:**
- `brainstorming` — If design needs exploration first
- `writing-plans` — For detailed implementation plan
- `executing-plans` — To execute the analysis
- `test-driven-development` — For implementation
- `systematic-debugging` — If bugs encountered
- Domain agents — Invoked during analysis

## Key Principles

- **Framework awareness**: Detect and respect framework patterns
- **Test-first mindset**: Include TDD in all plans
- **Quantified standards**: Use measurable metrics
- **Agent integration**: Recommend relevant domain experts
- **YAGNI ruthlessly**: Don't over-plan or over-engineer
- **Always use pnpm**: Not npm or yarn
- **Risk identification**: Surface blockers early
- **Realistic estimates**: Account for testing, review, docs
