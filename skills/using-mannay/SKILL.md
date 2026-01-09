---
name: using-mannay
description: "Master orchestrator for all Mannay skills, agents, and commands. Automatically loaded to help Claude select the right tools. Contains keyword-to-tool mapping for smart auto-detection even with short prompts."
triggers:
  - "what tools are available"
  - "how do I use"
  - "which skill should I"
  - "help me find"
---

<EXTREMELY-IMPORTANT>
If you think there is even a 1% chance a skill, agent, or command might apply to what you are doing, you ABSOLUTELY MUST invoke it.

IF A TOOL APPLIES TO YOUR TASK, YOU DO NOT HAVE A CHOICE. YOU MUST USE IT.

This is not negotiable. This is not optional. You cannot rationalize your way out of this.
</EXTREMELY-IMPORTANT>

---

# MANDATORY BEHAVIORS (ALWAYS ON)

These skills are NOT optional. They activate automatically based on task type.

## 1. TDD is ALWAYS ON for Implementation

**ANY task that involves writing or modifying code MUST use test-driven-development.**

This includes:
- "Build a login page" → TDD
- "Add a button" → TDD
- "Create an API endpoint" → TDD
- "Implement feature X" → TDD
- "Refactor this" → TDD

**The user does NOT need to say "test" or "TDD".** If you're writing code, you're using TDD. Period.

## 2. Systematic Debugging for ANY Problem

**ANY task that involves fixing, troubleshooting, or investigating MUST use systematic-debugging.**

This includes:
- "Fix this bug" → systematic-debugging
- "Why isn't this working?" → systematic-debugging
- "This is broken" → systematic-debugging
- "I'm getting an error" → systematic-debugging
- "Something's wrong with..." → systematic-debugging

**The user does NOT need to say "debug".** If something isn't working, you debug systematically first.

## 3. Brainstorming for ANY New Feature

**ANY task that involves creating something new MUST start with brainstorming.**

This includes:
- "Add user authentication" → brainstorming first
- "Build a dashboard" → brainstorming first
- "Create a new feature" → brainstorming first
- "I want to add..." → brainstorming first

**The user does NOT need to say "brainstorm".** If it's a new feature, you explore design first.

---

# MULTI-AGENT CHAINING (Use ALL Relevant Agents)

**CRITICAL: Tasks often require MULTIPLE agents. Use ALL that apply, not just one.**

## Agent Chains by Task Type

### Building a Feature (Full Chain)
```
brainstorming → task-analysis → [domain agents] → TDD → review
```

Example: "Add user authentication"
1. **brainstorming** - Explore approaches (session vs JWT, OAuth providers)
2. **task-analysis** - Break into implementable steps
3. **security-engineer** - Review auth design for vulnerabilities
4. **backend-architect** - Design database schema, API structure
5. **api-designer** - Define endpoints, contracts
6. **typescript-pro** - Type definitions for auth state
7. **TDD** - Write tests first, then implement
8. **code-reviewer** - Review final implementation

### Building UI (Full Chain)
```
brainstorming → frontend-design → frontend-architect → accessibility-specialist → TDD → review
```

Example: "Build a settings page"
1. **brainstorming** - Explore UX approaches
2. **frontend-design** - Create distinctive visual design
3. **frontend-architect** - Component structure, state management
4. **accessibility-specialist** - WCAG compliance, keyboard nav
5. **TDD** - Write tests first, then implement
6. **code-reviewer** - Review quality

### Building API (Full Chain)
```
brainstorming → api-designer → backend-architect → security-engineer → TDD → review
```

Example: "Create payment API"
1. **brainstorming** - Explore payment providers, approaches
2. **api-designer** - Define contracts, OpenAPI spec
3. **backend-architect** - Database design, error handling
4. **security-engineer** - PCI compliance, input validation
5. **TDD** - Write tests first, then implement
6. **code-reviewer** - Review final code

### Fixing a Bug (Full Chain)
```
systematic-debugging → [relevant domain agents] → TDD → review
```

Example: "Authentication is broken"
1. **systematic-debugging** - Find root cause (Phase 1-4)
2. **security-engineer** - If auth-related, review for vulnerabilities
3. **backend-architect** - If backend issue, review architecture
4. **TDD** - Write regression test, then fix
5. **code-reviewer** - Review fix

### Performance Issue (Full Chain)
```
systematic-debugging → performance-engineer → [domain agents] → TDD → review
```

Example: "The page is slow"
1. **systematic-debugging** - Identify what's slow and why
2. **performance-engineer** - Profile, identify bottlenecks
3. **frontend-architect** - If UI issue, optimize components
4. **backend-architect** - If API issue, optimize queries
5. **TDD** - Write performance tests, then optimize
6. **code-reviewer** - Review optimizations

---

# SMART TASK INFERENCE

Don't just match keywords. Analyze WHAT the user wants to accomplish.

## Task Type Detection

| User Says | Task Type | Required Chain |
|-----------|-----------|----------------|
| "Build X", "Create X", "Add X", "Implement X" | NEW FEATURE | brainstorming → task-analysis → agents → TDD |
| "Fix X", "X is broken", "X doesn't work" | BUG FIX | debugging → agents → TDD |
| "Make X faster", "X is slow", "Optimize X" | PERFORMANCE | debugging → performance-engineer → TDD |
| "Review X", "Check X", "Is X good?" | REVIEW | code-reviewer → domain agents |
| "Explain X", "How does X work?" | LEARNING | learning-guide |
| "Plan X", "Spec out X", "PRD for X" | PLANNING | prd-builder OR task-analysis |

## Domain Detection (Which Agents to Include)

| Task Involves | Always Include |
|---------------|----------------|
| User accounts, login, passwords, sessions | security-engineer + backend-architect |
| Forms, validation, input | accessibility-specialist + frontend-architect |
| Database, queries, schemas | backend-architect |
| API endpoints, REST, GraphQL | api-designer + backend-architect |
| UI components, pages, layouts | frontend-architect + frontend-design |
| Types, interfaces, generics | typescript-pro |
| Payments, sensitive data | security-engineer |
| Public-facing pages | accessibility-specialist + performance-engineer |

---

## How to Access Tools

**Skills (workflows):** Use the `Skill` tool. Example: `Skill("mannay:brainstorming")`
**Agents (domain expertise):** Invoke with `Task` tool using agent name as subagent_type
**Commands (quick tools):** Use `/command-name` syntax. Example: `/api-new`, `/component-new`

## Tool Priority (Order of Operations)

When multiple tools apply, invoke in this order:

1. **Mandatory Process Skills** - TDD (for implementation), debugging (for bugs), brainstorming (for new features)
2. **Planning Skills** - task-analysis, feature-planning, prd-builder
3. **ALL Relevant Domain Agents** - Not just one! Use every agent that applies
4. **Implementation Commands** - /api-new, /component-new
5. **Quality Skills** - code-review, api-testing

## Available Tools Catalog

### 🔄 Skills (Systematic Workflows)

**Core Discipline:**
- `mannay:test-driven-development` - RED-GREEN-REFACTOR for all code changes
- `mannay:systematic-debugging` - 4-phase root cause analysis for bugs
- `mannay:compound-engineering` - Plan → Work → Review → Compound loop (use for systematic feature development)

**Planning Workflows:**
- `mannay:brainstorming` - Design exploration before implementation (use BEFORE any creative work)
- `mannay:task-analysis` - Analyze task complexity and create actionable plan (use when user provides a task)
- `mannay:feature-planning` - Feature implementation planning with tech specs (use for new features)
- `mannay:writing-plans` - Detailed implementation plans (use when you have specs/requirements)
- `mannay:executing-plans` - Batch execution with checkpoints (use to execute plans in parallel session)
- `mannay:prd-builder` - Interactive PRD generation for Ralph (use when creating PRDs/user stories)

**Quality Workflows:**
- `mannay:requesting-code-review` - Two-stage review: spec compliance + code quality (use when executing plans with independent tasks in current session)
- `mannay:api-testing` - Comprehensive API endpoint testing (use for API test generation)

**Design & UI:**
- `mannay:frontend-design` - Create distinctive, production-grade interfaces (use for UI/component creation)

**Autonomous Execution:**
- `mannay:ralph-mode` - Autonomous PRD story execution with commits (use for long-running autonomous work)

### 🤖 Agents (Domain Expertise)

**Frontend & UI:**
- `accessibility-specialist` - WCAG 2.1 AA compliance, screen reader testing
- `frontend-architect` - Component architecture, responsive design, Core Web Vitals
- `typescript-pro` - Advanced type patterns, type safety, strict mode

**Backend & API:**
- `backend-architect` - API design, database schema, authentication, reliability
- `api-designer` - OpenAPI specs, GraphQL schemas, contract-first design

**Quality & Performance:**
- `code-reviewer` - SOLID principles, code quality, production readiness
- `performance-engineer` - Bottleneck identification, bundle optimization, Core Web Vitals
- `security-engineer` - Vulnerability assessment, OWASP Top 10, zero-trust
- `refactoring-expert` - Technical debt reduction, DRY, clean code

**Documentation & Architecture:**
- `documentation-engineer` - API docs, automated generation, docs-as-infrastructure
- `system-architect` - Scalability, component boundaries, 10x growth planning
- `tech-stack-researcher` - Technology comparisons, library recommendations

**Learning & Planning:**
- `requirements-analyst` - PRD creation, user stories, scope definition
- `learning-guide` - Progressive teaching, concept explanation
- `deep-research-agent` - Comprehensive research, analysis
- `technical-writer` - Clear documentation, audience-tailored content

### ⚡ Commands (Quick Tools)

**API Development:**
- `/api-new [description]` - Create Next.js API route with validation
- `/api-test [endpoint]` - Generate comprehensive test suite
- `/api-protect [endpoint]` - Add authentication and authorization
- `/api-backend-setup [framework]` - Set up Express or Fastify backend

**UI Components:**
- `/component-new [description]` - Create React component with TypeScript
- `/page-new [description]` - Create Next.js page with App Router
- `/page-new-react [description]` - Create React Router page for Vite/CRA

**Supabase:**
- `/supabase:types-gen` - Generate TypeScript types from schema
- `/supabase:edge-function-new [name]` - Create Supabase Edge Function

**Code Quality:**
- `/lint` - Run ESLint, TypeScript, and Prettier
- `/code-explain [file]` - Explain complex code sections
- `/code-optimize [file]` - Analyze and optimize performance
- `/code-cleanup [file]` - Refactor following best practices

**Documentation:**
- `/docs-generate [target]` - Generate comprehensive documentation

**Planning:**
- `/new-task [description]` - Analyze complexity and create plan
- `/feature-plan [description]` - Create technical specification

## Short Prompt Handling

**Don't match keywords. Analyze intent.**

For ANY short prompt, ask: **"What is the user trying to accomplish?"**

### Examples of Smart Inference

| User Says | DON'T Think | DO Think |
|-----------|-------------|----------|
| "login page" | "No keywords match" | "Building UI + auth → brainstorming + frontend-design + security-engineer + backend-architect + TDD" |
| "it's slow" | "slow = performance-engineer only" | "Performance issue → debugging first + performance-engineer + relevant domain agents + TDD" |
| "add button" | "Simple, just do it" | "UI change → frontend-architect + accessibility-specialist + TDD" |
| "fix auth" | "Fix = debugging only" | "Bug in auth → debugging + security-engineer + backend-architect + TDD" |

### The Rule for Short Prompts

1. **Identify WHAT** they want (build, fix, improve, explain)
2. **Identify DOMAIN** (UI, API, auth, data, etc.)
3. **Apply FULL CHAIN** for that task type + domain

**Never use just one tool because the prompt is short.**

## Complete Examples (Full Chains)

### "Add user authentication"
```
1. brainstorming - What approach? Session/JWT/OAuth?
2. task-analysis - Break into steps
3. security-engineer - Review for vulnerabilities (OWASP)
4. backend-architect - Database schema, API design
5. api-designer - Define endpoints
6. typescript-pro - Type definitions
7. TDD - Write tests FIRST, then implement each part
8. code-reviewer - Final quality check
```

### "Build a settings page"
```
1. brainstorming - What settings? UX approach?
2. frontend-design - Distinctive visual design
3. frontend-architect - Component structure
4. accessibility-specialist - WCAG, keyboard nav
5. TDD - Write tests FIRST, then implement
6. code-reviewer - Final quality check
```

### "Fix the login bug"
```
1. systematic-debugging - Find root cause (4 phases)
2. security-engineer - Check if security issue
3. backend-architect - If backend related
4. TDD - Write regression test FIRST, then fix
5. code-reviewer - Review the fix
```

### "Make the dashboard faster"
```
1. systematic-debugging - Profile, find what's slow
2. performance-engineer - Analyze bottlenecks
3. frontend-architect - If UI related
4. backend-architect - If API related
5. TDD - Write performance test, then optimize
6. code-reviewer - Review optimizations
```

### "Create payment API"
```
1. brainstorming - Payment providers, approach
2. api-designer - OpenAPI spec
3. backend-architect - Database, error handling
4. security-engineer - PCI compliance, validation
5. TDD - Write tests FIRST, then implement
6. code-reviewer - Security-focused review
```

## Common Rationalizations to Avoid

| Excuse | Reality |
|--------|---------|
| "Too simple for a tool" | Simple tasks benefit from tools. Use them. |
| "I'll use tool after exploring" | Tools tell you HOW to explore. Use first. |
| "This is urgent, no time" | Tools are FASTER than thrashing. |
| "I already know how" | Tools ensure consistency and quality. |
| "User didn't ask for workflow" | User asks for RESULT. Workflow is YOUR job. |
| "I can skip brainstorming" | Design first prevents rework. Always use. |
| "Tests can come after" | TDD is non-negotiable. Tests FIRST. |
| "Quick fix without debugging" | Root cause first. Always. |

## Red Flags - STOP and Use Tools

- Code before test → Use test-driven-development
- Fix without understanding → Use systematic-debugging
- Implement without design → Use brainstorming
- Generate without planning → Use task-analysis or feature-planning
- Skip review → Use requesting-code-review
- Bypass security check → Invoke security-engineer
- Ignore accessibility → Invoke accessibility-specialist
- "Just this once" thinking → ALWAYS use tools

## Framework Awareness

Mannay tools detect your framework:
- **Next.js**: App Router patterns, Server Components, Server Actions
- **Vite**: Client-side patterns, fast builds, lightweight libraries
- **Create React App**: Compatibility, gradual migration paths

Tools adapt automatically based on your package.json.

## Getting Help

**To see all available tools:** This skill catalogs everything
**To learn a specific tool:** Ask "How do I use [tool name]?"
**When stuck:** Say "I'm not sure which tool to use" and describe your task

## Final Rules

### Rule 1: Mandatory Skills Are Automatic
```
Writing code? → TDD is ON (no exceptions)
Fixing something? → Debugging is ON (no exceptions)
Building new? → Brainstorming is ON (no exceptions)
```

### Rule 2: Use ALL Relevant Agents
```
Don't use just ONE agent.
Identify ALL domains involved.
Chain them together.
Example: Auth feature → security + backend + api + typescript + TDD
```

### Rule 3: Intent Over Keywords
```
Don't match keywords literally.
Analyze what the user WANTS.
Apply the full chain for that task type.
```

### The Flow
```
1. What is the user trying to do? (build, fix, improve, explain)
2. What domains are involved? (UI, API, auth, data, etc.)
3. Apply mandatory skills (TDD, debugging, brainstorming)
4. Chain ALL relevant agents
5. Use implementation commands as needed
6. End with quality review
```

**No shortcuts. No single-agent responses. Full chains every time.**

---

## Integration

**Called by:**
- System automatically — Meta-orchestrator for all tasks

**Orchestrates:**
- `brainstorming` — For new features
- `test-driven-development` — For all code changes
- `systematic-debugging` — For any bugs/issues
- `task-analysis` — For task breakdown
- `feature-planning` — For feature specs
- `prd-builder` — For Ralph PRDs
- `ralph-mode` — For autonomous execution
- `git` — For all commits
- All domain agents — Based on task type
