# Component Animation Patterns

Production-ready patterns for common UI components. All patterns follow the core principles:
- Enter: opacity + translateY + blur
- Exit: **subtler** than enter
- Scale from 0.93+ (never 0)
- Under 300ms (except drawers)

---

## Modal/Dialog

```css
/* Overlay */
.modal-overlay {
  position: fixed;
  inset: 0;
  background: rgba(0, 0, 0, 0.5);
  opacity: 0;
  transition: opacity 200ms ease-out;
}
.modal-overlay[data-open] {
  opacity: 1;
}

/* Content - Enter */
.modal-content {
  position: fixed;
  top: 50%;
  left: 50%;
  transform: translate(-50%, -50%) scale(0.93);
  opacity: 0;
  filter: blur(4px);
  transition:
    transform 200ms ease-out,
    opacity 200ms ease-out,
    filter 200ms ease-out;
}

/* Content - Open */
.modal-content[data-open] {
  transform: translate(-50%, -50%) scale(1);
  opacity: 1;
  filter: blur(0);
}

/* Content - Exit (handled by removing data-open) */
/* Exit is naturally subtler because we're going back to initial state */
```

### With Framer Motion

```jsx
<AnimatePresence>
  {isOpen && (
    <>
      <motion.div
        className="modal-overlay"
        initial={{ opacity: 0 }}
        animate={{ opacity: 1 }}
        exit={{ opacity: 0 }}
        transition={{ duration: 0.2 }}
      />
      <motion.div
        className="modal-content"
        initial={{ opacity: 0, scale: 0.93, filter: "blur(4px)" }}
        animate={{ opacity: 1, scale: 1, filter: "blur(0px)" }}
        exit={{ opacity: 0, scale: 0.97, filter: "blur(2px)" }}
        transition={{ type: "spring", duration: 0.35, bounce: 0 }}
      >
        {children}
      </motion.div>
    </>
  )}
</AnimatePresence>
```

**Note exit**: `scale: 0.97` and `blur: 2px` — subtler than enter.

---

## Dropdown/Popover

```css
.dropdown {
  position: absolute;
  opacity: 0;
  transform: scale(0.93);
  filter: blur(4px);
  transform-origin: top center;
  transition:
    transform 180ms ease-out,
    opacity 180ms ease-out,
    filter 180ms ease-out;
  pointer-events: none;
}

.dropdown[data-open] {
  opacity: 1;
  transform: scale(1);
  filter: blur(0);
  pointer-events: auto;
}

/* Position variants - transform-origin */
.dropdown[data-side="bottom"] { transform-origin: top center; }
.dropdown[data-side="top"] { transform-origin: bottom center; }
.dropdown[data-side="left"] { transform-origin: right center; }
.dropdown[data-side="right"] { transform-origin: left center; }

/* Corner variants */
.dropdown[data-align="start"][data-side="bottom"] { transform-origin: top left; }
.dropdown[data-align="end"][data-side="bottom"] { transform-origin: top right; }
```

---

## Tooltip

```css
.tooltip {
  position: absolute;
  opacity: 0;
  transform: scale(0.97);
  transition:
    transform 125ms ease-out,
    opacity 125ms ease-out;
  pointer-events: none;
}

.tooltip[data-visible] {
  opacity: 1;
  transform: scale(1);
}

/* After first tooltip opens, subsequent ones: instant */
[data-tooltip-group="active"] .tooltip {
  transition-duration: 0ms;
}
```

### Tooltip with Delay (JavaScript)

```javascript
let showTimeout;
let activeGroup = false;

element.addEventListener('mouseenter', () => {
  const delay = activeGroup ? 0 : 200; // No delay if group active

  showTimeout = setTimeout(() => {
    tooltip.setAttribute('data-visible', '');
    activeGroup = true;
  }, delay);
});

element.addEventListener('mouseleave', () => {
  clearTimeout(showTimeout);
  tooltip.removeAttribute('data-visible');

  // Reset group after delay
  setTimeout(() => {
    if (!document.querySelector('[data-visible]')) {
      activeGroup = false;
    }
  }, 300);
});
```

---

## Button States

```css
.button {
  transition:
    transform 150ms ease-out,
    background-color 100ms ease;
}

.button:hover {
  background-color: var(--button-hover);
}

.button:active {
  transform: scale(0.97);
}

/* Disabled - no transitions */
.button:disabled {
  opacity: 0.5;
  pointer-events: none;
}
```

### Button with Loading State

```css
.button {
  position: relative;
}

.button-text {
  transition: opacity 150ms ease-out;
}

.button-spinner {
  position: absolute;
  inset: 0;
  display: flex;
  align-items: center;
  justify-content: center;
  opacity: 0;
  transition: opacity 150ms ease-out;
}

.button[data-loading] .button-text {
  opacity: 0;
}

.button[data-loading] .button-spinner {
  opacity: 1;
}

.button[data-loading] {
  pointer-events: none;
}
```

---

## iOS-Style Drawer/Sheet

```css
.drawer-overlay {
  position: fixed;
  inset: 0;
  background: rgba(0, 0, 0, 0.5);
  opacity: 0;
  transition: opacity 500ms cubic-bezier(0.32, 0.72, 0, 1);
}

.drawer-overlay[data-open] {
  opacity: 1;
}

.drawer-content {
  position: fixed;
  bottom: 0;
  left: 0;
  right: 0;
  background: white;
  border-radius: 12px 12px 0 0;
  transform: translateY(100%);
  transition: transform 500ms cubic-bezier(0.32, 0.72, 0, 1);
}

.drawer-content[data-open] {
  transform: translateY(0);
}
```

### Drawer with Background Scale Effect

```css
.drawer-background {
  transition:
    transform 500ms cubic-bezier(0.32, 0.72, 0, 1),
    border-radius 500ms cubic-bezier(0.32, 0.72, 0, 1);
}

[data-drawer-open] .drawer-background {
  transform: scale(0.95);
  border-radius: 12px;
  overflow: hidden;
}
```

### Velocity-Based Dismissal (JavaScript)

```javascript
let startY = 0;
let startTime = 0;

drawer.addEventListener('pointerdown', (e) => {
  startY = e.clientY;
  startTime = Date.now();
  drawer.setPointerCapture(e.pointerId);
});

drawer.addEventListener('pointermove', (e) => {
  const deltaY = e.clientY - startY;
  if (deltaY > 0) {
    // Direct style update (not CSS variable)
    drawer.style.transform = `translateY(${deltaY}px)`;
  }
});

drawer.addEventListener('pointerup', (e) => {
  const deltaY = e.clientY - startY;
  const elapsed = Date.now() - startTime;
  const velocity = deltaY / elapsed;

  // Velocity threshold (fast short gestures work)
  if (velocity > 0.11 || deltaY > 200) {
    closeDrawer();
  } else {
    // Snap back
    drawer.style.transform = '';
  }
});
```

---

## Toast Stack

```css
.toast-container {
  position: fixed;
  bottom: 24px;
  right: 24px;
  display: flex;
  flex-direction: column-reverse;
  gap: 8px;
}

.toast {
  background: white;
  padding: 16px;
  border-radius: 8px;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);

  /* Use transitions (interruptible), not keyframes */
  transform: translateX(100%);
  opacity: 0;
  transition:
    transform 300ms ease-out,
    opacity 200ms ease-out;
}

.toast[data-visible] {
  transform: translateX(0);
  opacity: 1;
}

/* Stacking effect */
.toast:nth-last-child(1) { transform: translateY(0) scale(1); }
.toast:nth-last-child(2) { transform: translateY(-14px) scale(0.95); opacity: 0.8; }
.toast:nth-last-child(3) { transform: translateY(-28px) scale(0.90); opacity: 0.6; }

/* Exit - subtler */
.toast[data-exiting] {
  transform: translateX(50%);
  opacity: 0;
}
```

### Toast Timer with Tab Visibility

```javascript
const TOAST_DURATION = 4000;

function showToast(message) {
  const toast = createToastElement(message);
  container.appendChild(toast);

  // Trigger enter animation
  requestAnimationFrame(() => {
    toast.setAttribute('data-visible', '');
  });

  let timeRemaining = TOAST_DURATION;
  let startTime = Date.now();
  let timer;

  function startTimer() {
    timer = setTimeout(() => dismissToast(toast), timeRemaining);
    startTime = Date.now();
  }

  function pauseTimer() {
    clearTimeout(timer);
    timeRemaining -= Date.now() - startTime;
  }

  // Pause when tab hidden
  document.addEventListener('visibilitychange', () => {
    if (document.hidden) pauseTimer();
    else startTimer();
  });

  // Pause on hover
  toast.addEventListener('mouseenter', pauseTimer);
  toast.addEventListener('mouseleave', startTimer);

  startTimer();
}

function dismissToast(toast) {
  toast.setAttribute('data-exiting', '');
  toast.addEventListener('transitionend', () => {
    toast.remove();
  }, { once: true });
}
```

---

## Accordion

```css
.accordion-content {
  display: grid;
  grid-template-rows: 0fr;
  transition: grid-template-rows 250ms ease-out;
}

.accordion-content[data-open] {
  grid-template-rows: 1fr;
}

.accordion-inner {
  overflow: hidden;
}
```

### With Content Fade

```css
.accordion-inner {
  overflow: hidden;
  opacity: 0;
  transition: opacity 150ms ease-out;
}

.accordion-content[data-open] .accordion-inner {
  opacity: 1;
  transition-delay: 100ms;
}
```

---

## Tabs with Indicator

```css
.tab-list {
  position: relative;
  display: flex;
  gap: 4px;
}

.tab {
  padding: 8px 16px;
  background: none;
  border: none;
  cursor: pointer;
}

/* Active indicator - animated */
.tab-indicator {
  position: absolute;
  bottom: 0;
  height: 2px;
  background: currentColor;
  transition:
    transform 250ms ease-out,
    width 250ms ease-out;
}
```

### Tab Indicator (JavaScript)

```javascript
function updateIndicator(activeTab) {
  const indicator = document.querySelector('.tab-indicator');
  const rect = activeTab.getBoundingClientRect();
  const containerRect = activeTab.parentElement.getBoundingClientRect();

  indicator.style.width = `${rect.width}px`;
  indicator.style.transform = `translateX(${rect.left - containerRect.left}px)`;
}
```

---

## Icon Swap

```jsx
<AnimatePresence mode="wait">
  {isCopied ? (
    <motion.div
      key="check"
      initial={{ opacity: 0, scale: 0.8, filter: "blur(4px)" }}
      animate={{ opacity: 1, scale: 1, filter: "blur(0px)" }}
      exit={{ opacity: 0, scale: 0.9, filter: "blur(2px)" }}
      transition={{ type: "spring", duration: 0.25, bounce: 0 }}
    >
      <CheckIcon />
    </motion.div>
  ) : (
    <motion.div
      key="copy"
      initial={{ opacity: 0, scale: 0.8, filter: "blur(4px)" }}
      animate={{ opacity: 1, scale: 1, filter: "blur(0px)" }}
      exit={{ opacity: 0, scale: 0.9, filter: "blur(2px)" }}
      transition={{ type: "spring", duration: 0.25, bounce: 0 }}
    >
      <CopyIcon />
    </motion.div>
  )}
</AnimatePresence>
```

---

## Skeleton Loading

```css
.skeleton {
  background: linear-gradient(
    90deg,
    #e0e0e0 0%,
    #f0f0f0 50%,
    #e0e0e0 100%
  );
  background-size: 200% 100%;
  animation: skeleton-shimmer 1.5s ease-in-out infinite;
  border-radius: 4px;
}

@keyframes skeleton-shimmer {
  0% { background-position: 200% 0; }
  100% { background-position: -200% 0; }
}

/* Fade to content */
.skeleton-wrapper .skeleton {
  transition: opacity 200ms ease-out;
}

.skeleton-wrapper[data-loaded] .skeleton {
  opacity: 0;
}

.skeleton-wrapper .content {
  opacity: 0;
  transition: opacity 200ms ease-out 100ms;
}

.skeleton-wrapper[data-loaded] .content {
  opacity: 1;
}
```

---

## List Item Animations

```css
/* Enter - staggered */
.list-item {
  opacity: 0;
  transform: translateY(-8px);
  animation: list-enter 250ms ease-out forwards;
}

@keyframes list-enter {
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

/* Stagger delays */
.list-item:nth-child(1) { animation-delay: 0ms; }
.list-item:nth-child(2) { animation-delay: 30ms; }
.list-item:nth-child(3) { animation-delay: 60ms; }
.list-item:nth-child(4) { animation-delay: 90ms; }
.list-item:nth-child(5) { animation-delay: 120ms; }

/* Exit - uses transitions for interruptibility */
.list-item[data-removing] {
  opacity: 0;
  transform: scale(0.97);
  transition:
    opacity 150ms ease-out,
    transform 150ms ease-out;
}
```

---

## Reduced Motion

Always provide fallbacks:

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
    /* Fade only, no scale or blur */
    transform: translate(-50%, -50%);
    filter: none;
    transition: opacity 200ms ease-out;
  }

  .dropdown {
    transform: none;
    filter: none;
    transition: opacity 150ms ease-out;
  }
}
```

---

## Shadows vs Borders

For cards on varied backgrounds, use shadows (adapt via transparency):

```css
.card {
  /* Multi-layer shadow for depth */
  box-shadow:
    0px 0px 0px 1px rgba(0, 0, 0, 0.06),
    0px 1px 2px -1px rgba(0, 0, 0, 0.06),
    0px 2px 4px 0px rgba(0, 0, 0, 0.04);
  transition: box-shadow 150ms ease-out;
}

.card:hover {
  box-shadow:
    0px 0px 0px 1px rgba(0, 0, 0, 0.08),
    0px 1px 2px -1px rgba(0, 0, 0, 0.08),
    0px 2px 4px 0px rgba(0, 0, 0, 0.06);
}
```

**Why shadows over borders?**
- Adapt to any background via transparency
- Multi-layer creates depth
- Smooth transitions
