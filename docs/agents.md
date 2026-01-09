# Agents Reference

> Complete reference for all Mannay agents (domain specialists).

## Overview

Agents are **domain specialists** invoked by skills or directly. They provide expert knowledge in specific areas.

## How Agents Are Invoked

1. **By skills automatically** - Skills invoke relevant agents based on task
2. **By the Task tool** - `Task(subagent_type="agent-name")`
3. **By mentioning their domain** - Orchestrator detects and invokes

## Architecture Agents

### backend-architect

**Expertise:** API design, database schema, authentication, reliability

**Invoke when:**
- Designing APIs or database schemas
- Implementing authentication
- Building reliable backend systems

**Standards:**
- Data integrity first
- Fault tolerance
- Security by default

---

### frontend-architect

**Expertise:** Component architecture, responsive design, Core Web Vitals

**Invoke when:**
- Designing component hierarchies
- Optimizing frontend performance
- Building design systems

**Standards:**
- Lighthouse ≥95
- Mobile-first
- Accessibility built-in

---

### api-designer

**Expertise:** REST, GraphQL, tRPC, gRPC, contract-first design

**Invoke when:**
- Designing API contracts
- Creating OpenAPI specs
- Building GraphQL schemas

**Standards:**
- Contract-first
- Versioning strategy
- Clear error responses

---

### system-architect

**Expertise:** Scalability, component boundaries, long-term decisions

**Invoke when:**
- Planning system architecture
- Making technology decisions
- Designing for scale (10x growth)

**Standards:**
- Maintainability focus
- Clear boundaries
- Documentation

---

### requirements-analyst

**Expertise:** PRD creation, user stories, scope definition

**Invoke when:**
- Gathering requirements
- Writing user stories
- Defining scope

**Standards:**
- Structured discovery
- Testable acceptance criteria
- Clear scope boundaries

---

### tech-stack-researcher

**Expertise:** Technology comparisons, library recommendations

**Invoke when:**
- Choosing technologies
- Comparing libraries
- Evaluating trade-offs

**Standards:**
- Objective comparison
- Cost consideration
- Future-proofing

---

## Quality Agents

### code-reviewer

**Expertise:** SOLID principles, code quality, production readiness

**Invoke when:**
- Reviewing code before merge
- Checking quality standards
- Finding improvements

**Standards:**
- Quantified metrics
- Actionable feedback
- Production focus

---

### typescript-pro

**Expertise:** Advanced types, type safety, strict mode

**Invoke when:**
- Complex type definitions
- Type inference issues
- Generic patterns

**Standards:**
- No `any` types
- Full type coverage
- Strict mode compliance

---

### accessibility-specialist

**Expertise:** WCAG 2.1 AA, screen readers, keyboard navigation

**Invoke when:**
- Building UI components
- Auditing accessibility
- Form design

**Standards:**
- WCAG 2.1 AA minimum
- Keyboard navigable
- Screen reader tested

---

### performance-engineer

**Expertise:** Bottleneck identification, optimization, profiling

**Invoke when:**
- Performance issues
- Optimization needed
- Bundle size concerns

**Standards:**
- Measurement-driven
- Lighthouse ≥95
- Bundle <50KB gzipped

---

### security-engineer

**Expertise:** Vulnerability assessment, OWASP Top 10, zero-trust

**Invoke when:**
- Authentication/authorization
- Input validation
- Security review

**Standards:**
- OWASP compliance
- Input validation
- Security-first design

---

### refactoring-expert

**Expertise:** Technical debt reduction, clean code, DRY

**Invoke when:**
- Code cleanup needed
- Technical debt
- Improving maintainability

**Standards:**
- Clean code principles
- SOLID adherence
- Test coverage maintained

---

## Documentation Agents

### technical-writer

**Expertise:** Clear documentation, audience-tailored content

**Invoke when:**
- Writing documentation
- API documentation
- User guides

**Standards:**
- Clear and concise
- Audience appropriate
- Examples included

---

### documentation-engineer

**Expertise:** Docs-as-infrastructure, automated generation

**Invoke when:**
- Setting up doc systems
- Automated doc generation
- Multi-format output

**Standards:**
- Versioned docs
- Automated testing
- CI/CD integration

---

### learning-guide

**Expertise:** Progressive teaching, concept explanation

**Invoke when:**
- Explaining concepts
- Teaching patterns
- Learning materials

**Standards:**
- Progressive complexity
- Practical examples
- Clear explanations

---

### deep-research-agent

**Expertise:** Comprehensive research, analysis

**Invoke when:**
- Deep investigation needed
- Multi-source research
- Complex analysis

**Standards:**
- Thorough coverage
- Source verification
- Structured output

---

## Agent Chaining

Skills automatically chain agents based on task domain:

| Task Domain | Agents Chained |
|-------------|----------------|
| User authentication | security-engineer → backend-architect → api-designer |
| UI component | frontend-architect → accessibility-specialist → typescript-pro |
| API endpoint | api-designer → backend-architect → security-engineer |
| Database work | backend-architect → typescript-pro |
| Performance issue | performance-engineer → frontend-architect or backend-architect |
