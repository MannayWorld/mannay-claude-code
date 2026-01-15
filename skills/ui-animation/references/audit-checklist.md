# Animation Audit Checklist

Quick checklist for reviewing animation code.

---

## Philosophy (Check First)

- [ ] **Should this animate at all?** Check interaction frequency
- [ ] **Is this keyboard-initiated?** If yes, don't animate
- [ ] **Does animation serve a purpose?** (feedback, orientation, continuity)
- [ ] **Will this get tiresome after 10+ uses?** Test repeatedly
- [ ] **Is frequency appropriate?** (100s/day = no animation)

---

## Timing & Easing

- [ ] Duration under 300ms (except drawers at 500ms)
- [ ] Custom easing used (not default `ease`)
- [ ] `ease-out` for entering elements
- [ ] `ease-in-out` for moving elements
- [ ] Spring animations for interactive elements
- [ ] Consistent timing across related animations

---

## Enter/Exit Patterns

- [ ] Enter: opacity + translateY + blur combined
- [ ] Exit: **subtler** than enter (smaller values)
- [ ] Scale starts from 0.93+ (never 0)
- [ ] `animation-fill-mode: backwards` for delayed sequences
- [ ] No flash before delayed animations start

---

## Transform-Origin

- [ ] Dropdown: origin at trigger edge (not center)
- [ ] Modal: origin at center
- [ ] Context menu: origin at click point
- [ ] Tooltip: origin at trigger

---

## Interruptibility

- [ ] CSS transitions used (not keyframes) for user-triggered animations
- [ ] State-driven class changes for animation control
- [ ] Velocity-based dismissal (not distance threshold)
- [ ] Test rapid clicks—animations blend smoothly

---

## Performance

- [ ] Only `transform`, `opacity`, `filter` animated
- [ ] No `width`, `height`, `padding`, `margin` animations
- [ ] `will-change` used sparingly and specifically
- [ ] Direct style updates for drag (not CSS variables)
- [ ] Tested on low-end devices

---

## Accessibility

- [ ] `prefers-reduced-motion` respected
- [ ] Alternative animations provided for reduced motion
- [ ] No vestibular triggers (excessive zoom, spin, parallax)
- [ ] Looping animations can be paused
- [ ] Functional animations have non-motion fallbacks

---

## Component-Specific

### Buttons
- [ ] Scale feedback on press (0.97)
- [ ] Hover transition (100-150ms)
- [ ] Loading state with smooth transition

### Tooltips
- [ ] First tooltip: delayed + animated
- [ ] Subsequent tooltips in group: instant
- [ ] Duration 125ms

### Modals
- [ ] Overlay fade (200ms)
- [ ] Content scale from 0.93 + blur
- [ ] Exit subtler than enter

### Dropdowns
- [ ] Transform-origin from trigger edge
- [ ] Scale from 0.93 + blur
- [ ] Duration 180ms

### Toasts
- [ ] Enter via transition (interruptible)
- [ ] 4-second auto-dismiss
- [ ] Pause timer when tab inactive
- [ ] Pause timer on hover
- [ ] Velocity-based swipe dismiss

### Drawers
- [ ] iOS curve: `cubic-bezier(0.32, 0.72, 0, 1)`
- [ ] Duration 500ms
- [ ] Velocity-based dismissal
- [ ] Damping at boundaries

---

## Severity Levels

### Critical (Must Fix)
- [ ] Missing `prefers-reduced-motion` support
- [ ] Animating layout properties (width, height)
- [ ] No exit animations (elements just disappear)
- [ ] Animating keyboard-initiated actions
- [ ] High-frequency actions with animation

### Important (Should Fix)
- [ ] Exit animations as prominent as enter
- [ ] Missing blur in enter animations
- [ ] scale(0) instead of scale(0.93+)
- [ ] Default CSS easing
- [ ] Wrong transform-origin

### Nice to Have
- [ ] Optical alignment refinements
- [ ] Spring animations instead of ease
- [ ] Button scale feedback
- [ ] Tooltip delay pattern
- [ ] Multi-layer shadows instead of borders

---

## Quick Audit Commands

```bash
# Find animations in codebase
grep -r "animate\|transition\|@keyframes\|motion" --include="*.tsx" --include="*.css"

# Find potential issues
grep -r "scale: 0[^.]" --include="*.tsx"     # scale(0) usage
grep -r "ease[^-]" --include="*.css"          # default easing
grep -r "width.*transition" --include="*.css" # layout animation
grep -r "will-change" --include="*.css"       # will-change usage
```

---

## Pass Criteria

**Minimum viable:**
- All Critical items pass
- 80%+ Important items pass
- prefers-reduced-motion works

**High quality:**
- All Critical and Important items pass
- Component-specific checks pass
- Tested on low-end device
- Tested with reduced motion enabled
