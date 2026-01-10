---
name: brainstorming
description: "MANDATORY before building any new feature. Explore design approaches through collaborative dialogue before implementation. This skill activates automatically for any new feature or significant change. Design first, code second."
always_active_for:
  - "new features"
  - "significant changes"
  - "adding functionality"
  - "building something new"
  - "creative work"
---

# Brainstorming Ideas Into Designs

## Overview

Help turn ideas into fully formed designs and specs through natural collaborative dialogue.

Start by understanding the current project context, then ask questions one at a time to refine the idea. Once you understand what you're building, present the design in small sections (200-300 words), checking after each section whether it looks right so far.

## The Process

**Understanding the idea:**
- Check out the current project state first (files, docs, recent commits)
- Detect project framework (Next.js, Vite, CRA) by examining package.json
- Ask questions one at a time to refine the idea
- Prefer multiple choice questions when possible, but open-ended is fine too
- Only one question per message - if a topic needs more exploration, break it into multiple questions
- Focus on understanding: purpose, constraints, success criteria, scale expectations

**Exploring approaches:**
- Propose 2-3 different approaches with trade-offs
- Present options conversationally with your recommendation and reasoning
- Lead with your recommended option and explain why
- Consider framework-specific patterns:
  - **Next.js**: Server Components, API routes, Edge Runtime compatibility
  - **Vite/CRA**: Client-side patterns, bundle size, lightweight libraries

**INVOKE Relevant Agents (MANDATORY):**

Based on what the feature involves, INVOKE these agents using the Task tool:

| Feature Involves | INVOKE These Agents |
|------------------|---------------------|
| Database, data models | `backend-architect` |
| API endpoints, contracts | `api-designer` + `backend-architect` |
| UI components, pages | `frontend-architect` + `frontend-design` |
| User input, forms | `accessibility-specialist` |
| Auth, passwords, security | `security-engineer` + `backend-architect` |
| Complex TypeScript types | `typescript-pro` |
| Performance concerns | `performance-engineer` |

**Example:** For "user authentication" feature:
```
1. INVOKE security-engineer → Review auth design for vulnerabilities
2. INVOKE backend-architect → Design database schema, session handling
3. INVOKE api-designer → Define login/register/logout endpoints
4. INVOKE typescript-pro → Type definitions for auth state
```

Do NOT just mention agents. Actually invoke them with the Task tool.

**Presenting the design:**
- Once you believe you understand what you're building, present the design
- Break it into sections of 200-300 words
- Ask after each section whether it looks right so far
- Cover: architecture, components, data flow, error handling, testing, performance
- Include quantified standards where applicable:
  - Performance: ≥95 Lighthouse score for user-facing features
  - Accessibility: WCAG 2.1 AA compliance
  - Testing: ≥80% code coverage
  - Bundle size: <50KB gzipped for client-side libraries
- Be ready to go back and clarify if something doesn't make sense

## After the Design

**Documentation:**
- Write the validated design to `planning/YYYY-MM-DD-<topic>-design.md`
- Commit the design document to git

**Implementation (if continuing):**
- Ask: "Ready to set up for implementation?"
- Use mannay:writing-plans to create detailed implementation plan
- Consider which Mannay agents or commands might help:
  - `/api-new` for API endpoints
  - `/component-new` for React components
  - `/page-new` for Next.js pages
  - tech-stack-researcher agent for technology choices
  - api-designer agent for API architecture

## Integration

**Called by:**
- `prd-builder` — Phase 2: Design exploration
- `feature-planning` — Before technical specification
- User directly — For new feature ideation

**Pairs with:**
- `task-analysis` — After design approved, break into tasks
- `writing-plans` — Create detailed implementation plan
- `feature-planning` — For technical specification
- Domain agents — Invoke during exploration

---

## Key Principles

- **One question at a time** - Don't overwhelm with multiple questions
- **Multiple choice preferred** - Easier to answer than open-ended when possible
- **YAGNI ruthlessly** - Remove unnecessary features from all designs
- **Explore alternatives** - Always propose 2-3 approaches before settling
- **Incremental validation** - Present design in sections, validate each
- **Framework awareness** - Respect framework patterns and constraints
- **Quantify standards** - Use measurable metrics for quality goals
- **Be flexible** - Go back and clarify when something doesn't make sense
