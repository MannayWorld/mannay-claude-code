---
name: api-testing
description: Use when you need comprehensive API endpoint tests with full coverage of happy paths, error cases, and edge cases
---

# API Testing

Generate comprehensive, production-ready API tests with full coverage.

**Announce at start:** "I'm using the api-testing skill to generate tests for this API endpoint."

## When to Use

Use this skill when:
- You have an API endpoint that needs tests
- You need to improve test coverage for existing APIs
- You're implementing new API routes
- You need to test error handling and edge cases

**Do NOT use if:**
- Endpoint doesn't exist yet (implement it first with TDD)
- You need E2E tests (this focuses on API unit/integration tests)

## Process

### Step 1: Detect Project Context

**Before generating tests:**
- Read package.json to identify test framework (Vitest, Jest, etc.)
- Check existing test patterns in the codebase
- Identify framework (Next.js API routes, Express, Fastify, etc.)
- Note authentication patterns
- Check for existing test utilities/helpers

### Step 2: Analyze API Endpoint

**Understand the endpoint:**
- HTTP method (GET, POST, PUT, DELETE, PATCH)
- Route path and parameters
- Request body schema
- Response format
- Authentication requirements
- Rate limiting
- Validation rules
- Business logic

### Step 3: Plan Test Coverage

**Test Categories:**

**1. Happy Paths (Success Cases)**
- Valid inputs return expected results
- Proper HTTP status codes (200, 201, 204)
- Correct response structure and types
- Successful data persistence
- Proper pagination (if applicable)

**2. Validation & Error Handling**
- Missing required fields (400)
- Invalid field types (400)
- Out-of-range values (400)
- Invalid formats (email, URL, etc.) (400)
- Empty request body (400)
- Malformed JSON (400)

**3. Authentication & Authorization**
- Valid authentication (200/201)
- Missing auth token (401)
- Invalid auth token (401)
- Expired auth token (401)
- Insufficient permissions (403)
- Wrong user attempting access (403)

**4. Rate Limiting**
- Within rate limits (200)
- Exceeding rate limits (429)
- Rate limit reset behavior

**5. Edge Cases**
- Empty database/no results (200 with empty array)
- Large payloads
- Special characters in input
- Unicode handling
- Boundary values (min/max)
- Duplicate requests (idempotency)

**6. Security**
- SQL injection attempts (blocked)
- NoSQL injection attempts (blocked)
- XSS payloads (sanitized)
- Path traversal attempts (blocked)
- Command injection (blocked)

**7. Performance**
- Response time benchmarks (<200ms for simple APIs)
- Concurrent request handling
- Large dataset queries

### Step 4: Generate Test Suite

**Test Structure:**

```typescript
import { describe, it, expect, beforeEach, afterEach } from 'vitest' // or jest
import { testClient } from '@/tests/utils/test-client'
import { createMockUser, cleanupTestData } from '@/tests/utils/test-helpers'

describe('API: /api/endpoint', () => {
  let authToken: string
  let testUserId: string

  beforeEach(async () => {
    // Setup: Create test user, get auth token
    const user = await createMockUser()
    testUserId = user.id
    authToken = user.token
  })

  afterEach(async () => {
    // Cleanup: Remove test data
    await cleanupTestData(testUserId)
  })

  describe('Success Cases', () => {
    it('should return 200 with valid request', async () => {
      const response = await testClient
        .post('/api/endpoint')
        .set('Authorization', `Bearer ${authToken}`)
        .send({ validData: true })

      expect(response.status).toBe(200)
      expect(response.body).toMatchObject({
        success: true,
        data: expect.any(Object)
      })
    })

    it('should persist data correctly', async () => {
      // Test that data is actually saved
    })
  })

  describe('Validation', () => {
    it('should reject missing required fields', async () => {
      const response = await testClient
        .post('/api/endpoint')
        .set('Authorization', `Bearer ${authToken}`)
        .send({})

      expect(response.status).toBe(400)
      expect(response.body.error).toContain('required')
    })

    it('should validate field types', async () => {
      // Test type validation
    })

    it('should validate field formats', async () => {
      // Test format validation (email, URL, etc.)
    })
  })

  describe('Authentication', () => {
    it('should reject requests without auth token', async () => {
      const response = await testClient
        .post('/api/endpoint')
        .send({ validData: true })

      expect(response.status).toBe(401)
    })

    it('should reject invalid auth tokens', async () => {
      // Test invalid token
    })

    it('should reject expired tokens', async () => {
      // Test expired token
    })
  })

  describe('Authorization', () => {
    it('should reject unauthorized users', async () => {
      // Test insufficient permissions
    })
  })

  describe('Error Handling', () => {
    it('should handle server errors gracefully', async () => {
      // Mock server error, verify 500 response
    })

    it('should return proper error format', async () => {
      // Verify error response structure
    })
  })

  describe('Edge Cases', () => {
    it('should handle empty results', async () => {
      // Test empty state
    })

    it('should handle special characters', async () => {
      // Test Unicode, emojis, etc.
    })

    it('should handle large payloads', async () => {
      // Test with large data
    })
  })

  describe('Security', () => {
    it('should prevent SQL injection', async () => {
      const response = await testClient
        .post('/api/endpoint')
        .set('Authorization', `Bearer ${authToken}`)
        .send({ input: "'; DROP TABLE users; --" })

      expect(response.status).toBe(400)
      // Verify table still exists
    })

    it('should sanitize XSS attempts', async () => {
      // Test XSS payload handling
    })
  })

  describe('Performance', () => {
    it('should respond within 200ms', async () => {
      const start = Date.now()
      await testClient
        .get('/api/endpoint')
        .set('Authorization', `Bearer ${authToken}`)
      const duration = Date.now() - start

      expect(duration).toBeLessThan(200)
    })
  })
})
```

### Step 5: Create Test Utilities

**Generate helper files:**

```typescript
// tests/utils/test-client.ts
import request from 'supertest'
import { app } from '@/app' // or Next.js handler

export const testClient = request(app)

// tests/utils/test-helpers.ts
export async function createMockUser() {
  // Create test user in database
  // Return user object with auth token
}

export async function cleanupTestData(userId: string) {
  // Remove all test data for user
}

export function generateMockData(overrides = {}) {
  // Generate realistic test fixtures
  return {
    name: 'Test User',
    email: 'test@example.com',
    ...overrides
  }
}
```

### Step 6: Add Test Scripts

**Update package.json:**

```json
{
  "scripts": {
    "test": "vitest",
    "test:api": "vitest tests/api",
    "test:watch": "vitest --watch",
    "test:coverage": "vitest --coverage"
  }
}
```

## Output Format

```markdown
### API Test Suite Generated

**Endpoint**: [METHOD] /api/endpoint

**Test Framework**: [Vitest / Jest]

**Coverage**:
- ✅ Happy paths (5 tests)
- ✅ Validation (8 tests)
- ✅ Authentication (4 tests)
- ✅ Authorization (3 tests)
- ✅ Error handling (3 tests)
- ✅ Edge cases (5 tests)
- ✅ Security (4 tests)
- ✅ Performance (2 tests)

**Total**: 34 tests

**Files Created**:
- `tests/api/endpoint.test.ts` - Main test suite
- `tests/utils/test-helpers.ts` - Reusable utilities (if not exists)
- `tests/fixtures/endpoint-data.ts` - Mock data

**Run Tests**:
```bash
pnpm test tests/api/endpoint.test.ts
```

**Expected Coverage**: ≥90% for this endpoint

**Integration Points**:
- Uses mannay:test-driven-development principles
- Follows security-engineer best practices
- Performance benchmarks from performance-engineer standards
```

## Quantified Standards

**Test Quality Metrics:**
- Coverage: ≥80% for API routes (≥90% target)
- Test execution time: <5s for unit tests, <30s for integration tests
- Assertions per test: ≥2 (verify status AND body)
- Mock data quality: Realistic, valid test fixtures
- Error message coverage: 100% error paths tested

**Security Testing:**
- OWASP Top 10 coverage: 100%
- Injection attack tests: SQL, NoSQL, XSS, Command
- Auth/AuthZ tests: All permission levels
- Rate limiting tests: Included if applicable

## Integration with Other Skills/Agents

**Before api-testing:**
- Use mannay:test-driven-development if API doesn't exist yet
- Use security-engineer agent to identify security test cases
- Use backend-architect agent for complex business logic tests

**After generating tests:**
- Run tests: `pnpm test`
- Check coverage: `pnpm test:coverage`
- Integrate with CI/CD pipeline
- Use code-reviewer agent to validate test quality

## Key Principles

- **Comprehensive coverage**: All paths, errors, edge cases
- **Independent tests**: No shared state between tests
- **Realistic data**: Use fixtures that match production
- **Clear descriptions**: Test names explain what's being tested
- **AAA pattern**: Arrange-Act-Assert structure
- **Fast execution**: Unit tests <5s, integration tests <30s
- **Always use pnpm**: Not npm or yarn
- **Security-first**: Test injection attacks, auth failures
- **Performance-aware**: Include response time benchmarks
- **Framework-appropriate**: Use framework testing patterns (Next.js, Express, etc.)
