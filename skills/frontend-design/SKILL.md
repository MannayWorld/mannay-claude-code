---
name: frontend-design
description: "Create distinctive, production-grade frontend interfaces with high design quality. Use this skill when the user asks to build web components, pages, or applications. Generates creative, polished code that avoids generic AI aesthetics."
triggers:
  - "build a page"
  - "create a component"
  - "design this UI"
  - "make it look good"
  - "beautiful interface"
  - "landing page"
  - "dashboard UI"
  - "improve the design"
---

# Frontend Design - Distinctive UI Creation

> **Create production-grade interfaces that avoid generic "AI slop" aesthetics. Commit to bold creative choices.**

## The Job

Take frontend requirements and produce visually striking, memorable, production-ready code. Never settle for generic.

---

## Design Thinking (Before Coding)

Before writing any code, establish a **BOLD aesthetic direction**:

### Context Questions
- **Purpose**: What problem does this interface solve? Who uses it?
- **Tone**: Pick an extreme (see palette below)
- **Constraints**: Framework, performance, accessibility requirements
- **Differentiation**: What makes this UNFORGETTABLE?

### Tone Palette (Choose One)
| Tone | Characteristics |
|------|-----------------|
| Brutally Minimal | White space, single accent, stark typography |
| Maximalist Chaos | Layered elements, bold colors, dense information |
| Retro-Futuristic | 80s neon, gradients, glowing effects |
| Organic/Natural | Earthy tones, flowing shapes, texture |
| Luxury/Refined | Gold accents, serif fonts, subtle animations |
| Playful/Toy-like | Bright primaries, rounded shapes, bouncy motion |
| Editorial/Magazine | Grid-based, bold headlines, image-heavy |
| Brutalist/Raw | Exposed structure, monospace, harsh contrast |
| Art Deco | Geometric patterns, gold/black, symmetric |
| Industrial | Metal textures, exposed elements, utilitarian |

**CRITICAL**: Choose a direction and execute with precision. Bold maximalism AND refined minimalism both work—the key is intentionality.

---

## Implementation Standards

### Typography
- **NEVER**: Arial, Inter, Roboto, system fonts
- **DO**: Choose distinctive fonts that match the aesthetic
- **Pair**: Display font (headlines) + body font (readable)
- Use CSS custom properties for consistency

### Color & Theme
- Commit to a cohesive palette using CSS variables
- Dominant color + sharp accent beats timid even distribution
- Consider: `color-mix()`, gradients, transparency layers

### Motion & Animation
- CSS-only when possible (HTML/JS projects)
- Framer Motion for React when available
- Focus on high-impact moments:
  - Page load with staggered reveals (`animation-delay`)
  - Scroll-triggered effects
  - Hover states that surprise
- One orchestrated animation > scattered micro-interactions

### Spatial Composition
- Break the grid deliberately
- Use asymmetry, overlap, diagonal flow
- Generous negative space OR controlled density
- Never center everything

### Visual Details
- **Backgrounds**: Never solid white/gray—add atmosphere
- **Effects**: Gradient meshes, noise textures, layered transparencies
- **Depth**: Dramatic shadows, decorative borders
- **Polish**: Custom cursors, grain overlays, micro-details

---

## Anti-Patterns (NEVER DO)

- Generic fonts (Arial, Inter, system-ui)
- Purple gradients on white (overused AI aesthetic)
- Centered everything with uniform spacing
- Cookie-cutter card layouts
- Predictable button styles (rounded corners, gradient backgrounds)
- "Modern startup" look (Space Grotesk + purple + lots of white space)

---

## Framework Patterns

### React/Next.js
```tsx
// Use CSS modules or Tailwind with custom values
// Prefer composition over complex components
// Add motion with Framer Motion

import { motion } from 'framer-motion';

const staggerContainer = {
  hidden: { opacity: 0 },
  show: {
    opacity: 1,
    transition: { staggerChildren: 0.1 }
  }
};
```

### HTML/CSS
```css
/* Define custom properties for the aesthetic */
:root {
  --color-dominant: #1a1a2e;
  --color-accent: #e94560;
  --font-display: 'Playfair Display', serif;
  --font-body: 'Source Sans Pro', sans-serif;
}

/* Use modern CSS: grid, container queries, color-mix */
```

### Tailwind
```js
// Extend theme with custom values, never use defaults alone
module.exports = {
  theme: {
    extend: {
      fontFamily: {
        display: ['Playfair Display', 'serif'],
      },
      colors: {
        brand: { /* custom palette */ }
      }
    }
  }
}
```

---

## Output Checklist

Before presenting the design:

- [ ] Aesthetic direction is clear and intentional
- [ ] Typography is distinctive (not generic)
- [ ] Color palette is cohesive and memorable
- [ ] Layout has personality (not cookie-cutter)
- [ ] Motion adds delight (not distraction)
- [ ] Code is production-ready and accessible
- [ ] Responsive across breakpoints
- [ ] Performance considered (no massive bundles)

---

## Remember

**Claude is capable of extraordinary creative work.**

Don't hold back. Show what can truly be created when thinking outside the box and committing fully to a distinctive vision.

Every design should be different. Vary themes, fonts, aesthetics. NEVER converge on common safe choices.
