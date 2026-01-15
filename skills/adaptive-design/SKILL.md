---
name: adaptive-design
description: Design with real data and adaptive layouts. Use when creating responsive interfaces, building components, planning layouts, or when designs need to handle variable content, multiple screen sizes, or dynamic data.
---

# Adaptive Design

Design tools should match the medium. Interfaces are fluid and data-driven — design process should be too.

## Core Principle: Design with Real Data

**Idealized data deceives.** Designers fill mocks with perfectly composed photos, ideal text lengths, and just the right amount of content. Then implementation breaks everything.

### The Problem with Fake Data
- Beautiful avatar photos → Real users have none or low-quality
- "John Smith" → Real names are "Bartholomew Witherspoon III"
- Perfect 2-line descriptions → Real content is 10 lines or empty
- Curated 6-item lists → Real data has 0, 1, or 47 items

### Design in Reality
When you work with real data:
- Data **informs and constrains** your work
- Edge cases surface **during design**, not development
- You make **better product decisions** based on actual constraints
- Designs are **robust from the start**

### Practical Application

1. **Connect to real APIs** or JSON files when possible
2. **Test with extremes**: empty states, single items, hundreds of items
3. **Use real names**: long names, names with special characters, names in other scripts
4. **Test real images**: missing images, wrong aspect ratios, low resolution
5. **Test real text**: very short, very long, multi-line, special characters

## Adaptive Layouts

**The age of pixel-perfect design for fixed sizes is over.** Devices have countless screen sizes, densities, and orientations.

### Constraint-Based Thinking

Instead of fixed pixel positions, define **relationships**:

```
❌ Fixed: "Element is at x:234, y:567"
✅ Adaptive: "Element is 16pt from left edge, 24pt below header"
```

### Layout Primitives

**Size**: Fixed, percentage, or fill-available
**Alignment**: Left, center, right, top, bottom
**Pinning**: Relative to edges or other elements

### Edge Pinning

Pin elements relative to container edges:

```css
/* Pinned 16pt from left and right — fluid width */
.search-input {
  position: absolute;
  left: 16px;
  right: 16px;
}

/* Pinned to bottom with negative offset — partial visibility */
.preview-card {
  position: absolute;
  bottom: -90px; /* Shows partial preview */
}
```

### Relative Positioning

Define elements relative to each other, not absolute coordinates:

```css
/* Below header with consistent gap */
.content {
  margin-top: 24px;
}

/* Sibling relationship */
.sidebar + .main {
  margin-left: 16px;
}
```

### The Canvas is Not Fixed

Design for the range of sizes your interface will live in:

1. **Start with constraints**, not pixels
2. **Resize your canvas** during design to test adaptability
3. **Define relationships** that hold across sizes
4. **Test breakpoints** as part of design, not afterthought

## Component Thinking

Components are **reusable objects** with defined types, properties, and behaviors.

### Data-Driven Components

A component should work with **any valid data**, not just the perfect example:

```
✅ Card component that handles:
   - Title: 1-100 characters
   - Description: 0-500 characters (or none)
   - Image: present, missing, or error state
   - Actions: 0-4 buttons
```

### Test Your Components With:

| Scenario | What Breaks |
|----------|-------------|
| No data | Empty states, null handling |
| Minimal data | Single character, one item |
| Maximum data | Truncation, overflow, scrolling |
| Missing fields | Optional content, fallbacks |
| Wrong format | Image errors, parse failures |

## Layout Patterns

### Fluid Containers

```css
.container {
  width: 100%;
  max-width: 1200px;
  margin: 0 auto;
  padding: 0 16px;
}
```

### Responsive Without Breakpoints

Use CSS that adapts naturally:

```css
/* Fluid grid */
.grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(280px, 1fr));
  gap: 24px;
}

/* Fluid type */
.heading {
  font-size: clamp(24px, 5vw, 48px);
}

/* Fluid spacing */
.section {
  padding: clamp(24px, 5vw, 64px);
}
```

### Content-First Breakpoints

Let content determine breakpoints, not device categories:

```css
/* Break when content needs it */
@media (min-width: 600px) {
  /* Sidebar fits */
}

@media (min-width: 900px) {
  /* Three columns fit */
}
```

## Edge Cases to Design For

### Empty States
- No items yet
- Search with no results
- Error fetching data
- User hasn't set up feature

### Overflow States
- Text too long for container
- Too many items for layout
- Image wrong aspect ratio
- Number too large for display

### Loading States
- Initial load
- Pagination/infinite scroll
- Background refresh
- Slow connection

### Error States
- Network failure
- Invalid data
- Permission denied
- Feature unavailable

## Checklist

Before finalizing any design:

- [ ] Tested with real or realistic data
- [ ] Tested with empty state
- [ ] Tested with minimal content (1 character, 1 item)
- [ ] Tested with maximum content (overflow)
- [ ] Tested with missing optional fields
- [ ] Resized canvas to test adaptability
- [ ] Defined constraints, not just pixel positions
- [ ] Components handle data variations
- [ ] Error and loading states designed

---

## Integration

**Called by:**
- `frontend-design` — For component/page creation
- `component-new` — For new component generation
- `page-new` — For new page creation
- `page-new-react` — For React Router pages
- `frontend-architect` — For component architecture decisions

**Works with:**
- `ui-animation` — Animation patterns for adaptive interfaces
- `web-design-guidelines` — Accessibility and design compliance
