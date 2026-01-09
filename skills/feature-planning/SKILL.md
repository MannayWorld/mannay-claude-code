---
name: feature-planning
description: Use when planning new feature implementation with technical specifications and architecture decisions
---

# Feature Planning

Create detailed implementation plans for new features with technical specifications, architecture decisions, and step-by-step execution strategy.

**Announce at start:** "I'm using the feature-planning skill to plan this feature."

## When to Use

Use this skill when:
- User wants to add a new feature to the application
- Feature requires multiple components/files
- Architecture decisions need to be made
- Technology choices need evaluation

**Do NOT use if:**
- User wants to explore design options first (use mannay:brainstorming instead)
- Feature is very simple (use mannay:task-analysis instead)
- Plan already exists (use mannay:executing-plans instead)

## Process

### Step 1: Detect Project Context

**Before planning:**
- Read package.json to detect framework and version
- Check existing patterns for similar features
- Identify framework-specific constraints
- Note state management, routing, API patterns

### Step 2: Feature Breakdown

**Analyze and break down into:**

**User Stories:**
- Who is this for?
- What problem does it solve?
- What are the key user flows?

**Technical Requirements:**
- Frontend components needed
- Backend API endpoints
- Database schema changes
- Third-party integrations
- Authentication/authorization needs

**Dependencies:**
- New packages needed
- Framework upgrades needed
- External services required
- Environment variables

**Edge Cases:**
- Error scenarios
- Empty states
- Loading states
- Offline behavior
- Permission boundaries

**Success Criteria:**
- Feature works as specified (100% requirements met)
- Tests pass (≥80% coverage)
- No console errors
- WCAG 2.1 AA accessible
- Responsive design
- Performance targets met (Lighthouse ≥95)
- Error handling complete
- Documentation updated

### Step 3: Technical Specification

**Architecture Decision:**

Consider framework patterns:
- **Next.js**: Server Components vs Client Components, API routes vs Server Actions
- **Vite/CRA**: Client-side routing, state management, backend integration

**Component Structure:**
```
Feature/
  ├── FeatureContainer.tsx (main component)
  ├── FeatureForm.tsx (form handling)
  ├── FeatureList.tsx (data display)
  └── feature-utils.ts (shared logic)
```

**API Endpoints:**
```
GET    /api/feature        - List items
POST   /api/feature        - Create item
GET    /api/feature/:id    - Get single item
PUT    /api/feature/:id    - Update item
DELETE /api/feature/:id    - Delete item
```

**Database Schema:**
- Tables needed
- Columns and types
- Indexes
- Foreign keys
- RLS policies (if Supabase)

**State Management:**
- Local state (useState)
- Server state (SWR, React Query, etc.)
- Global state (Context, Zustand, etc.)

**Technology Choices:**

Consult tech-stack-researcher agent for:
- Library selection (compare 2-3 options)
- Why each choice?
- Trade-offs and alternatives
- Cost implications

**Data Flow:**
```
User Action → Frontend Component → API Route → Database → Response → UI Update
```

### Step 4: Implementation Plan

**Create detailed, sequential phases:**

**Phase 1: Foundation** (Day 1)
- [ ] Write failing tests for database schema
- [ ] Create database migrations
- [ ] Implement and test database layer
- [ ] Commit
- [ ] Install required dependencies (pnpm)
- [ ] Set up environment variables
- [ ] Configure framework-specific settings
- [ ] Commit

**Phase 2: Backend** (Day 2)
- [ ] Write failing tests for API endpoints
- [ ] Create API routes with validation
- [ ] Implement business logic
- [ ] Add authentication/authorization
- [ ] Test API endpoints (≥80% coverage)
- [ ] Commit each endpoint separately

**Phase 3: Frontend** (Day 3-4)
- [ ] Write failing component tests
- [ ] Create base components
- [ ] Implement forms and validation
- [ ] Add error handling and loading states
- [ ] Connect to API
- [ ] Test components (≥80% coverage)
- [ ] Ensure WCAG 2.1 AA compliance
- [ ] Commit each component

**Phase 4: Integration** (Day 5)
- [ ] Write E2E tests for critical paths
- [ ] Connect all pieces
- [ ] Test full user flows
- [ ] Fix integration issues
- [ ] Commit

**Phase 5: Polish** (Day 6)
- [ ] Performance optimization (Lighthouse ≥95)
- [ ] Accessibility audit
- [ ] Security review (use security-engineer agent)
- [ ] Error message polish
- [ ] Loading state improvements
- [ ] Responsive design testing
- [ ] Commit

**Phase 6: Documentation & Deploy** (Day 7)
- [ ] Update API documentation
- [ ] Update component documentation
- [ ] Create user guide if needed
- [ ] Run full test suite (pnpm test)
- [ ] Build verification (pnpm build)
- [ ] Create PR with mannay:requesting-code-review
- [ ] Deploy to staging
- [ ] Production deployment

### Step 5: Output Format

```markdown
### Feature Overview
- **Problem**: What problem does this solve?
- **Users**: Who is this for?
- **Key Functionality**: Core capabilities

### Technical Design

**Architecture**: [Describe approach]

**Framework**: [Next.js 14 App Router / Vite 5 / etc.]

**Component Structure**:
- Component hierarchy
- State flow
- API integration points

**API Endpoints**: [List with methods and purposes]

**Database Schema**: [Tables, relationships]

**State Management**: [Approach and tools]

### Implementation Plan

[6-phase plan as above]

### File Changes

**New Files**:
```
app/api/feature/route.ts
components/Feature/FeatureContainer.tsx
components/Feature/FeatureForm.tsx
lib/feature-utils.ts
tests/feature.test.tsx
```

**Modified Files**:
```
app/page.tsx (add navigation)
lib/database.types.ts (add types)
```

### Dependencies

```bash
pnpm install package-name package-name-2
```

**Environment Variables**:
```bash
FEATURE_API_KEY=xxx
```

### Testing Strategy

- Unit tests for utilities and helpers (≥80%)
- Integration tests for API routes
- Component tests for UI
- E2E tests for critical user flows
- Accessibility testing (WCAG 2.1 AA)
- Performance testing (Lighthouse ≥95)

### Quantified Standards

- **Performance**: Lighthouse score ≥95, FCP <1.5s, LCP <2.5s
- **Accessibility**: WCAG 2.1 AA compliance, keyboard navigation
- **Testing**: ≥80% code coverage, all E2E flows covered
- **Security**: Input validation, OWASP Top 10 compliance
- **Bundle Size**: <50KB gzipped for client code
- **Error Rate**: <0.1% in production

### INVOKE Agents (MANDATORY)

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
| Technology choices | `tech-stack-researcher` |

**Example:** For a "user profile feature":
```
1. INVOKE backend-architect → Database schema design
2. INVOKE api-designer → API endpoint contracts
3. INVOKE frontend-architect → Component structure
4. INVOKE frontend-design → Visual design approach
5. INVOKE accessibility-specialist → WCAG requirements
6. INVOKE security-engineer → Data protection review
```

Do NOT just mention agents. Actually invoke them with the Task tool during planning.

### Rollout Plan

- Feature flag: `ENABLE_FEATURE=true`
- Gradual rollout: 10% → 50% → 100%
- Rollback plan: Feature flag toggle
- Monitoring: Error rates, performance metrics
- Success metrics: User adoption, error rates, performance

### Risk Assessment

**Technical Risks**:
- [Risk and mitigation]

**Time Risks**:
- [Risk and mitigation]

**Dependency Risks**:
- [Risk and mitigation]

### Next Steps

1. Review and approve this plan
2. If design needs exploration, use mannay:brainstorming
3. If ready to implement, use mannay:writing-plans for detailed step-by-step
4. OR use mannay:requesting-code-review for subagent-driven execution
5. Start with Phase 1 and test incrementally
6. Use pnpm for all package operations
7. Commit after each passing test
```

## Integration

**Called by:**
- User directly — For feature specification
- `brainstorming` — After design approved
- `task-analysis` — For complex features needing full spec

**Pairs with:**
- `brainstorming` — If design needs exploration first
- `writing-plans` — For detailed implementation steps
- `prd-builder` — For Ralph automation
- `requesting-code-review` — For subagent execution
- `test-driven-development` — For implementation
- Domain agents — Invoked during planning
- `/api-new`, `/component-new` — Quick scaffolding

## Key Principles

- **Framework-first**: Respect framework patterns and conventions
- **Test-driven**: Plan for TDD from the start
- **Quantified standards**: Use measurable success criteria
- **Agent integration**: Leverage domain experts
- **Risk identification**: Surface blockers and mitigation
- **Realistic estimates**: Include testing, review, docs, polish
- **Always use pnpm**: Not npm or yarn
- **YAGNI**: Don't over-engineer or add unnecessary features
