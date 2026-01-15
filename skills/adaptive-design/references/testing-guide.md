# Real Data Testing Guide

Practical approaches to testing designs with realistic data variations.

## Test Data Sets

### Text Content

**Names**
```
Short:      "Li"
Medium:     "Sarah Johnson"
Long:       "Bartholomew Montgomery Witherspoon III"
Unicode:    "François Müller-Østergård"
RTL:        "محمد أحمد"
Mixed:      "José García-López 田中"
```

**Titles/Headlines**
```
Minimal:    "Hi"
Short:      "Quick Update"
Medium:     "Quarterly Performance Review Meeting Notes"
Long:       "Comprehensive Analysis of Q4 2024 Marketing Campaign Performance Metrics and Strategic Recommendations for Improvement"
With breaks: "Multi-line\nTitle Example"
```

**Descriptions**
```
Empty:      ""
Minimal:    "OK"
Single:     "This is a brief description."
Paragraph:  [100-200 words of lorem ipsum or real content]
Multiple:   [500+ words with paragraphs]
With HTML:  "Check <script>alert('xss')</script> handling"
With links: "Visit https://very-long-domain-name.example.com/path/to/resource?query=param"
```

### Numbers

```
Zero:           0
Single digit:   7
Normal:         42
Hundreds:       847
Thousands:      12,847
Large:          1,284,739
Huge:           1,284,739,284
Negative:       -42
Decimal:        3.14159265359
Currency:       $1,234,567.89
Percentage:     99.99%
```

### Lists/Collections

```
Empty:          []
Single:         [1 item]
Few:            [3 items]
Standard:       [10 items]
Many:           [50 items]
Excessive:      [500+ items]
Mixed lengths:  [items with varying content lengths]
```

### Images

```
Missing:        null, undefined, empty string
Broken:         invalid URL, 404
Tiny:           16x16
Small:          100x100
Normal:         400x300
Large:          2000x1500
Huge:           5000x4000
Wrong ratio:    1920x200 (panorama), 200x1920 (tall)
Formats:        jpg, png, gif, webp, svg
Transparent:    PNG with alpha
Animated:       GIF, animated WebP
```

### Dates/Times

```
Past:           1990-01-01
Recent:         Yesterday
Now:            Current timestamp
Future:         Next year
Far future:     2099-12-31
Invalid:        null, "Invalid Date"
Timezones:      UTC, local, +14:00, -12:00
Formats:        ISO, Unix timestamp, locale string
```

## Component Testing Matrix

### Card Component

| Scenario | Title | Image | Description | Actions |
|----------|-------|-------|-------------|---------|
| Complete | 30 chars | Present | 100 chars | 2 buttons |
| Minimal | 2 chars | None | None | None |
| Overflow | 200 chars | Present | 1000 chars | 5 buttons |
| Mixed | Long | Broken | Short | 1 button |
| Empty | Empty | None | Empty | None |

### List/Table

| Scenario | Items | Test For |
|----------|-------|----------|
| Empty | 0 | Empty state display |
| Single | 1 | Singular grammar, no "items" |
| Few | 3 | Normal layout |
| Many | 50 | Scrolling, pagination |
| Excessive | 500 | Performance, virtualization |

### Form Fields

| Scenario | Value | Test For |
|----------|-------|----------|
| Empty | "" | Placeholder, required validation |
| Whitespace | "   " | Trim handling |
| Minimal | "a" | Min length validation |
| Maximal | 1000+ chars | Max length, overflow |
| Special | "<script>" | XSS prevention |
| Unicode | "émojis 🎉" | Character handling |
| Paste | Large clipboard | Paste handling |

## Layout Stress Tests

### Width Variations

Test at these viewport widths:
```
320px   - Small mobile
375px   - Standard mobile
414px   - Large mobile
768px   - Tablet portrait
1024px  - Tablet landscape / small desktop
1280px  - Standard desktop
1440px  - Large desktop
1920px  - Full HD
2560px  - Ultra-wide
```

### Height Variations

```
480px   - Mobile landscape
600px   - Short browser
768px   - Standard
900px   - Tall
1080px  - Full HD
```

### Content-Driven Tests

1. **Shortest content**: All fields at minimum
2. **Longest content**: All fields at maximum
3. **Mixed**: Long title + short description, short title + long description
4. **Asymmetric lists**: Items of varying lengths in same container

## Automated Testing Script

```javascript
// Test data generator
const testData = {
  strings: {
    empty: '',
    short: 'Hi',
    medium: 'This is a medium length string for testing',
    long: 'Lorem ipsum '.repeat(50),
    unicode: 'Ümläüts, 中文, العربية, 🎉🎊🎁',
    xss: '<script>alert("xss")</script>',
  },

  numbers: {
    zero: 0,
    small: 7,
    medium: 847,
    large: 1284739,
    negative: -42,
    decimal: 3.14159,
  },

  arrays: {
    empty: [],
    single: [1],
    few: [1, 2, 3],
    many: Array.from({ length: 50 }, (_, i) => i),
  },

  images: {
    missing: null,
    broken: 'https://example.com/404.jpg',
    valid: 'https://picsum.photos/400/300',
    tiny: 'https://picsum.photos/16/16',
    huge: 'https://picsum.photos/2000/1500',
  },
};

// Run component through all variations
function stressTest(Component, propVariations) {
  const results = [];

  for (const [name, props] of Object.entries(propVariations)) {
    try {
      render(Component, props);
      results.push({ name, status: 'pass' });
    } catch (error) {
      results.push({ name, status: 'fail', error });
    }
  }

  return results;
}
```

## Visual Regression Checklist

For each component, capture screenshots with:

- [ ] Default/happy path data
- [ ] Empty state
- [ ] Minimal content
- [ ] Maximum content
- [ ] Missing optional fields
- [ ] Error state
- [ ] Loading state
- [ ] Hover/focus states
- [ ] At each breakpoint
- [ ] Light and dark mode
- [ ] High contrast mode

## Common Failures to Watch

### Text Overflow
- Truncation without ellipsis
- Text escaping container
- Breaking word boundaries incorrectly
- Tooltip for truncated text missing

### Image Failures
- No fallback for missing images
- Layout shift on load
- Wrong aspect ratio distortion
- No loading placeholder

### Empty States
- "0 items" instead of friendly message
- Broken layout with no content
- No call-to-action to add content
- Undefined/null displayed

### Number Formatting
- No thousands separators
- Wrong decimal places
- Negative numbers unhandled
- Currency symbols missing/wrong

### Responsive Issues
- Horizontal scroll on mobile
- Touch targets too small (<44px)
- Text unreadable at extremes
- Overlapping elements
