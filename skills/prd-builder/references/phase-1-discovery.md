# Phase 1: Requirements Discovery

**Objective:** Understand what the user wants to build through Socratic questioning.

## Process

1. **Invoke requirements-analyst agent** with user's initial idea
2. **Ask clarifying questions** (5-10 questions):
   - What problem does this solve?
   - Who are the users?
   - What are the core features?
   - What are the constraints (tech stack, timeline, budget)?
   - What does success look like?
   - Are there existing patterns to follow?
   - What are the edge cases?
   - What should NOT be included?

3. **Document answers** in structured format:

```markdown
## Requirements Discovery

**Problem Statement:** [Clear 1-2 sentence problem]

**Target Users:** [Who will use this]

**Core Features:** [Bulleted list of must-haves]

**Constraints:**
- Tech Stack: [Existing technologies]
- Non-Negotiables: [Hard requirements]
- Out of Scope: [What we're NOT building]

**Success Criteria:** [How we measure success]
```

4. **Validate understanding** with user before proceeding

## Question Techniques

### Lettered Options (Quick Answers)

Always provide lettered options for faster user responses:

```
What type of authentication do you need?
A) Email/password only
B) OAuth (Google, GitHub)
C) Both email and OAuth
D) Something else (please describe)
```

### Open-Ended Follow-ups

After initial answers, dig deeper:
- "Can you give me an example of when this would be used?"
- "What happens if [edge case]?"
- "Is there an existing system we should follow as reference?"

## Output

**File:** `planning/YYYY-MM-DD-<feature>-requirements.md`

**Format:**
```markdown
# Requirements: [Feature Name]

## Problem Statement
[1-2 sentences describing the core problem]

## Target Users
- [User type 1]: [Their needs]
- [User type 2]: [Their needs]

## Core Features (Must-Have)
1. [Feature 1]
2. [Feature 2]
3. [Feature 3]

## Nice-to-Have Features
1. [Feature 1]
2. [Feature 2]

## Constraints
- **Tech Stack:** [Technologies]
- **Timeline:** [If applicable]
- **Non-Negotiables:** [Hard requirements]

## Out of Scope
- [Explicit exclusion 1]
- [Explicit exclusion 2]

## Success Criteria
- [Measurable outcome 1]
- [Measurable outcome 2]

## Open Questions
- [Question 1]
- [Question 2]
```

## Validation Checkpoint

Before proceeding to Phase 2, confirm with user:

```
"I understand you want to build [summary]. The core features are:
1. [Feature 1]
2. [Feature 2]
3. [Feature 3]

Out of scope: [exclusions]

Does this capture your requirements correctly?"
```

Only proceed when user confirms.
