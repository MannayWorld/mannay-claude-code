---
name: ui-animation
description: Implement polished UI animations with precise timing, easing, and scale values. Use when adding transitions, hover effects, motion, or making interfaces feel responsive. Covers buttons, modals, dropdowns, tooltips, toasts, drawers.
---

# UI Animation

Animations must be **fast**, **natural**, and **purposeful**. Know when NOT to animate.

## Core Timing Rule

**UI animations must stay under 300ms.** This is non-negotiable for responsive feel.

| Element | Duration | Notes |
|---------|----------|-------|
| Button press | ~150ms | Quick tactile feedback |
| Tooltip | 125ms | Fast appear/disappear |
| Dropdown/popover | 150-200ms | Snappy open |
| Modal | 200ms | Appears instantly responsive |
| Drawer (iOS-style) | 500ms | Longer, uses specific curve |
| Toast auto-dismiss | 4 seconds | Pause when tab inactive |

## Button Press Pattern

Scale to **0.97** on active state with **~150ms ease-out**:

```css
.button {
  transition: transform 150ms ease-out;
}
.button:active {
  transform: scale(0.97);
}
```

For subtler effect, use `scale(0.98)`.

## Enter Animation Scale

**Never animate from scale(0)** — feels like element appears from nowhere.

Use **scale(0.9+)** as initial value. Recommended: **scale(0.93)** for dropdowns.

```css
/* Wrong */
.dropdown[data-entering] {
  transform: scale(0);
  opacity: 0;
}

/* Correct */
.dropdown[data-entering] {
  transform: scale(0.93);
  opacity: 0;
}

.dropdown[data-open] {
  transform: scale(1);
  opacity: 1;
  transition: transform 180ms ease-out, opacity 180ms ease-out;
}
```

## Easing Selection

| Use Case | Easing | Why |
|----------|--------|-----|
| **Default (90% of UI)** | `ease-out` | Starts fast, decelerates. Feels responsive |
| Moving on-screen elements | `ease-in-out` | Natural acceleration/deceleration |
| Simple hover (bg color) | `ease` | Acceptable for basic effects |
| **Never use** | `ease-in` | Speeds up at end — wrong for UI |

Built-in CSS easings are often too weak. For custom curves, use [easing.dev](https://easing.dev) or [easings.co](https://easings.co).

## iOS-Style Drawer Curve

For smooth drawer/sheet animations matching iOS feel:

```css
.drawer {
  transition: transform 500ms cubic-bezier(0.32, 0.72, 0, 1);
}
```

This specific curve (`0.32, 0.72, 0, 1`) with 500ms duration mimics native iOS sheets.

## Transform-Origin

**Default `center` is wrong for most UI.** Elements should animate from their trigger point.

```css
/* Dropdown opens below button */
.dropdown {
  transform-origin: top center;
}

/* Dropdown opens above button */
.dropdown[data-position="top"] {
  transform-origin: bottom center;
}

/* Dropdown opens from corner */
.dropdown[data-position="top-right"] {
  transform-origin: top right;
}
```

Set transform-origin based on where the trigger element is located.

## Tooltip Pattern

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

/* After first tooltip opens, subsequent ones: no animation */
.tooltip[data-instant] {
  transition-duration: 0ms;
}
```

Add delay before showing (prevents accidental activation). Once one tooltip is open, others should appear instantly.

## When NOT to Animate

### Keyboard-Initiated Actions
**Never animate keyboard navigation.** Arrow keys, Enter, Tab — these repeat hundreds of times daily. Animation makes them feel delayed.

Command palettes and search interfaces work best with **zero opening animation**.

### High-Frequency Interactions
If users trigger an action hundreds of times daily, animation adds friction, not delight.

### After First Tooltip
Once one tooltip is visible, hovering to another should show it **immediately with no animation**.

## Toast Component

```css
.toast {
  transition: transform 400ms ease-out, opacity 200ms ease-out;
}

/* Stack toasts with offset and scale */
.toast[data-index="0"] { transform: translateY(0) scale(1); }
.toast[data-index="1"] { transform: translateY(-14px) scale(0.95); }
.toast[data-index="2"] { transform: translateY(-28px) scale(0.90); }
```

- Default visibility: **4 seconds**
- Pause timer when browser tab is inactive
- Scale down by **0.05 × index** for depth effect
- Gap of ~14px between stacked toasts

### Swipe Dismiss
Use velocity threshold of **~0.11** — allows short fast swipes to dismiss.

## Performance Rules

**Only animate `transform` and `opacity`** — they use GPU compositing, stay smooth.

Animating these triggers expensive layout/paint:
- `width`, `height`
- `padding`, `margin`
- `top`, `left`, `right`, `bottom`
- `border-width`

```css
/* Bad - triggers layout */
.expand { width: 100px; transition: width 200ms; }
.expand:hover { width: 200px; }

/* Good - GPU accelerated */
.expand { transform: scaleX(1); transition: transform 200ms ease-out; }
.expand:hover { transform: scaleX(2); }
```

## Debugging Tip: Blur Trick

When animation feels off despite tweaking easing/duration, add **2px blur** during transition:

```css
.element {
  transition: transform 200ms ease-out, filter 200ms ease-out;
}
.element[data-transitioning] {
  filter: blur(2px);
}
```

Blurs the visual gap between states, tricks eye into seeing smooth transition.

## Quick Reference

```
Max duration:     < 300ms (rule)
Button press:     scale(0.97), 150ms, ease-out
Tooltip:          scale(0.97), 125ms, ease-out
Modal:            scale(0.93), 200ms, ease-out
Dropdown:         scale(0.93), 180ms, ease-out
Drawer (iOS):     500ms, cubic-bezier(0.32, 0.72, 0, 1)
Toast dismiss:    4 seconds
Default easing:   ease-out
Enter scale:      0.93 (never 0)
Only animate:     transform, opacity
```

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
