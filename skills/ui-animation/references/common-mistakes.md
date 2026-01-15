# Common Animation Mistakes

Anti-patterns to avoid when implementing UI animations.

---

## Critical (Must Fix)

### Missing prefers-reduced-motion

```css
/* WRONG: No fallback */
.element {
  animation: bounce 1s infinite;
}

/* CORRECT: Respect user preference */
@media (prefers-reduced-motion: no-preference) {
  .element {
    animation: bounce 1s infinite;
  }
}
```

### Animating Layout Properties

```jsx
// WRONG: Triggers layout recalc (expensive)
animate={{ width: 200, height: 100 }}

// CORRECT: GPU accelerated
animate={{ scale: 1.2 }}
```

Never animate: `width`, `height`, `padding`, `margin`, `top`, `left`, `right`, `bottom`

Always use: `transform`, `opacity`, `filter`

### Animating from scale(0)

```jsx
// WRONG: Unnatural, appears from nowhere
initial={{ scale: 0 }}
animate={{ scale: 1 }}

// CORRECT: Gentle, natural motion
initial={{ scale: 0.93, opacity: 0 }}
animate={{ scale: 1, opacity: 1 }}
```

### Animating Keyboard Actions

```jsx
// WRONG: Keyboard shortcuts should NEVER animate
onKeyDown={() => {
  animateElement(); // Don't do this
  performAction();
}}

// CORRECT: Immediate response
onKeyDown={() => {
  performAction(); // No animation
}}
```

### High-Frequency Actions with Animation

If users trigger an action 100+ times daily, remove the animation entirely.

---

## Important (Should Fix)

### Exit as Prominent as Enter

```jsx
// WRONG: Same animation for enter and exit
initial={{ opacity: 0, y: 20 }}
exit={{ opacity: 0, y: 20 }}

// CORRECT: Subtler exit
initial={{ opacity: 0, y: 20, filter: "blur(4px)" }}
exit={{ opacity: 0, y: -8, filter: "blur(2px)" }}
```

### Default CSS Easing

```css
/* WRONG: Built-in easing lacks strength */
.element {
  transition: transform 200ms ease;
}

/* CORRECT: Custom curve */
.element {
  transition: transform 200ms cubic-bezier(0.33, 1, 0.68, 1);
}
```

### Wrong Transform-Origin

```css
/* WRONG: Dropdown expands from center */
.dropdown {
  transform-origin: center;
}

/* CORRECT: Expands from trigger */
.dropdown {
  transform-origin: top center;
}
```

### Keyframes for Interruptible Animations

```css
/* WRONG: Can't be interrupted mid-flight */
@keyframes slideIn {
  from { transform: translateY(100%); }
  to { transform: translateY(0); }
}
.toast { animation: slideIn 400ms ease; }

/* CORRECT: Can retarget mid-animation */
.toast {
  transform: translateY(100%);
  transition: transform 400ms ease;
}
.toast.mounted {
  transform: translateY(0);
}
```

### Distance Threshold for Dismissal

```javascript
// WRONG: Requires long drag
if (dragDistance > 100) dismiss();

// CORRECT: Fast short gestures work
const velocity = dragDistance / elapsedTime;
if (velocity > 0.11) dismiss();
```

### CSS Variables for Drag Updates

```javascript
// WRONG: Triggers expensive cascade recalc
element.style.setProperty('--drag-y', `${y}px`);

// CORRECT: Direct style update
element.style.transform = `translateY(${y}px)`;
```

---

## Medium Priority

### Missing Blur in Enter Animations

```jsx
// MISSING BLUR: Less polished
initial={{ opacity: 0, y: 8 }}
animate={{ opacity: 1, y: 0 }}

// WITH BLUR: "Materializing" effect
initial={{ opacity: 0, y: 8, filter: "blur(4px)" }}
animate={{ opacity: 1, y: 0, filter: "blur(0px)" }}
```

### Durations Over 300ms

```jsx
// TOO SLOW: Feels sluggish
transition={{ duration: 0.5 }}

// BETTER: Snappy, responsive
transition={{ duration: 0.2 }}
```

Exception: iOS-style drawers (500ms with specific curve)

### Same Animation Everywhere

Different contexts need different timing:

| Element | Duration |
|---------|----------|
| Tooltip | 125ms |
| Button | 150ms |
| Dropdown | 180ms |
| Modal | 200ms |

### Missing Hover Transitions

```css
/* WRONG: Instant color change */
.button:hover {
  background-color: var(--hover);
}

/* CORRECT: Smooth transition */
.button {
  transition: background-color 100ms ease;
}
.button:hover {
  background-color: var(--hover);
}
```

### will-change Everywhere

```css
/* WRONG: Wastes GPU memory */
* { will-change: transform; }

/* CORRECT: Targeted */
.animated-button { will-change: transform, opacity; }
```

---

## Code Review Red Flags

Watch for these patterns:

```jsx
// 🚩 Animating layout properties
animate={{ width: 200, height: 100, padding: 20 }}

// 🚩 No reduced motion support
.element { animation: bounce 1s infinite; }

// 🚩 scale(0) initial
initial={{ scale: 0 }}

// 🚩 Same enter/exit
initial={{ opacity: 0, y: 20 }}
exit={{ opacity: 0, y: 20 }}

// 🚩 Default easing
transition: transform 200ms ease;

// 🚩 Center transform-origin on dropdown
.dropdown { transform-origin: center; }

// 🚩 Keyframes for user-triggered animations
animation: slideIn 400ms ease;

// 🚩 CSS variables during drag
element.style.setProperty('--drag-y', `${y}px`);

// 🚩 Distance threshold
if (dragDistance > 100) dismiss();

// 🚩 will-change everywhere
* { will-change: transform; }

// 🚩 Over 300ms duration (except drawers)
transition={{ duration: 0.5 }}

// 🚩 Animation on keyboard action
onKeyDown={() => animateElement()}
```

---

## Quick Fixes

| Problem | Fix |
|---------|-----|
| Sluggish feel | Reduce duration to under 300ms |
| Janky animation | Use transform/opacity only |
| Unnatural motion | Start from scale(0.93+), not scale(0) |
| Dropdown feels off | Set transform-origin to trigger edge |
| Exit too prominent | Use smaller translateY, less blur |
| Rapid clicks break | Use transitions, not keyframes |
| Dismissal requires long drag | Use velocity threshold (0.11) |
| Flash before animation | Add animation-fill-mode: backwards |
| Accessibility complaint | Add prefers-reduced-motion support |
