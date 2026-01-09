---
name: executing-plans
description: Use when you have a written implementation plan to execute in a separate session with review checkpoints
---

# Executing Plans

## Overview

Load plan, review critically, execute tasks in batches, report for review between batches.

**Core principle:** Batch execution with checkpoints for architect review.

**Announce at start:** "I'm using the executing-plans skill to implement this plan."

## The Process

### Step 1: Load and Review Plan

1. Read plan file
2. Review critically - identify any questions or concerns about the plan
3. Verify framework compatibility (Next.js, Vite, CRA patterns align)
4. Check quantified standards are clear
5. If concerns: Raise them with your human partner before starting
6. If no concerns: Create TodoWrite and proceed

### Step 2: Execute Batch

**Default: First 3 tasks**

For each task:
1. Mark as in_progress
2. Follow each step exactly (plan has bite-sized steps)
3. Use `pnpm` for all package operations
4. Follow framework-specific patterns from plan
5. Run verifications as specified
6. Meet quantified standards (coverage, performance, accessibility)
7. Mark as completed

**Framework-Specific Execution:**
- **Next.js**: Verify Server/Client Component boundaries, Edge Runtime compatibility
- **Vite/CRA**: Check bundle size impact, client-side performance
- Use framework-appropriate commands:
  - Next.js: `/api-new` for API routes, `/page-new` for pages
  - Vite/CRA: `/page-new-react` for router pages, `/api-backend-setup` if needed

### Step 3: Report

When batch complete:
- Show what was implemented
- Show verification output
- Show test coverage and passing tests
- Note any deviations from plan (with justification)
- Say: "Ready for feedback."

### Step 4: Continue

Based on feedback:
- Apply changes if needed
- Execute next batch
- Repeat until complete

### Step 5: Complete Development

After all tasks complete and verified:
- Run full test suite: `pnpm test`
- Verify coverage meets standards (≥80%)
- Run build to ensure no errors: `pnpm build`
- Check bundle size if client-side
- Consider code-reviewer agent for final review

## When to Stop and Ask for Help

**STOP executing immediately when:**
- Hit a blocker mid-batch (missing dependency, test fails, instruction unclear)
- Plan has critical gaps preventing starting
- You don't understand an instruction
- Verification fails repeatedly
- Framework patterns conflict with plan
- Test coverage falls below standards

**Ask for clarification rather than guessing.**

## When to Revisit Earlier Steps

**Return to Review (Step 1) when:**
- Partner updates the plan based on your feedback
- Fundamental approach needs rethinking
- Framework incompatibilities discovered

**Don't force through blockers** - stop and ask.

## Agent Integration During Execution

**When to invoke Mannay agents:**
- **Stuck on architecture**: Use backend-architect or frontend-architect
- **Performance issues**: Use performance-engineer
- **Security concerns**: Use security-engineer
- **Type challenges**: Use typescript-pro
- **API design questions**: Use api-designer

**Example:**
```markdown
Task blocked: Unclear how to handle real-time updates

Action: Invoke tech-stack-researcher agent to evaluate WebSockets vs SSE vs Supabase Realtime
```

## Remember

- Review plan critically first
- Follow plan steps exactly
- Always use `pnpm` (not npm)
- Don't skip verifications
- Reference skills/agents when plan says to
- Between batches: just report and wait
- Stop when blocked, don't guess
- Meet quantified standards (coverage, performance, accessibility)
- Follow framework-specific patterns
