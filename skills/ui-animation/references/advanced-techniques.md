# Advanced Animation Techniques

Advanced patterns for when basic enter/exit animations aren't enough.

---

## @property (Animate CSS Variables)

By default, CSS custom properties are strings and can't interpolate. The `@property` rule declares types, enabling smooth animation.

### Basic Usage

```css
@property --hue {
  syntax: '<number>';
  initial-value: 0;
  inherits: false;
}

.element {
  background: hsl(var(--hue), 80%, 50%);
  transition: --hue 500ms ease-out;
}

.element:hover {
  --hue: 180;
}
```

### Available Types

| Syntax | Example |
|--------|---------|
| `<number>` | 0, 100, 3.14 |
| `<percentage>` | 0%, 50%, 100% |
| `<length>` | 10px, 2rem |
| `<color>` | red, #fff, hsl() |
| `<angle>` | 45deg, 0.5turn |
| `<time>` | 200ms, 1s |
| `<integer>` | 0, 1, 2 |
| `<transform-list>` | rotate(45deg) |

### Curved Motion Paths

Standard transforms animate in straight lines. With @property, create curves:

```css
@property --x {
  syntax: '<percentage>';
  initial-value: 0%;
  inherits: false;
}

@property --y {
  syntax: '<percentage>';
  initial-value: 0%;
  inherits: false;
}

.ball {
  transform: translateX(var(--x)) translateY(var(--y));
  animation: throw 1s ease-out;
}

@keyframes throw {
  0% { --x: -100%; --y: 0%; }
  50% { --y: -50%; }
  100% { --x: 100%; --y: 0%; }
}
```

The ball arcs through space instead of moving in a straight line.

---

## linear() Function (Pure CSS Springs)

CSS `linear()` enables bounce, elastic, and spring effects without JavaScript.

### Bounce Easing

```css
:root {
  --bounce: linear(
    0, 0.004, 0.016, 0.035, 0.063, 0.098, 0.141 13.6%, 0.25, 0.391, 0.563, 0.765,
    1, 0.891 40.9%, 0.848, 0.813, 0.785, 0.766, 0.754, 0.75, 0.754, 0.766, 0.785,
    0.813, 0.848, 0.891 68.2%, 1 72.7%, 0.973, 0.953, 0.941, 0.938, 0.941, 0.953,
    0.973, 1, 0.988, 0.984, 0.988, 1
  );
}

.bouncy {
  transition: transform 600ms var(--bounce);
}
```

### Generate Custom Curves

Use Jake Archibald's generator: https://linear-easing-generator.netlify.app/

**When to use linear():**
- Playful contexts (kids apps, games)
- Achievement celebrations
- Onboarding moments

**When NOT to use:**
- Professional/enterprise UI
- Frequent interactions
- Productivity tools

---

## layoutId / FLIP Technique

Smooth transitions between completely different components sharing an ID.

### Framer Motion

```jsx
// Card in list
<motion.div layoutId={`card-${id}`} className="card-small">
  <h3>{title}</h3>
</motion.div>

// Same card expanded (different component entirely)
<motion.div layoutId={`card-${id}`} className="card-large">
  <h3>{title}</h3>
  <p>{description}</p>
  <img src={image} />
</motion.div>
```

Framer Motion automatically animates between them using FLIP (First, Last, Inverse, Play).

### Best Practices

1. **Keep layoutId elements outside AnimatePresence** — avoids conflicts with initial/exit animations
2. **Each layoutId must be unique** — no duplicates
3. **Works across routes** — card in list → detail page modal

### Manual FLIP (No Library)

```javascript
function flip(element, getLastState) {
  // First: capture initial state
  const first = element.getBoundingClientRect();

  // Trigger the change
  getLastState();

  // Last: capture final state
  const last = element.getBoundingClientRect();

  // Inverse: calculate difference
  const deltaX = first.left - last.left;
  const deltaY = first.top - last.top;
  const deltaW = first.width / last.width;
  const deltaH = first.height / last.height;

  // Apply inverse transform
  element.style.transform = `translate(${deltaX}px, ${deltaY}px) scale(${deltaW}, ${deltaH})`;

  // Play: animate to final state
  requestAnimationFrame(() => {
    element.style.transition = 'transform 300ms ease-out';
    element.style.transform = '';
  });
}
```

---

## Scroll-Driven Animations

### The Problem

Scroll-driven animations are tied to scroll **speed**. Scroll slowly → animation plays slowly. This feels wrong for most UI.

### Solution: Trigger + Duration Pattern

Use scroll position to **trigger** a traditional duration-based animation:

```css
@property --in-view {
  syntax: '<number>';
  initial-value: 0;
  inherits: false;
}

/* Scroll-driven trigger */
.element {
  animation: detect-in-view linear;
  animation-timeline: view();
  animation-range: entry 0% entry 10%;
}

@keyframes detect-in-view {
  to { --in-view: 1; }
}

/* Style query activates real animation */
@container style(--in-view: 1) {
  .element-content {
    animation: fade-in 400ms ease-out forwards;
  }
}

@keyframes fade-in {
  from { opacity: 0; transform: translateY(20px); }
  to { opacity: 1; transform: translateY(0); }
}
```

### Progressive Enhancement

Always provide fallbacks:

```javascript
if (!CSS.supports('animation-timeline', 'scroll()')) {
  // Fallback: IntersectionObserver
  const observer = new IntersectionObserver((entries) => {
    entries.forEach(entry => {
      if (entry.isIntersecting) {
        entry.target.classList.add('in-view');
      }
    });
  }, { threshold: 0.1 });

  document.querySelectorAll('.animate-on-scroll').forEach(el => {
    observer.observe(el);
  });
}
```

---

## Stagger Techniques

### CSS-Only Stagger

```css
.item {
  --index: 0;
  opacity: 0;
  animation: fade-in 300ms ease-out forwards;
  animation-delay: calc(var(--index) * 50ms);
}

.item:nth-child(1) { --index: 0; }
.item:nth-child(2) { --index: 1; }
.item:nth-child(3) { --index: 2; }
.item:nth-child(4) { --index: 3; }
.item:nth-child(5) { --index: 4; }

@keyframes fade-in {
  to { opacity: 1; }
}
```

### Negative Delays ("Already in Progress")

Make animations appear mid-flight from the start:

```css
.item {
  animation: pulse 2s ease-in-out infinite;
  animation-delay: calc(var(--index) * -0.3s);
}
```

Elements start at different points in the animation cycle.

### animation-fill-mode

Prevent flash before delayed animations:

```css
.item {
  opacity: 0;
  animation: fade-in 300ms ease-out forwards;
  animation-delay: calc(var(--index) * 50ms);
  animation-fill-mode: backwards; /* Holds initial state before delay */
}
```

| Mode | Behavior |
|------|----------|
| `forwards` | Holds final state after animation |
| `backwards` | Holds initial state before delay starts |
| `both` | Both behaviors |

---

## Clip-Path Animations

GPU-accelerated reveals without layout shifts.

### Basic Reveal

```css
.reveal {
  clip-path: inset(0 0 100% 0);
  animation: reveal 800ms cubic-bezier(0.77, 0, 0.175, 1) forwards;
}

@keyframes reveal {
  to { clip-path: inset(0 0 0 0); }
}
```

### Direction Variants

```css
/* From bottom */
.reveal-up { clip-path: inset(100% 0 0 0); }

/* From left */
.reveal-right { clip-path: inset(0 100% 0 0); }

/* From right */
.reveal-left { clip-path: inset(0 0 0 100%); }

/* Circle expand */
.reveal-circle { clip-path: circle(0% at 50% 50%); }

@keyframes reveal-circle {
  to { clip-path: circle(100% at 50% 50%); }
}
```

### Scroll-Driven Clip-Path

```javascript
const clipPathY = useTransform(scrollYProgress, [0, 1], ["100%", "0%"]);
const motionClipPath = useMotionTemplate`inset(0 0 ${clipPathY} 0)`;

return <motion.div style={{ clipPath: motionClipPath }} />;
```

---

## Spring Physics Parameters

Understanding spring physics for natural motion.

| Parameter | Effect | Typical Range |
|-----------|--------|---------------|
| **stiffness** | How quickly spring reaches target | 100-500 |
| **damping** | How quickly oscillations settle | 10-50 |
| **mass** | Weight/momentum of object | 0.5-2 |
| **bounce** | Overshoot amount (Framer Motion) | 0-0.5 |

### Framer Motion Springs

```jsx
// Professional (no overshoot)
transition={{ type: "spring", duration: 0.45, bounce: 0 }}

// Slight bounce
transition={{ type: "spring", stiffness: 300, damping: 20 }}

// Heavy, slow
transition={{ type: "spring", stiffness: 100, damping: 15, mass: 1.5 }}
```

### useSpring for Continuous Values

```javascript
const springConfig = { stiffness: 300, damping: 30 };
const x = useSpring(mouseX, springConfig);
const y = useSpring(mouseY, springConfig);

// Values interpolate smoothly instead of jumping
return <motion.div style={{ x, y }} />;
```

---

## Optical Alignment

When geometric centering looks wrong.

### Buttons with Icons

```css
/* Icon on left: reduce left padding */
.button-with-icon {
  padding: 8px 16px 8px 12px;
}

/* Icon on right: reduce right padding */
.button-icon-right {
  padding: 8px 12px 8px 16px;
}
```

### Play Button

The triangle creates visual weight on the left. Shift right:

```css
.play-icon {
  margin-left: 2px; /* Optical adjustment */
}
```

### The Rule

If it looks wrong despite being mathematically correct, trust your eyes and adjust.

---

## Damping for Natural Boundaries

When dragging past boundaries, reduce movement progressively:

```javascript
function applyDamping(position, boundary, strength = 0.5) {
  if (position > boundary) {
    const overflow = position - boundary;
    return boundary + overflow * strength;
  }
  return position;
}

// Usage during drag
const dampedY = applyDamping(rawY, maxY, 0.3);
element.style.transform = `translateY(${dampedY}px)`;
```

Things in real life slow down before stopping—damping creates this effect.

---

## Multi-Touch Protection

Prevent position jumps from multiple touches:

```javascript
let activePointerId = null;

element.addEventListener('pointerdown', (e) => {
  if (activePointerId !== null) return; // Ignore additional touches
  activePointerId = e.pointerId;
  element.setPointerCapture(e.pointerId);
});

element.addEventListener('pointerup', (e) => {
  if (e.pointerId === activePointerId) {
    activePointerId = null;
  }
});
```

---

## Pointer Capture

Continue tracking drag even when pointer leaves element:

```javascript
element.addEventListener('pointerdown', (e) => {
  element.setPointerCapture(e.pointerId);
});

// pointermove events continue even outside element bounds
element.addEventListener('pointermove', (e) => {
  // Track continues...
});
```

---

## Gradients with oklch

Avoid muddy midpoints in gradients:

```css
/* sRGB: muddy gray in middle */
.gradient-bad {
  background: linear-gradient(blue, red);
}

/* oklch: vibrant throughout */
.gradient-good {
  background: linear-gradient(in oklch, blue, red);
}
```

**Why oklch?** It interpolates through perceptually uniform color space, avoiding the gray zone when blending complementary colors.
