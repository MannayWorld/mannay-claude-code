---
name: compound-engineering
description: "Compound Engineering workflow where each unit of work makes future work easier. Use when planning features, executing work, reviewing code, or codifying learnings. Follows Plan (40%) → Work (20%) → Review (20%) → Compound (20%) loop."
triggers:
  - "plan this feature"
  - "implement this"
  - "review this code"
  - "compound learnings"
  - "create implementation plan"
  - "systematic development"
  - "document patterns"
---

# Compound Engineering - Development That Compounds

> **Each unit of engineering work should make subsequent units easier—not harder.**

## The Job

Implement a development loop where bugs become lessons, patterns get documented, and every feature builds on accumulated knowledge.

---

## Core Philosophy

Traditional development accumulates technical debt. Every feature adds complexity. Compound Engineering inverts this by:

1. **Documenting patterns** as they're discovered
2. **Capturing failures** as prevention guides
3. **Building institutional knowledge** that accelerates future work

**Time Allocation:**
```
Plan (40%) → Work (20%) → Review (20%) → Compound (20%)
```

80% of compound engineering is planning and review. 20% is execution.

---

## Step 1: Plan (40% of effort)

Before writing any code, research and plan.

### Research Phase
1. **Codebase Analysis**: Search for similar patterns, conventions
2. **Commit History**: `git log` to understand how related features were built
3. **Documentation**: Check README, AGENTS.md, inline docs
4. **External Research**: Best practices for the problem domain

### Plan Document Template

```markdown
# Feature: [Name]

## Context
- Problem: [What problem does this solve?]
- Users: [Who is affected?]
- Current vs Desired: [Behavior change]

## Research Findings
- Similar patterns: [file references]
- Prior implementations: [commit references]
- Best practices: [external references]

## Acceptance Criteria
- [ ] Criterion 1 (testable)
- [ ] Criterion 2 (testable)
- [ ] npm run typecheck passes

## Technical Approach
1. Step 1: [specific action]
2. Step 2: [specific action]

## Code Examples
[Snippets that follow existing patterns]

## Testing Strategy
- Unit: [what to test]
- Integration: [what to test]
- Manual: [verification steps]

## Risks & Mitigations
- Risk 1: [mitigation]
```

### Plan Depth Levels
| Scope | Depth | Work Time |
|-------|-------|-----------|
| Quick fix | Minimal | 1-2 hours |
| Standard feature | Standard | 1-2 days |
| Major feature | Comprehensive | Multi-day |

---

## Step 2: Work (20% of effort)

Execute the plan systematically.

### Execution Workflow
1. **Isolate**: Feature branch or git worktree
2. **Break down**: Create TODO list from plan
3. **Execute**: One task at a time
4. **Validate**: Run tests after each change
5. **Commit**: Small, focused commits

### Working Principles
- Follow patterns discovered in research
- Run tests after every meaningful change
- If something fails, understand WHY before proceeding
- Keep changes focused—no scope creep

### Quality Checks
```bash
npm run typecheck  # After each change
npm test           # After each feature
npm run lint       # Before commit
```

---

## Step 3: Review (20% of effort)

Comprehensive review before merging.

### Review Checklist

**Code Quality**
- [ ] Follows existing codebase patterns
- [ ] No unnecessary complexity (duplication > wrong abstraction)
- [ ] Clear naming matching project conventions
- [ ] No debug code left behind

**Security**
- [ ] No secrets or sensitive data exposed
- [ ] Input validation present
- [ ] Safe handling of user data

**Performance**
- [ ] No obvious regressions
- [ ] No N+1 queries
- [ ] Appropriate caching

**Testing**
- [ ] Tests cover acceptance criteria
- [ ] Edge cases considered
- [ ] Tests are maintainable

**Architecture**
- [ ] Consistent with system design
- [ ] No unnecessary coupling
- [ ] Separation of concerns

### Multi-Perspective Review

Consider the code from different angles:
- **Maintainer**: Easy to modify in 6 months?
- **Performance**: Any bottlenecks?
- **Security**: Any vulnerabilities?
- **Simplicity**: Can this be simpler?

---

## Step 4: Compound (20% of effort)

**This is where the magic happens.** Capture learnings for future work.

### What to Compound

**Patterns** - Document new patterns discovered:
```markdown
## Pattern: [Name]
**When to use:** [context]
**Implementation:** [example code]
**See:** [file reference]
```

**Decisions** - Record architectural choices:
```markdown
## Decision: [Choice Made]
**Context:** [situation]
**Options:** [alternatives considered]
**Rationale:** [why this choice]
**Trade-offs:** [consequences]
```

**Failures** - Turn bugs into lessons:
```markdown
## Lesson: [What Went Wrong]
**Symptom:** [what was observed]
**Root cause:** [actual problem]
**Fix:** [solution]
**Prevention:** [how to avoid in future]
```

### Where to Codify

| Location | Use For |
|----------|---------|
| AGENTS.md | Project-wide guidance |
| Subdirectory AGENTS.md | Subsystem-specific guidance |
| Inline comments | Only when code isn't self-explanatory |
| Test cases | Turn bugs into regression tests |
| progress.txt | Ralph session learnings |

### Compounding Questions

After completing work, ask:
- What did I learn that others should know?
- What mistake did I make that can be prevented?
- What pattern did I discover or create?
- What decision was made and why?

---

## Key Principles

1. **Prefer duplication over wrong abstraction** - Clear code beats complex abstractions
2. **Document as you go** - Every task generates reusable documentation
3. **Quality compounds** - High-quality code is easier to modify
4. **Systematic beats heroic** - Consistent processes beat individual heroics
5. **Knowledge should be codified** - Learnings must be captured and reused

---

## Success Metrics

You're doing compound engineering well when:
- Each feature takes less effort than the last similar feature
- Bugs become one-time events (documented and prevented)
- New team members can be productive quickly
- Code reviews surface fewer issues
- Technical debt decreases over time

---

## Remember

**You're not just building features—you're building a development system that gets better with each use.**
