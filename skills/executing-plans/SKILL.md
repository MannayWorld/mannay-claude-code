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
2. **Check for existing progress**: Look for `<plan>-progress.json` alongside the plan
   - If exists: Load progress and resume from last incomplete task
   - If not: Initialize progress files using `initProgress()`
3. Review critically - identify any questions or concerns about the plan
4. Verify framework compatibility (Next.js, Vite, CRA patterns align)
5. Check quantified standards are clear
6. If concerns: Raise them with your human partner before starting
7. If no concerns: Create TodoWrite and proceed

**Progress Resume Logic:**
```javascript
import { getProgress, hasProgress, initProgress } from 'memory/progress/index.js';
import { extractTasks } from 'memory/progress/updater.js';

if (hasProgress(planFile)) {
  const progress = getProgress(planFile);
  console.log(`Resuming: ${progress.stats.completed}/${progress.stats.total} tasks done`);
  // Skip completed tasks, start from first pending/in_progress
} else {
  const tasks = extractTasks(planFile);
  initProgress(planFile, projectName, tasks);
}
```

### Step 2: Execute Batch

**Default: First 3 tasks**

For each task:
1. Mark as in_progress (both TodoWrite and progress files)
2. Follow each step exactly (plan has bite-sized steps)
3. Use `pnpm` for all package operations
4. Follow framework-specific patterns from plan
5. Run verifications as specified
6. Meet quantified standards (coverage, performance, accessibility)
7. Commit the changes
8. Mark as completed with commit reference

**Update progress on each task:**
```javascript
import { updateTaskStatus, appendLog } from 'memory/progress/index.js';
import { markTaskComplete, markTaskInProgress } from 'memory/progress/updater.js';

// Starting task
markTaskInProgress(planFile, taskId);
updateTaskStatus(planFile, taskId, 'in_progress');
appendLog(planFile, `Starting Task ${taskId}`);

// After commit
const commitHash = getLatestCommitHash(); // e.g., 'abc123f'
markTaskComplete(planFile, taskId, commitHash);
updateTaskStatus(planFile, taskId, 'completed', { commit: commitHash });
appendLog(planFile, `Completed Task ${taskId} (commit: ${commitHash})`);
```

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

## Crash Recovery

**If session crashes or context fills:**
1. Progress is preserved in `<plan>-progress.json` and `<plan>-progress.md`
2. Plan file has ✅ markers on completed tasks
3. New session loads progress and resumes automatically
4. Session log shows what was done and when

**To verify state after crash:**
- Read `<plan>-progress.md` for human-readable status
- Check plan file for ✅ markers with commit references
- Git log shows all committed work

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
- **Update progress files on every task completion**
