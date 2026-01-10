# Commands Reference

> Complete reference for all Mannay slash commands.

## Overview

Commands are **quick tools** for scaffolding and common tasks. Use `/command-name` syntax.

## API Commands

### /api-new

Create a new API endpoint with validation and error handling.

```bash
/api-new POST /api/users create user endpoint
```

**Creates:**
- API route file
- TypeScript types
- Validation schema
- Error handling
- Test file

---

### /api-backend-setup

Set up backend API with Express or Fastify for Vite/CRA projects.

```bash
/api-backend-setup express
/api-backend-setup fastify
```

**Creates:**
- Server configuration
- Middleware setup
- Route structure
- Error handling

---

### /api-test

Generate comprehensive test suite for an API endpoint.

```bash
/api-test /api/users
```

**Creates:**
- Happy path tests
- Error case tests
- Edge case tests
- Integration tests

---

### /api-protect

Add authentication and authorization to API endpoints.

```bash
/api-protect /api/admin
```

**Adds:**
- Auth middleware
- Role-based access
- Token validation
- Security headers

---

## UI Commands

### /component-new

Create a new React component with TypeScript.

```bash
/component-new UserCard
```

**Creates:**
- Component file
- TypeScript props interface
- Test file
- Storybook story (optional)

---

### /page-new

Create a new Next.js page with App Router.

```bash
/page-new dashboard
```

**Creates:**
- Page component
- Layout (if needed)
- Loading state
- Error boundary

---

### /page-new-react

Create a React Router page for Vite/CRA projects.

```bash
/page-new-react settings
```

**Creates:**
- Page component
- Route registration
- TypeScript types

---

## Supabase Commands

### /types-gen

Generate TypeScript types from Supabase database schema.

```bash
/types-gen
```

**Creates:**
- Database types
- Table interfaces
- Function types

---

### /edge-function-new

Create a new Supabase Edge Function.

```bash
/edge-function-new send-email
```

**Creates:**
- Edge function file
- Deno configuration
- Type definitions

---

## Quality Commands

### /lint

Run ESLint, TypeScript, and Prettier.

```bash
/lint
```

**Runs:**
- ESLint check
- TypeScript check
- Prettier check
- Auto-fix when possible

---

### /code-cleanup

Refactor and clean up code following best practices.

```bash
/code-cleanup src/utils/helpers.ts
```

**Does:**
- Remove dead code
- Improve naming
- Apply DRY
- Add missing types

---

### /code-optimize

Analyze and optimize code for performance.

```bash
/code-optimize src/components/List.tsx
```

**Does:**
- Profile performance
- Identify bottlenecks
- Apply optimizations
- Measure improvement

---

### /code-explain

Explain complex code sections.

```bash
/code-explain src/lib/auth.ts
```

**Provides:**
- Line-by-line explanation
- Architecture overview
- Key patterns used

---

## Planning Commands

### /new-task

Analyze task complexity and create implementation plan.

```bash
/new-task add user authentication
```

**Creates:**
- Task breakdown
- Complexity estimate
- Implementation plan
- Agent recommendations

---

### /feature-plan

Create technical specification for a feature.

```bash
/feature-plan user profile management
```

**Creates:**
- User stories
- Technical spec
- API design
- Implementation phases

---

### /docs-generate

Generate documentation for code, APIs, or components.

```bash
/docs-generate src/lib/
```

**Creates:**
- API documentation
- Code comments
- README files

---

## Ralph Commands

### /ralph-init

Initialize Ralph Mode files in current project.

```bash
/ralph-init
```

**Creates:**
- `scripts/ralph/` directory
- `prd.json` template
- `progress.txt`
- `prompt.md`
- `AGENTS.md`

---

### /ralph-build

Create a PRD interactively for Ralph execution.

```bash
/ralph-build
```

**Process:**
1. Ask clarifying questions
2. Generate user stories
3. Create `prd.json`
4. Validate atomicity

---

### /ralph-start

Start Ralph autonomous execution loop.

```bash
/ralph-start
```

**Does:**
1. Reads `prd.json`
2. Executes stories sequentially
3. Commits after each story
4. Updates progress

---

### /ralph-status

Check Ralph execution status.

```bash
/ralph-status
```

**Shows:**
- Stories completed
- Stories remaining
- Current progress
- Recent commits

---

### /ralph-stop

Stop Ralph execution loop.

```bash
/ralph-stop
```

**Does:**
- Terminates loop
- Preserves progress
- Reports status

---

## Codex Commands

### /gpt-review

Queue a file for GPT code review using your ChatGPT subscription via Codex CLI.

```bash
/gpt-review src/auth.ts --security
/gpt-review src/api/payment.ts --performance
/gpt-review src/utils.ts --refactor
/gpt-review src/file.ts "Check for edge cases"
```

**Flags:**
| Flag | Focus |
|------|-------|
| `--security` | Vulnerabilities, input validation, secrets |
| `--performance` | Bottlenecks, memory leaks, optimization |
| `--refactor` | DRY, naming, structure, clarity |

**Requirements:**
- Codex CLI installed: `npm install -g @openai/codex`
- Authenticated: `codex auth` (Sign in with ChatGPT)

---

### /gpt-status

Check Codex review status and daily usage.

```bash
/gpt-status
```

**Shows:**
- Reviews completed today
- Daily limit remaining
- Recent review list

---

### /gpt-results

View GPT code review results.

```bash
/gpt-results              # Show all recent results
/gpt-results src/auth.ts  # Show specific file's review
```

**Shows:**
- Summary of each review
- Full results saved in `.claude/gpt-reviews/`

---

## Memory Commands

### /memory-status

Check memory system status and statistics.

```bash
/memory-status
```

**Shows:**
- Database size
- Saved handoffs
- Cached signatures
- Token savings
- Learnings count
- Current session state

---

### /memory-learnings

View recent learnings accumulated across sessions.

```bash
/memory-learnings
```

**Shows:**
- Recent learnings
- Tags and categories
- Recall counts
- Total learnings

See [Memory System](memory-system.md) for full documentation.

---

## Command Quick Reference

| Command | Purpose |
|---------|---------|
| `/api-new` | Create API endpoint |
| `/api-backend-setup` | Setup Express/Fastify |
| `/api-test` | Generate API tests |
| `/api-protect` | Add auth to endpoint |
| `/component-new` | Create React component |
| `/page-new` | Create Next.js page |
| `/page-new-react` | Create React Router page |
| `/types-gen` | Generate Supabase types |
| `/edge-function-new` | Create Edge Function |
| `/lint` | Run linting |
| `/code-cleanup` | Refactor code |
| `/code-optimize` | Optimize performance |
| `/code-explain` | Explain code |
| `/new-task` | Analyze task |
| `/feature-plan` | Plan feature |
| `/docs-generate` | Generate docs |
| `/ralph-init` | Initialize Ralph |
| `/ralph-build` | Create PRD |
| `/ralph-start` | Start Ralph |
| `/ralph-status` | Check status |
| `/ralph-stop` | Stop Ralph |
| `/gpt-review` | GPT code review via Codex |
| `/gpt-status` | Codex review status |
| `/gpt-results` | View GPT review results |
| `/memory-status` | Memory system stats |
| `/memory-learnings` | View learnings |
