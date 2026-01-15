---
name: web-design-guidelines
description: "Review UI code for Web Interface Guidelines compliance. Use when asked to review UI, check accessibility, audit design, review UX, or check site against best practices."
impact: HIGH
allowed-tools: Read, Grep, Glob, WebFetch
triggers:
  - "review UI"
  - "check accessibility"
  - "audit design"
  - "review UX"
  - "design review"
  - "UI audit"
  - "accessibility audit"
---

# Web Design Guidelines

Review files for compliance with modern web interface best practices.

## When to Use

This skill activates when:
- Reviewing UI component code
- Checking accessibility compliance
- Auditing design implementation
- Reviewing user experience patterns
- Checking against industry best practices

---

## Guidelines Reference

### 1. Accessibility (CRITICAL)

**Icon Buttons**
- Every `<button>` with only an icon MUST have `aria-label`
- Bad: `<button><Icon /></button>`
- Good: `<button aria-label="Close dialog"><Icon /></button>`

**Form Controls**
- All inputs MUST have associated `<label>` or `aria-label`
- Bad: `<input type="email" />`
- Good: `<input type="email" aria-label="Email address" />` or `<label>Email<input type="email" /></label>`

**Interactive Elements**
- Use `<button>`, `<a>`, `<Link>` instead of `<div onClick>`
- Every interactive element must work with keyboard (`Enter`, `Space`, arrow keys)
- Add `tabindex="0"` only when necessary (prefer semantic HTML)

**ARIA Best Practices**
- Prefer semantic HTML over ARIA attributes
- Add `aria-hidden="true"` to decorative icons
- Use `aria-live="polite"` for async content updates
- Headings must be hierarchical (h1 → h2 → h3) with skip-links

**Images**
- All `<img>` must have `alt` text (empty `alt=""` for decorative images)
- Functional images need descriptive alt text

### 2. Focus States (HIGH)

**Visible Focus Required**
- All interactive elements MUST have visible focus indicators
- Use `focus-visible:ring-*` pattern in Tailwind
- Bad: `outline-none` without replacement
- Good: `focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-blue-500`

**Focus-Visible over Focus**
- Use `:focus-visible` not `:focus` to avoid focus rings on click
- Ensures keyboard users see focus, mouse users don't

### 3. Forms (HIGH)

**Input Attributes**
- Every input needs appropriate `autocomplete` attribute
- Use correct `type` (email, tel, url, password, etc.)
- Add meaningful `name` attributes
- Set appropriate `inputmode` (numeric, email, tel, etc.)

**Validation & Errors**
- NEVER block paste in any input field
- Disable spellcheck on emails, codes, tokens: `spellcheck="false"`
- Display errors inline next to the field
- Focus first error field on form submission

**Labels & Targets**
- Labels must be clickable and associated with inputs
- Checkboxes/radios need shared click targets (label + input)
- Enable submit button until request starts (disable only during submit)

**Navigation**
- Warn users before navigating away with unsaved changes

### 4. Animation (MEDIUM)

**Motion Preferences**
- ALWAYS respect `prefers-reduced-motion`
- Wrap animations: `@media (prefers-reduced-motion: no-preference) { ... }`

**Performance**
- Animate ONLY `transform` and `opacity` (GPU-accelerated)
- NEVER use `transition: all` - list specific properties
- Bad: `transition: all 0.3s ease`
- Good: `transition: opacity 200ms ease-in-out, transform 200ms ease-in-out`

**User Control**
- Animations should respond to/be interruptible by user input

### 5. Typography (MEDIUM)

**Punctuation**
- Use proper ellipsis: `…` not `...`
- Use curly quotes: `"` `"` `'` `'` not straight quotes
- Add non-breaking spaces (`&nbsp;` or `\u00A0`) for measurements, brand names

**Layout**
- Apply `text-wrap: balance` to headings
- Handle long content with `truncate`, `line-clamp-*`, or `break-words`
- Show graceful empty states (never blank containers)

### 6. Images (MEDIUM)

**Dimensions**
- All images MUST have explicit `width` and `height` to prevent CLS
- Bad: `<img src="..." />`
- Good: `<img src="..." width={400} height={300} />`

**Loading**
- Below-fold images: `loading="lazy"`
- Above-fold/critical images: `loading="eager"` or `priority`

### 7. Performance (HIGH)

**Large Lists**
- Virtualize lists with >50 items (use react-window, tanstack-virtual, etc.)

**Layout**
- Avoid layout reads (`getBoundingClientRect`, `offsetHeight`) during render
- Batch DOM operations
- Use `content-visibility: auto` for long scrolling content

**Preloading**
- Add `<link rel="preconnect">` for critical third-party domains

### 8. Navigation & State (MEDIUM)

**URL State**
- URL MUST reflect UI state: filters, tabs, pagination, panels
- Support deep-linking to all stateful UI
- Back/forward navigation should work correctly

**Destructive Actions**
- Require confirmation for destructive actions (delete, remove)
- Use distinct styling for destructive buttons

### 9. Dark Mode & Theming (LOW)

**Meta Tags**
- Include `<meta name="color-scheme" content="light dark" />`
- Set `<meta name="theme-color">` appropriately

**CSS**
- Use CSS custom properties for theming
- Test both light and dark modes

### 10. Touch & Interaction (LOW)

**Touch Targets**
- Minimum touch target size: 44x44px
- Add appropriate `touch-action` for scrollable areas
- Consider tap-highlight color for mobile

### 11. Locale & i18n (LOW)

**Formatting**
- Use `Intl.DateTimeFormat` for dates (never hardcode format)
- Use `Intl.NumberFormat` for numbers/currency

---

## Anti-Patterns to Flag

Always flag these patterns as issues:

| Pattern | Problem |
|---------|---------|
| `user-scalable=no` | Blocks zoom accessibility |
| `transition: all` | Performance issue |
| `outline-none` without ring | Removes focus indicator |
| Icon button without `aria-label` | Screen reader inaccessible |
| `<img>` without dimensions | Causes layout shift |
| `<div onClick>` | Not keyboard accessible |
| Hardcoded date/number formats | i18n issue |
| `tabindex > 0` | Breaks natural focus order |

---

## Output Format

When auditing files, output findings in terse `file:line` format (VS Code clickable):

```
src/components/Button.tsx:24 Icon button missing aria-label
src/components/Form.tsx:45 Input needs associated <label>
src/components/Modal.tsx:12 Using transition: all (specify properties)
src/components/Card.tsx:8 Image missing width/height attributes
✓ src/components/Header.tsx passes all checks
```

**Output Rules:**
- Group findings by file
- State issue concisely (no verbose explanations)
- Skip explanations unless fix is non-obvious
- Mark compliant files with ✓ checkmark

---

## Usage

When a user asks to review UI code:

1. Read the specified files (or ask user which files to review)
2. Check against ALL rules in this document
3. Output findings using the format above
4. Prioritize by impact: CRITICAL > HIGH > MEDIUM > LOW

---

## Integration

This skill works well with:
- `frontend-design` skill for building compliant UIs
- `react-best-practices` skill for React-specific optimizations
- `code-reviewer` agent for comprehensive reviews
- `accessibility-specialist` agent for deep accessibility audits
