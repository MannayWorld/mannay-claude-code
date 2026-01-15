# Phase 3: Technical Planning

**Objective:** Create detailed technical specification with implementation details.

## Process

1. **Invoke feature-planning skill** with chosen design
2. **Generate technical spec** including all required sections
3. **Invoke relevant agents** for validation
4. **Refine based on agent feedback**

## Technical Spec Template

```markdown
# Technical Specification: [Feature Name]

## Overview
[One paragraph describing the technical approach]

## Architecture

### System Components
```
[Component diagram or description]
```

### Data Flow
```
[Sequence or flow diagram]
```

## Data Models

### Database Schema
```sql
CREATE TABLE [table_name] (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  [field_name] [TYPE] [constraints],
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);
```

### TypeScript Types
```typescript
interface [TypeName] {
  id: string;
  [fieldName]: [type];
}
```

## API Specifications

### Endpoint: [METHOD] /api/[path]

**Request:**
```typescript
interface [RequestType] {
  [field]: [type];
}
```

**Response:**
```typescript
interface [ResponseType] {
  [field]: [type];
}
```

**Validation:**
- [Rule 1]
- [Rule 2]

**Error Responses:**
- 400: [Validation error]
- 401: [Unauthorized]
- 404: [Not found]
- 500: [Server error]

## Component Hierarchy

```
[ParentComponent]
├── [ChildComponent1]
│   └── [SubComponent]
├── [ChildComponent2]
└── [ChildComponent3]
```

### Component: [ComponentName]
- **Props:** [list of props with types]
- **State:** [local state if any]
- **Events:** [event handlers]

## Testing Strategy

### Unit Tests
- [What to test]
- [Coverage target: 85%]

### Integration Tests
- [API integration tests]
- [Component integration tests]

### E2E Tests (if applicable)
- [Critical user flows]

## Security Considerations

- [ ] Input validation on all endpoints
- [ ] Authentication required for [routes]
- [ ] Authorization checks for [actions]
- [ ] Rate limiting on [endpoints]
- [ ] Data sanitization for [fields]

## Performance Requirements

- API response time: < [X]ms
- Database queries: < [Y]ms
- Bundle size impact: < [Z]KB
```

## Agent Validation

Invoke relevant agents for review:

### security-engineer
- Review auth/validation approach
- Check for common vulnerabilities
- Validate rate limiting strategy

### typescript-pro
- Validate type definitions
- Check for type safety issues
- Review generics usage

### backend-architect
- Review data model design
- Validate API specifications
- Check query efficiency

### frontend-architect
- Review component architecture
- Validate state management
- Check accessibility approach

## Output

**File:** `planning/YYYY-MM-DD-<feature>-spec.md`

## Validation Checkpoint

```
"The technical specification is ready:

**Data Model:** [summary]
**API Endpoints:** [list]
**Components:** [list]
**Testing:** [approach]

Agent reviews:
- security-engineer: [status]
- typescript-pro: [status]
- backend-architect: [status]
- frontend-architect: [status]

Ready to proceed with story breakdown?"
```

Wait for user confirmation before Phase 4.
