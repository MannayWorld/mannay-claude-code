---
description: Create a new React component with TypeScript and modern best practices
model: claude-opus-4-5
---

Generate a new React component following 2025 best practices.

## Component Specification

$ARGUMENTS

## Framework Detection

**IMPORTANT**: First, detect the project framework by checking `package.json`:
- **Next.js**: Has "next" in dependencies → Use Server/Client Component patterns
- **Vite**: Has "vite" or "@vitejs/plugin-react" → Client-side components only
- **Create React App**: Has "react-scripts" → Client-side components only

**File Path Conventions**:
- Next.js: `app/components/` or `components/`
- Vite/CRA: `src/components/`

## Modern React + TypeScript Standards

### 1. **Function Components Only**
- Use function components (not class components)
- React 19 patterns when available
- Server Components (Next.js only) - async components with direct data fetching
- Client Components (all frameworks) - interactive components with hooks

### 2. **TypeScript Best Practices**
- Strict typing (`strict: true`)
- Interface for props
- Proper TypeScript utility types (ComponentProps, ReactNode, etc.)
- NO `any` types
- Explicit return types for complex components

### 3. **Component Patterns**

**Client Components** (interactive, use hooks)
```typescript
// Next.js: Add 'use client' directive at top
'use client' // Only needed in Next.js for interactive components

import { useState } from 'react'

interface Props {
  // typed props
}

export function Component({ }: Props) {
  // implementation
}
```

**Note**: In Vite/CRA, all components are client-side by default (no 'use client' needed).

**Server Components** (Next.js App Router only)
```typescript
// Only available in Next.js - NOT for Vite/CRA
interface Props {
  // typed props
}

export async function Component({ }: Props) {
  const data = await fetch('...').then(r => r.json())
  return <div>{data}</div>
}
```

**Note**: For Vite/CRA, use `useEffect` with `fetch` for data fetching instead.

### 4. **State Management**
- `useState` for local state
- `useReducer` for complex state
- Zustand for global state
- React Context for theme/auth

### 5. **Performance**
- Lazy loading with `React.lazy()`
- Code splitting
- `use memo()` for expensive computations
- `useCallback()` for callback functions

### 6. **Styling Approach** (choose based on project)
- **Tailwind CSS** - Utility-first (recommended)
- **CSS Modules** - Scoped styles
- **Styled Components** - CSS-in-JS

## What to Generate

1. **Component File** - Main component with TypeScript
2. **Props Interface** - Fully typed props
3. **Styles** - Tailwind classes or CSS module
4. **Example Usage** - How to import and use
5. **Storybook Story** (optional) - Component documentation

## Code Quality Standards

**Structure**
-  Feature-based folder organization
-  Co-locate related files
-  Barrel exports (index.ts)
-  Clear file naming conventions

**TypeScript**
-  Explicit prop types via interface
-  Proper generics where needed
-  Utility types (Pick, Omit, Partial)
-  Discriminated unions for variants

**Props**
-  Required vs optional props
-  Default values where appropriate
-  Destructure in function signature
-  Props spread carefully

**Accessibility**
-  Semantic HTML
-  ARIA labels where needed
-  Keyboard navigation
-  Screen reader friendly

**Best Practices**
-  Single Responsibility Principle
-  Composition over inheritance
-  Extract complex logic to hooks
-  Keep components small (<200 lines)

## Component Types to Consider

**Presentational Components**
- Pure UI rendering
- No business logic
- Receive data via props
- Easy to test

**Container Components**
- Data fetching
- Business logic
- State management
- Pass data to presentational components

**Compound Components**
- Related components working together
- Shared context
- Flexible API
- Example: `<Select><Select.Trigger/><Select.Content/></Select>`

## React 19 Features to Use

- **use()** API for reading promises/context (React 19+)
- **useActionState()** for form state (React 19+)
- **useFormStatus()** for form pending state (React 19+)
- **useOptimistic()** for optimistic UI updates (React 19+)
- **Server Actions** for mutations (Next.js only)

**Note**: Check React version in package.json. React 19 features may not be available in older projects.

## Framework-Specific Notes

**For Next.js Projects**:
- Choose between Server and Client Components based on interactivity needs
- Use 'use client' directive for components with hooks, events, or browser APIs
- Server Components are async and can fetch data directly
- Prefer Server Components when possible for better performance

**For Vite/CRA Projects**:
- All components are client-side (no 'use client' directive needed)
- Use `useEffect` for data fetching
- Consider React Query or SWR for data management
- Lazy load with `React.lazy()` for code splitting

Generate production-ready, accessible, and performant React components following modern React patterns adapted to the detected framework.

## Advanced React 18+ Patterns

### 1. Concurrent Features

**useTransition for Non-Urgent Updates**
```typescript
'use client'

import { useState, useTransition } from 'react'

interface SearchProps {
  onSearch: (query: string) => void
}

export function SearchInput({ onSearch }: SearchProps) {
  const [query, setQuery] = useState('')
  const [isPending, startTransition] = useTransition()

  const handleChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const value = e.target.value
    setQuery(value)

    // Mark search as low-priority update
    startTransition(() => {
      onSearch(value)
    })
  }

  return (
    <div>
      <input
        type="text"
        value={query}
        onChange={handleChange}
        placeholder="Search..."
        aria-label="Search input"
      />
      {isPending && <span className="loading">Searching...</span>}
    </div>
  )
}
```

**useDeferredValue for Expensive Computations**
```typescript
'use client'

import { useMemo, useDeferredValue } from 'react'

interface FilteredListProps {
  items: Array<{ id: string; name: string }>
  searchQuery: string
}

export function FilteredList({ items, searchQuery }: FilteredListProps) {
  // Defer the search query to prevent blocking UI
  const deferredQuery = useDeferredValue(searchQuery)

  const filteredItems = useMemo(() => {
    return items.filter(item =>
      item.name.toLowerCase().includes(deferredQuery.toLowerCase())
    )
  }, [items, deferredQuery])

  const isStale = searchQuery !== deferredQuery

  return (
    <div className={isStale ? 'opacity-50' : ''}>
      <ul role="list">
        {filteredItems.map(item => (
          <li key={item.id}>{item.name}</li>
        ))}
      </ul>
    </div>
  )
}
```

**Suspense Boundaries with Fallbacks**
```typescript
import { Suspense } from 'react'

// Server Component (Next.js)
async function DataComponent() {
  const data = await fetch('https://api.example.com/data')
  const result = await data.json()
  return <div>{result.content}</div>
}

export function PageWithSuspense() {
  return (
    <div>
      <h1>My Page</h1>
      <Suspense fallback={<LoadingSkeleton />}>
        <DataComponent />
      </Suspense>
    </div>
  )
}

function LoadingSkeleton() {
  return (
    <div className="animate-pulse">
      <div className="h-4 bg-gray-200 rounded w-3/4 mb-2"></div>
      <div className="h-4 bg-gray-200 rounded w-1/2"></div>
    </div>
  )
}
```

### 2. Error Boundaries

**Class-Based Error Boundary Wrapper**
```typescript
'use client'

import React, { Component, ReactNode } from 'react'

interface Props {
  children: ReactNode
  fallback?: ReactNode
  onError?: (error: Error, errorInfo: React.ErrorInfo) => void
}

interface State {
  hasError: boolean
  error: Error | null
}

export class ErrorBoundary extends Component<Props, State> {
  constructor(props: Props) {
    super(props)
    this.state = { hasError: false, error: null }
  }

  static getDerivedStateFromError(error: Error): State {
    return { hasError: true, error }
  }

  componentDidCatch(error: Error, errorInfo: React.ErrorInfo): void {
    // Log error to monitoring service
    console.error('ErrorBoundary caught:', error, errorInfo)
    this.props.onError?.(error, errorInfo)
  }

  render(): ReactNode {
    if (this.state.hasError) {
      return this.props.fallback || (
        <ErrorFallback
          error={this.state.error}
          resetError={() => this.setState({ hasError: false, error: null })}
        />
      )
    }

    return this.props.children
  }
}
```

### 3. Performance Patterns

**React.memo with Custom Comparison**
```typescript
'use client'

import React, { memo } from 'react'

interface ExpensiveComponentProps {
  data: { id: string; value: number }
  onUpdate: (id: string) => void
}

export const ExpensiveComponent = memo(
  function ExpensiveComponent({ data, onUpdate }: ExpensiveComponentProps) {
    console.log('Rendering ExpensiveComponent')

    return (
      <div>
        <p>{data.value}</p>
        <button onClick={() => onUpdate(data.id)}>Update</button>
      </div>
    )
  },
  (prevProps, nextProps) => {
    // Custom comparison - only re-render if data.value changes
    return prevProps.data.value === nextProps.data.value
  }
)
```

**useMemo for Expensive Calculations**
```typescript
'use client'

import { useMemo } from 'react'

interface DataVisualizationProps {
  data: number[]
  threshold: number
}

export function DataVisualization({ data, threshold }: DataVisualizationProps) {
  const statistics = useMemo(() => {
    console.log('Computing statistics...')

    const sum = data.reduce((acc, val) => acc + val, 0)
    const avg = sum / data.length
    const filtered = data.filter(val => val > threshold)
    const max = Math.max(...data)
    const min = Math.min(...data)

    return { sum, avg, filtered, max, min }
  }, [data, threshold])

  return (
    <div>
      <p>Average: {statistics.avg}</p>
      <p>Max: {statistics.max}</p>
      <p>Min: {statistics.min}</p>
      <p>Above threshold: {statistics.filtered.length}</p>
    </div>
  )
}
```

## Component Reusability Standards

### Target: 80%+ Reusability Across Features

**Atomic Design Principles**
```typescript
// 1. Atoms - Basic building blocks
interface ButtonProps {
  variant?: 'primary' | 'secondary' | 'ghost'
  size?: 'sm' | 'md' | 'lg'
  children: React.ReactNode
  onClick?: () => void
  disabled?: boolean
}

export function Button({
  variant = 'primary',
  size = 'md',
  children,
  ...props
}: ButtonProps) {
  const baseStyles = 'rounded font-medium transition-colors'
  const variantStyles = {
    primary: 'bg-blue-600 text-white hover:bg-blue-700',
    secondary: 'bg-gray-200 text-gray-900 hover:bg-gray-300',
    ghost: 'bg-transparent hover:bg-gray-100'
  }
  const sizeStyles = {
    sm: 'px-3 py-1 text-sm',
    md: 'px-4 py-2 text-base',
    lg: 'px-6 py-3 text-lg'
  }

  return (
    <button
      className={`${baseStyles} ${variantStyles[variant]} ${sizeStyles[size]}`}
      {...props}
    >
      {children}
    </button>
  )
}
```

## Testing Requirements

### 90%+ Test Coverage for Components

**Unit Tests (React Testing Library)**
```typescript
// Button.test.tsx
import { render, screen, fireEvent } from '@testing-library/react'
import { Button } from './Button'

describe('Button', () => {
  it('renders with children', () => {
    render(<Button>Click me</Button>)
    expect(screen.getByRole('button', { name: /click me/i })).toBeInTheDocument()
  })

  it('calls onClick when clicked', () => {
    const handleClick = jest.fn()
    render(<Button onClick={handleClick}>Click me</Button>)

    fireEvent.click(screen.getByRole('button'))
    expect(handleClick).toHaveBeenCalledTimes(1)
  })

  it('is disabled when disabled prop is true', () => {
    render(<Button disabled>Click me</Button>)
    expect(screen.getByRole('button')).toBeDisabled()
  })
})\
```
