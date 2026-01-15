# Phase 2: Design Exploration

**Objective:** Explore 2-3 design approaches and select the best one.

## Process

1. **Invoke brainstorming skill** with requirements document
2. **Generate design options** (2-3 approaches)
3. **Present to user** with recommendations
4. **User selects** preferred approach
5. **Document decision** with rationale

## Design Options Template

```markdown
## Design Options

### Option A: [Name]

**Description:**
[Brief description of the approach]

**Pros:**
- [Benefit 1]
- [Benefit 2]
- [Benefit 3]

**Cons:**
- [Limitation 1]
- [Limitation 2]

**Complexity:** Low / Medium / High

**Estimated Stories:** [X-Y stories]

---

### Option B: [Name]

**Description:**
[Brief description of the approach]

**Pros:**
- [Benefit 1]
- [Benefit 2]

**Cons:**
- [Limitation 1]
- [Limitation 2]

**Complexity:** Low / Medium / High

**Estimated Stories:** [X-Y stories]

---

### Option C: [Name] (if applicable)
[Same structure]

---

## Recommendation

**Recommended:** Option [A/B/C]

**Rationale:**
[Why this option is best for the requirements]
```

## Evaluation Criteria

When comparing options, consider:

1. **Alignment with Requirements**
   - Does it address all must-have features?
   - How well does it handle edge cases?

2. **Implementation Complexity**
   - How many stories will this generate?
   - Are there complex integrations?
   - What's the testing complexity?

3. **Maintainability**
   - How easy to modify later?
   - Does it follow existing patterns?
   - Is it well-documented?

4. **Performance**
   - Will it scale?
   - Are there potential bottlenecks?

5. **User Experience**
   - Is it intuitive?
   - Does it match user expectations?

## Example Design Exploration

**Feature:** User Profile Management

### Option A: Single Page with Inline Editing
- User views profile and edits in place
- Save button appears when changes detected
- **Pros:** Quick edits, fewer clicks
- **Cons:** Complex state management, harder to cancel
- **Complexity:** Medium

### Option B: View Mode + Edit Modal
- Read-only view with "Edit" button
- Modal form for editing
- **Pros:** Clear separation, easy to cancel
- **Cons:** Extra click to edit
- **Complexity:** Low

### Option C: Multi-Step Wizard
- Separate steps for different profile sections
- Progress indicator
- **Pros:** Guided experience, good for complex profiles
- **Cons:** More clicks, overkill for simple profiles
- **Complexity:** High

**Recommendation:** Option B - Clear UX, manageable complexity, matches existing patterns in codebase.

## Output

**File:** `planning/YYYY-MM-DD-<feature>-design.md`

## Validation Checkpoint

```
"I've explored 3 design approaches:

A) [Option A summary]
B) [Option B summary]
C) [Option C summary]

I recommend Option [X] because [rationale].

Which approach would you prefer?"
```

Wait for user selection before proceeding.
