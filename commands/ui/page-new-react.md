---
description: Create a new React Router page for Vite/CRA projects with TypeScript
model: claude-opus-4-5
---

Generate a new page component for React Router following modern patterns.

## Page Specification

$ARGUMENTS

## Framework Detection

This command is optimized for **Vite** and **Create React App** projects using **React Router**.

For Next.js projects, use `/page-new` instead (which uses Next.js App Router).

## React Router Page Standards

### 1. **Page Component Structure**

```typescript
// src/pages/ExamplePage.tsx
import { useParams, useSearchParams, useNavigate } from 'react-router'
import { useEffect, useState } from 'react'

interface PageData {
  // Define your data types
}

export default function ExamplePage() {
  const [data, setData] = useState<PageData | null>(null)
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState<Error | null>(null)

  useEffect(() => {
    // Fetch data on mount
    fetchData()
  }, [])

  if (loading) return <LoadingState />
  if (error) return <ErrorState error={error} />
  if (!data) return <NotFoundState />

  return (
    <div>
      {/* Page content */}
    </div>
  )
}
```

### 2. **File Organization**

```
src/
├── pages/
│   ├── HomePage.tsx
│   ├── AboutPage.tsx
│   └── [feature]/
│       ├── FeaturePage.tsx
│       ├── FeatureDetailPage.tsx
│       └── components/
│           └── FeatureSpecificComponent.tsx
├── components/       # Shared components
├── layouts/          # Layout components
├── hooks/            # Custom hooks
└── lib/              # Utilities
```

### 3. **Routing Setup**

**React Router v7+ (recommended)**:
```typescript
// app/routes.ts
import { type RouteConfig, route, index, layout } from "@react-router/dev/routes"

export default [
  layout("layouts/MainLayout.tsx", [
    index("pages/HomePage.tsx"),
    route("about", "pages/AboutPage.tsx"),
    route("posts/:id", "pages/PostDetailPage.tsx"),
  ]),
] satisfies RouteConfig
```

**React Router v6**:
```typescript
// app/Router.tsx
import { createBrowserRouter, RouterProvider } from 'react-router-dom'

const router = createBrowserRouter([
  {
    path: '/',
    element: <MainLayout />,
    children: [
      { index: true, element: <HomePage /> },
      { path: 'about', element: <AboutPage /> },
      { path: 'posts/:id', element: <PostDetailPage /> },
    ],
  },
])

export function Router() {
  return <RouterProvider router={router} />
}
```

### 4. **Data Fetching Patterns**

**Option A: useEffect (Traditional)**
```typescript
useEffect(() => {
  let isMounted = true

  const fetchData = async () => {
    try {
      setLoading(true)
      const response = await fetch('/api/data')
      const result = await response.json()

      if (isMounted) {
        setData(result)
      }
    } catch (err) {
      if (isMounted) {
        setError(err as Error)
      }
    } finally {
      if (isMounted) {
        setLoading(false)
      }
    }
  }

  fetchData()

  return () => {
    isMounted = false
  }
}, [])
```

**Option B: React Query (Recommended)**
```typescript
import { useQuery } from '@tanstack/react-query'

export default function ExamplePage() {
  const { data, isLoading, error } = useQuery({
    queryKey: ['example-data'],
    queryFn: () => fetch('/api/data').then(r => r.json()),
  })

  if (isLoading) return <LoadingState />
  if (error) return <ErrorState error={error} />

  return <div>{/* Use data */}</div>
}
```

**Option C: SWR (Alternative)**
```typescript
import useSWR from 'swr'

const fetcher = (url: string) => fetch(url).then(r => r.json())

export default function ExamplePage() {
  const { data, error, isLoading } = useSWR('/api/data', fetcher)

  if (isLoading) return <LoadingState />
  if (error) return <ErrorState error={error} />

  return <div>{/* Use data */}</div>
}
```

### 5. **Dynamic Routes**

```typescript
// pages/PostDetailPage.tsx
import { useParams } from 'react-router'

export default function PostDetailPage() {
  const { id } = useParams<{ id: string }>()

  useEffect(() => {
    fetchPost(id)
  }, [id])

  return <div>Post {id}</div>
}
```

### 6. **Layout Pattern**

```typescript
// layouts/MainLayout.tsx
import { Outlet, Link } from 'react-router'

export default function MainLayout() {
  return (
    <div>
      <nav>
        <Link to="/">Home</Link>
        <Link to="/about">About</Link>
      </nav>

      <main>
        <Outlet /> {/* Child routes render here */}
      </main>

      <footer>
        {/* Footer content */}
      </footer>
    </div>
  )
}
```

### 7. **SEO & Meta Tags**

**Option A: React Helmet (Popular)**
```typescript
import { Helmet } from 'react-helmet-async'

export default function ExamplePage() {
  return (
    <>
      <Helmet>
        <title>Page Title - Site Name</title>
        <meta name="description" content="Page description" />
        <meta property="og:title" content="Page Title" />
        <meta property="og:description" content="Page description" />
      </Helmet>

      <div>{/* Page content */}</div>
    </>
  )
}
```

**Option B: React Router Meta (v7+)**
```typescript
// In routes.ts
export const meta = () => {
  return [
    { title: "Page Title" },
    { name: "description", content: "Page description" },
  ]
}
```

### 8. **Loading States**

```typescript
function LoadingState() {
  return (
    <div className="flex items-center justify-center min-h-screen">
      <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-gray-900" />
      <span className="ml-3">Loading...</span>
    </div>
  )
}
```

### 9. **Error States**

```typescript
interface ErrorStateProps {
  error: Error
}

function ErrorState({ error }: ErrorStateProps) {
  return (
    <div className="flex flex-col items-center justify-center min-h-screen">
      <h1 className="text-2xl font-bold text-red-600">Error</h1>
      <p className="mt-2 text-gray-600">{error.message}</p>
      <button
        onClick={() => window.location.reload()}
        className="mt-4 px-4 py-2 bg-blue-600 text-white rounded"
      >
        Retry
      </button>
    </div>
  )
}
```

### 10. **404 Not Found**

```typescript
// pages/NotFoundPage.tsx
import { Link } from 'react-router'

export default function NotFoundPage() {
  return (
    <div className="flex flex-col items-center justify-center min-h-screen">
      <h1 className="text-6xl font-bold">404</h1>
      <p className="mt-4 text-xl text-gray-600">Page not found</p>
      <Link to="/" className="mt-6 text-blue-600 hover:underline">
        Go back home
      </Link>
    </div>
  )
}
```

## What to Generate

1. **Page Component** - Main page with TypeScript
2. **Data Fetching Logic** - useEffect or React Query pattern
3. **Loading State** - Skeleton or spinner
4. **Error Boundary** - Error handling UI
5. **Type Definitions** - Interfaces for data
6. **Route Configuration** - How to add to routes
7. **Meta Tags** - SEO setup with React Helmet

## Code Quality Standards

**TypeScript**
- Strict typing for all data
- Proper interfaces for API responses
- No `any` types
- Type route parameters

**Performance**
- Lazy load pages: `const Page = lazy(() => import('./pages/Page'))`
- Memoize expensive computations
- Debounce user input
- Optimize re-renders

**Accessibility**
- Semantic HTML
- Focus management on route change
- Skip links for navigation
- ARIA labels where needed

**Best Practices**
- Handle loading states
- Handle error states
- Handle empty states
- Clean up effects
- Prevent memory leaks

## Page Types

**Static Pages**
- About, Contact, Terms
- No dynamic data
- Simple content rendering

**Data-Driven Pages**
- Dashboard, Profile, Settings
- Fetch data on mount
- Handle loading/error states

**Dynamic Route Pages**
- Blog posts, Product details
- Use route parameters
- Fetch based on ID

**Form Pages**
- Login, Signup, Checkout
- Form validation
- Submit handling
- Success/error feedback

## Common Hooks to Use

```typescript
import {
  useParams,        // Get route parameters
  useSearchParams,  // Get/set query strings
  useNavigate,      // Programmatic navigation
  useLocation,      // Current location
  useMatch,         // Check if route matches
  Link,             // Navigation component
  NavLink,          // Active link styling
  Outlet,           // Render child routes
} from 'react-router'
```

## Integration with Vite

**Environment Variables**:
```typescript
const apiUrl = import.meta.env.VITE_API_URL
```

**Assets**:
```typescript
import logo from '@/assets/logo.svg'
```

**Path Aliases** (configure in `vite.config.ts`):
```typescript
import { Component } from '@/components/Component'
import { helper } from '@/lib/helper'
```

Generate production-ready page components following React Router patterns with TypeScript, proper data fetching, loading states, error handling, and accessibility.
