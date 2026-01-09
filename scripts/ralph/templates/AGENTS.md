# AGENTS.md - Codebase Guidance for Ralph

> This file provides codebase-specific guidance for Ralph and the specialized agents.
> **READ THIS FIRST** at the start of each Ralph iteration.
> Updated during Ralph execution as patterns and gotchas are discovered.

## Project Overview

[Brief description of what this project does]

## Tech Stack

- **Framework**: [Next.js 14 App Router / Vite + React / CRA / Other]
- **Language**: [TypeScript 5.x]
- **Database**: [PostgreSQL / MySQL / MongoDB / Supabase / None]
- **Auth**: [NextAuth / Supabase Auth / Custom / None]
- **Styling**: [Tailwind / CSS Modules / Styled Components / Other]
- **Testing**: [Vitest / Jest / Playwright / Cypress]
- **Key Libraries**: [List important dependencies]

## Architecture

### Directory Structure

```
src/
├── app/          [Next.js App Router pages]
├── components/   [Reusable React components]
├── lib/          [Utilities, helpers, shared logic]
├── types/        [TypeScript type definitions]
└── api/          [API routes or backend logic]
```

### Key Design Patterns

- [Pattern 1: e.g., "Server Components by default, Client Components marked explicitly"]
- [Pattern 2: e.g., "API routes use Zod for validation"]
- [Pattern 3: e.g., "Database access only through repository pattern"]

## Conventions

### File Organization

- [Where components go]
- [Where tests go (colocated, separate directory)]
- [How files are named (PascalCase, kebab-case)]

### Naming

- **Components**: PascalCase (e.g., `UserProfile.tsx`)
- **Files**: kebab-case (e.g., `user-profile.ts`)
- **Functions**: camelCase (e.g., `getUserProfile`)
- **Constants**: UPPER_SNAKE_CASE (e.g., `API_BASE_URL`)

### Code Style

- [Indentation: 2 spaces / 4 spaces]
- [Semicolons: yes / no]
- [Quotes: single / double]
- [Import order: rules]

## Dependencies

### Required for Development

```bash
# Example: What needs to be running
pnpm dev          # Development server on port 3000
docker compose up # PostgreSQL database
```

### Environment Variables

Required `.env` variables:

```
DATABASE_URL=          # PostgreSQL connection string
AUTH_SECRET=           # Session secret (32+ chars)
NEXT_PUBLIC_API_URL=   # Public API endpoint
```

## Testing

### Running Tests

```bash
pnpm test              # Run all tests
pnpm test:watch        # Watch mode
pnpm test:coverage     # Coverage report
pnpm test:e2e          # End-to-end tests
```

### Test Requirements

- **Coverage target**: >80%
- **Test location**: Colocated with components (*.test.tsx)
- **Integration tests**: In `tests/integration/`
- **E2E tests**: In `tests/e2e/`

### Testing Patterns

- [Pattern: How to mock dependencies]
- [Pattern: How to test async operations]
- [Pattern: How to test components with context]

## Common Gotchas

### General

- [Gotcha 1: e.g., "Always await Prisma client calls"]
- [Gotcha 2: e.g., "Server Components can't use useState or useEffect"]

### Framework-Specific

- [Next.js: Server/Client Component boundary issues]
- [Vite: Environment variable must start with VITE_]

### Database

- [Remember to run migrations after schema changes: `pnpm db:migrate`]
- [Seed database for tests: `pnpm db:seed`]

### Deployment

- [Build command: `pnpm build`]
- [Environment variables needed in production]

## AI Agent Notes

### Before Making Changes

1. Read this AGENTS.md file completely
2. Check `scripts/ralph/progress.txt` for recent patterns
3. Review recent commits: `git log --oneline -10`
4. Run typecheck: `pnpm typecheck`

### When Implementing Features

- Follow existing patterns in similar files
- Use TDD: Write failing test → implement → make it pass
- Check Codebase Patterns in progress.txt before starting
- Invoke relevant agents:
  - Auth/security: security-engineer
  - APIs: api-designer
  - Performance: performance-engineer
  - TypeScript: typescript-pro

### After Making Changes

1. Run typecheck: `pnpm typecheck`
2. Run tests: `pnpm test`
3. Run linter if exists: `pnpm lint`
4. Commit with descriptive message
5. Update this file if you discovered important patterns

## Reference Documentation

- [Project docs: Link to internal docs]
- [API docs: Link to API documentation]
- [Design system: Link to component library]
