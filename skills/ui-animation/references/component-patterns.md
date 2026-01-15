# Component Animation Patterns

Production-ready vanilla CSS patterns for common UI components.

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

/* Content */
.modal-content {
  position: fixed;
  top: 50%;
  left: 50%;
  transform: translate(-50%, -50%) scale(0.93);
  opacity: 0;
  transition: transform 200ms ease-out, opacity 200ms ease-out;
}
.modal-content[data-open] {
  transform: translate(-50%, -50%) scale(1);
  opacity: 1;
}
```

## Dropdown/Popover

```css
.dropdown {
  position: absolute;
  opacity: 0;
  transform: scale(0.93);
  transform-origin: top center; /* Adjust based on position */
  transition: transform 180ms ease-out, opacity 180ms ease-out;
  pointer-events: none;
}
.dropdown[data-open] {
  opacity: 1;
  transform: scale(1);
  pointer-events: auto;
}

/* Position variants */
.dropdown[data-side="bottom"] { transform-origin: top center; }
.dropdown[data-side="top"] { transform-origin: bottom center; }
.dropdown[data-side="left"] { transform-origin: right center; }
.dropdown[data-side="right"] { transform-origin: left center; }
```

## Tooltip

```css
.tooltip {
  position: absolute;
  opacity: 0;
  transform: scale(0.97);
  transition: transform 125ms ease-out, opacity 125ms ease-out;
  pointer-events: none;
}
.tooltip[data-visible] {
  opacity: 1;
  transform: scale(1);
}

/* Skip animation after first tooltip opens */
[data-tooltip-group="active"] .tooltip {
  transition-duration: 0ms;
}
```

### Tooltip with Delay

```javascript
// Show tooltip after delay
let showTimeout;
element.addEventListener('mouseenter', () => {
  showTimeout = setTimeout(() => {
    tooltip.setAttribute('data-visible', '');
  }, 200); // 200ms delay
});

element.addEventListener('mouseleave', () => {
  clearTimeout(showTimeout);
  tooltip.removeAttribute('data-visible');
});
```

## Button States

```css
.button {
  transition: transform 150ms ease-out, background-color 80ms ease;
}
.button:hover {
  background-color: var(--button-hover);
}
.button:active {
  transform: scale(0.97);
}

/* Disabled state - no transitions */
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
  transition: transform 500ms cubic-bezier(0.32, 0.72, 0, 1),
              border-radius 500ms cubic-bezier(0.32, 0.72, 0, 1);
}
[data-drawer-open] .drawer-background {
  transform: scale(0.95);
  border-radius: 12px;
  overflow: hidden;
}
```

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
  transition: transform 400ms ease-out, opacity 200ms ease-out;
}

/* Stacking effect */
.toast:nth-last-child(1) { transform: translateY(0) scale(1); }
.toast:nth-last-child(2) { transform: translateY(-14px) scale(0.95); opacity: 0.8; }
.toast:nth-last-child(3) { transform: translateY(-28px) scale(0.90); opacity: 0.6; }

/* Enter animation */
.toast[data-entering] {
  transform: translateX(100%);
  opacity: 0;
}

/* Exit animation */
.toast[data-exiting] {
  transform: translateX(100%);
  opacity: 0;
}
```

### Toast Timer (JavaScript)

```javascript
const TOAST_DURATION = 4000; // 4 seconds

function showToast(message) {
  const toast = createToastElement(message);
  container.appendChild(toast);

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
```

## Accordion

```css
.accordion-content {
  display: grid;
  grid-template-rows: 0fr;
  transition: grid-template-rows 300ms ease-out;
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
  transition: opacity 200ms ease-out;
}
.accordion-content[data-open] .accordion-inner {
  opacity: 1;
  transition-delay: 100ms;
}
```

## Tabs

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

/* Active indicator */
.tab-indicator {
  position: absolute;
  bottom: 0;
  height: 2px;
  background: currentColor;
  transition: transform 250ms ease-out, width 250ms ease-out;
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
.skeleton-wrapper[data-loaded] .skeleton {
  opacity: 0;
  transition: opacity 200ms ease-out;
}
.skeleton-wrapper[data-loaded] .content {
  opacity: 1;
  transition: opacity 200ms ease-out 100ms;
}
```

## List Item Animations

```css
/* Enter */
.list-item {
  animation: list-enter 300ms ease-out forwards;
}

@keyframes list-enter {
  from {
    opacity: 0;
    transform: translateY(-8px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

/* Staggered enter */
.list-item:nth-child(1) { animation-delay: 0ms; }
.list-item:nth-child(2) { animation-delay: 50ms; }
.list-item:nth-child(3) { animation-delay: 100ms; }
.list-item:nth-child(4) { animation-delay: 150ms; }
.list-item:nth-child(5) { animation-delay: 200ms; }

/* Exit */
.list-item[data-removing] {
  opacity: 0;
  transform: scale(0.95);
  transition: opacity 150ms ease-out, transform 150ms ease-out;
}
```

## Reduced Motion

Always respect user preferences:

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
