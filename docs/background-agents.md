# Background Agents

Guide for using background agents in Claude Code (v2.0.60+).

## Overview

Background agents allow Claude to work on tasks while you continue working. They're useful for:
- Long-running operations
- Parallel task execution
- Non-blocking research

## How to Use

### Starting a Background Agent

Use the `run_in_background` parameter with the Task tool:

```typescript
Task({
  description: "Research API patterns",
  prompt: "Research REST API best practices...",
  subagent_type: "Explore",
  run_in_background: true
})
```

Or use the `&` prefix with prompts:
```
& Research the best authentication patterns for this project
```

### Checking Background Agent Status

Use the `/tasks` command to see running agents:
```
/tasks
```

### Getting Background Agent Output

Use `TaskOutput` to retrieve results:
```typescript
TaskOutput({
  task_id: "agent-id-here",
  block: false,  // false for non-blocking check
  timeout: 30000
})
```

## Use Cases in Mannay Skills

### 1. Parallel Research

When using `brainstorming` skill, launch background agents for parallel research:

```typescript
// Main thread explores approach A
// Background agent researches approach B
Task({
  description: "Research alternative approach",
  prompt: "Research approach B while I explore approach A",
  subagent_type: "deep-research-agent",
  run_in_background: true
})
```

### 2. Long-Running Builds

During `executing-plans` skill, run tests in background:

```typescript
Task({
  description: "Run test suite",
  prompt: "Run the full test suite and report results",
  subagent_type: "general-purpose",
  run_in_background: true
})
// Continue with next task while tests run
```

### 3. Code Review While Implementing

During `test-driven-development`, queue background review:

```typescript
// After implementing
Task({
  description: "Review implementation",
  prompt: "Review the code I just wrote for quality issues",
  subagent_type: "code-reviewer",
  run_in_background: true
})
// Continue with next feature
```

## Best Practices

1. **Use for independent tasks** - Background agents can't see changes you make after launching them
2. **Check status periodically** - Use `/tasks` to monitor progress
3. **Keep prompts self-contained** - Include all necessary context in the prompt
4. **Limit concurrent agents** - 2-3 background agents max to avoid confusion

## Integration with Skills

These skills benefit from background agents:

| Skill | Use Case |
|-------|----------|
| `brainstorming` | Parallel exploration of approaches |
| `executing-plans` | Run tests while continuing work |
| `feature-planning` | Research while designing |
| `systematic-debugging` | Search logs while investigating |

## Limitations

- Background agents don't see file changes made after they start
- Output may be delayed
- Can't interact with background agents (no follow-up questions)
- Limited to available agent types

## Claude Code Version

Background agents require Claude Code v2.0.60 or later.
