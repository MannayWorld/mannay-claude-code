---
name: ui-animation
description: Implement polished UI animations with precise timing, easing, and motion. Use when adding transitions, hover effects, or making interfaces feel responsive. Covers philosophy (when NOT to animate), timing, easing, component patterns, and accessibility.
---

# UI Animation

Animations must be **fast**, **natural**, and **purposeful**. The best animation goes unnoticed—users feel the interface is polished without pointing to specific animations.

---

## Philosophy: When to Animate

**First question: Should this animate at all?**

Animation appropriateness depends on interaction frequency:

| Frequency | Recommendation |
|-----------|----------------|
| Rare (monthly) | Delightful animations welcome |
| Occasional (daily) | Subtle, fast animations |
| Frequent (100s/day) | Minimal or NO animation |
| Keyboard-initiated | **NEVER** animate |

**The test**: If users trigger this action hundreds of times daily, animation adds friction, not delight. Productivity tools (Raycast, Linear) benefit from zero animation on frequent actions.

---

## Core Timing

**UI animations must stay under 300ms.** This is non-negotiable for responsive feel.

| Element | Duration | Easing |
|---------|----------|--------|
| Button press | 150ms | ease-out |
| Tooltip | 125ms | ease-out |
| Dropdown/popover | 180ms | ease-out |
| Modal | 200ms | ease-out |
| Drawer (iOS-style) | 500ms | cubic-bezier(0.32, 0.72, 0, 1) |
| Toast auto-dismiss | 4 seconds | — |

**Speed creates perceived performance.** 180ms feels more responsive than 400ms. When in doubt, go faster.

---

## Enter/Exit Patterns

### The Enter Recipe

Combine three properties for a "materializing" effect:

```jsx
initial={{ opacity: 0, translateY: 8, filter: "blur(4px)" }}
animate={{ opacity: 1, translateY: 0, filter: "blur(0px)" }}
transition={{ type: "spring", duration: 0.45, bounce: 0 }}
```

| Property | From | To | Purpose |
|----------|------|-----|---------|
| opacity | 0 | 1 | Fade in |
| translateY | 8px | 0 | Subtle upward movement |
| blur | 4px | 0 | "Coming into focus" effect |

### Exit Asymmetry (Critical)

**Exits must be subtler than enters.** User focus moves to what's next, not what's leaving.

```jsx
// WRONG: Same as enter
exit={{ opacity: 0, translateY: 8, filter: "blur(4px)" }}

// CORRECT: Subtler exit
exit={{ opacity: 0, translateY: -8, filter: "blur(4px)" }}
```

Use smaller, fixed values for exits. Don't compete for attention.

### Scale Rules

**Never animate from scale(0)** — feels like element appears from nowhere.

```jsx
// WRONG: Unnatural
initial={{ scale: 0 }}

// CORRECT: Gentle, natural
initial={{ scale: 0.93, opacity: 0 }}
animate={{ scale: 1, opacity: 1 }}
```

| Element | Initial Scale |
|---------|---------------|
| Modal | 0.93 |
| Dropdown | 0.93 |
| Tooltip | 0.97 |
| Button press | 0.97 |

---

## Easing

### Custom Easing is Essential

Built-in CSS easing (`ease`, `ease-in-out`) lacks strength. Always use custom curves.

| Use Case | Easing | Why |
|----------|--------|-----|
| **Default (90% of UI)** | `ease-out` | Fast start, gentle stop. Feels responsive |
| Moving elements | `ease-in-out` | Natural acceleration/deceleration |
| **Never use** | `ease-in` | Speeds up at end—wrong for UI |
| Interactive | `spring` | Natural deceleration |

**Resources**: [easing.dev](https://easing.dev), [easings.co](https://easings.co)

### Spring Configuration

```jsx
transition={{ type: "spring", duration: 0.45, bounce: 0 }}
```

| Parameter | Effect |
|-----------|--------|
| **bounce: 0** | Professional, refined (default for production) |
| **bounce: 0.1** | Slight playfulness |
| **bounce: 0.2+** | Only for explicitly playful contexts |
| **stiffness** | Higher = faster to target |
| **damping** | Higher = less oscillation |

**Default to `bounce: 0`** for professional UI.

---

## Transform-Origin

**Default `center` is wrong for most UI.** Elements should animate from their trigger point.

```css
/* Dropdown opens below button */
.dropdown { transform-origin: top center; }

/* Dropdown opens above */
.dropdown[data-side="top"] { transform-origin: bottom center; }

/* Context menu from click point */
.menu { transform-origin: var(--origin-x) var(--origin-y); }
```

**Component libraries:**
- Radix UI: `--radix-dropdown-menu-content-transform-origin`
- Base UI: `--transform-origin`

---

## Interruptibility

### Transitions vs Keyframes

**CSS keyframes can't be interrupted.** When users trigger actions rapidly, elements "jump" instead of smoothly retargeting.

```jsx
// WRONG: Keyframes (can't interrupt)
@keyframes slideIn {
  from { transform: translateY(100%); }
  to { transform: translateY(0); }
}
.toast { animation: slideIn 400ms ease; }

// CORRECT: Transitions (can interrupt mid-flight)
.toast {
  transform: translateY(100%);
  transition: transform 400ms ease;
}
.toast.mounted {
  transform: translateY(0);
}
```

### State-Driven Pattern

```jsx
useEffect(() => {
  setMounted(true);
}, []);

// CSS handles animation via class change
```

### Velocity-Based Dismissal

For swipe-to-dismiss (toasts, drawers), use velocity not distance:

```javascript
// WRONG: Distance threshold (requires long drag)
if (dragDistance > 100) dismiss();

// CORRECT: Velocity (fast short gestures work)
const velocity = dragDistance / elapsedTime;
if (velocity > 0.11) dismiss();
```

---

## Component Patterns

### Button Press

```css
.button {
  transition: transform 150ms ease-out;
}
.button:active {
  transform: scale(0.97);
}
```

For subtler effect, use `scale(0.98)`.

### Tooltip

```css
.tooltip {
  opacity: 0;
  transform: scale(0.97);
  transition: transform 125ms ease-out, opacity 125ms ease-out;
}
.tooltip[data-visible] {
  opacity: 1;
  transform: scale(1);
}

/* After first tooltip, subsequent ones: instant */
[data-tooltip-group="active"] .tooltip {
  transition-duration: 0ms;
}
```

**Tooltip delay pattern**: First tooltip delayed + animated. Subsequent tooltips in same group: instant.

### Modal

```css
.modal-overlay {
  opacity: 0;
  transition: opacity 200ms ease-out;
}
.modal-overlay[data-open] {
  opacity: 1;
}

.modal-content {
  opacity: 0;
  transform: scale(0.93);
  transition: transform 200ms ease-out, opacity 200ms ease-out;
}
.modal-content[data-open] {
  opacity: 1;
  transform: scale(1);
}
```

### Dropdown

```css
.dropdown {
  opacity: 0;
  transform: scale(0.93);
  transform-origin: top center;
  transition: transform 180ms ease-out, opacity 180ms ease-out;
  pointer-events: none;
}
.dropdown[data-open] {
  opacity: 1;
  transform: scale(1);
  pointer-events: auto;
}
```

### iOS-Style Drawer

```css
.drawer {
  transform: translateY(100%);
  transition: transform 500ms cubic-bezier(0.32, 0.72, 0, 1);
}
.drawer[data-open] {
  transform: translateY(0);
}
```

The curve `cubic-bezier(0.32, 0.72, 0, 1)` matches native iOS sheets.

### Icon Swap

When icons change state (copy → check), animate the transition:

```jsx
<AnimatePresence mode="wait">
  {isCopied ? (
    <motion.div
      initial={{ opacity: 0, scale: 0.8, filter: "blur(4px)" }}
      animate={{ opacity: 1, scale: 1, filter: "blur(0px)" }}
      exit={{ opacity: 0, scale: 0.8, filter: "blur(4px)" }}
    >
      <CheckIcon />
    </motion.div>
  ) : (
    <motion.div ...>
      <CopyIcon />
    </motion.div>
  )}
</AnimatePresence>
```

**See [component-patterns.md](references/component-patterns.md) for complete patterns.**

---

## Performance

### Only Animate Transform + Opacity

These use GPU compositing and stay smooth:
- `transform` (translate, scale, rotate)
- `opacity`
- `filter` (blur, brightness)

**Never animate** (triggers expensive layout/paint):
- `width`, `height`
- `padding`, `margin`
- `top`, `left`, `right`, `bottom`
- `border-width`

```css
/* WRONG: Triggers layout */
.expand { width: 100px; transition: width 200ms; }
.expand:hover { width: 200px; }

/* CORRECT: GPU accelerated */
.expand { transform: scaleX(1); transition: transform 200ms ease-out; }
.expand:hover { transform: scaleX(2); }
```

### will-change (Use Sparingly)

```css
/* CORRECT: Specific properties */
.animated-button { will-change: transform, opacity; }

/* WRONG: Too broad */
* { will-change: transform; }
```

### Direct Style Updates for Drag

CSS variables cause cascade recalculation. For frequent updates (dragging), update styles directly:

```javascript
// WRONG: Expensive cascade
element.style.setProperty('--drag-y', `${y}px`);

// CORRECT: No cascade
element.style.transform = `translateY(${y}px)`;
```

---

## Accessibility

### prefers-reduced-motion (Mandatory)

```css
@media (prefers-reduced-motion: reduce) {
  *,
  *::before,
  *::after {
    animation-duration: 0.01ms !important;
    animation-iteration-count: 1 !important;
    transition-duration: 0.01ms !important;
  }
}
```

Or provide alternative animations:

```css
@media (prefers-reduced-motion: reduce) {
  .modal-content {
    /* Fade only, no scale */
    transform: translate(-50%, -50%);
    transition: opacity 200ms ease-out;
  }
}
```

### Vestibular Triggers to Avoid

- Full-screen zoom effects
- Parallax scrolling
- Continuous spinning/rotation
- Rapid flashing

---

## Quick Reference

```
Philosophy:        Should this animate? Check frequency first.
Max duration:      < 300ms (except drawers at 500ms)
Default easing:    ease-out
Spring bounce:     0 (professional), 0.1+ (playful only)

Button press:      scale(0.97), 150ms, ease-out
Tooltip:           scale(0.97), 125ms, ease-out
Modal:             scale(0.93), 200ms, ease-out
Dropdown:          scale(0.93), 180ms, ease-out, origin from trigger
Drawer (iOS):      500ms, cubic-bezier(0.32, 0.72, 0, 1)
Toast:             4s dismiss, pause when inactive

Enter:             opacity + translateY(8) + blur(4px)
Exit:              SUBTLER than enter (translateY -8px)
Scale:             Start from 0.93+ (never 0)

Only animate:      transform, opacity, filter
Never animate:     width, height, padding, margin, top/left

Interruptibility:  Use transitions (not keyframes)
Dismissal:         Use velocity threshold (0.11), not distance

Accessibility:     prefers-reduced-motion is MANDATORY
```

---

## References

- **[component-patterns.md](references/component-patterns.md)** — Full CSS patterns for all components
- **[advanced-techniques.md](references/advanced-techniques.md)** — @property, linear(), layoutId, scroll-driven
- **[common-mistakes.md](references/common-mistakes.md)** — Anti-patterns to avoid
- **[audit-checklist.md](references/audit-checklist.md)** — Quick review checklist

---

## Integration

**Called by:**
- `frontend-design` — For component/page creation
- `component-new` — For new component generation
- `page-new` — For new page creation
- `page-new-react` — For React Router pages
- `frontend-architect` — For component architecture decisions

**Works with:**
- `adaptive-design` — Responsive layout patterns
- `web-design-guidelines` — Accessibility and design compliance
- `react-best-practices` — React animation patterns
