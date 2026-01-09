---
description: Set up backend API with Express or Fastify for Vite/CRA projects
model: claude-opus-4-5
---

Create a production-ready backend API server for React projects (Vite/CRA) using Express or Fastify with TypeScript, validation, and error handling.

## API Specification

$ARGUMENTS

## Framework Selection

This command helps set up a **separate backend server** for projects that don't have built-in API routes (Vite, Create React App).

For Next.js projects, use `/api-new` instead (which uses built-in Route Handlers).

## Choose Your Backend Framework

### Option A: Express (Most Popular)
- **Pros**: Largest ecosystem, most tutorials, mature
- **Cons**: Slower than Fastify, more boilerplate
- **Best For**: Standard APIs, teams familiar with Express

### Option B: Fastify (Performance-Focused)
- **Pros**: 2x faster than Express, built-in validation, TypeScript support
- **Cons**: Smaller ecosystem, different patterns
- **Best For**: High-performance APIs, new projects

## Project Structure

```
project-root/
├── frontend/          # Your Vite/CRA project
│   ├── src/
│   ├── package.json
│   └── vite.config.ts
│
├── backend/           # API server
│   ├── src/
│   │   ├── routes/
│   │   │   └── users.ts
│   │   ├── middleware/
│   │   │   ├── auth.ts
│   │   │   ├── errorHandler.ts
│   │   │   └── validation.ts
│   │   ├── services/
│   │   │   └── userService.ts
│   │   ├── types/
│   │   │   └── index.ts
│   │   ├── utils/
│   │   │   └── database.ts
│   │   └── server.ts
│   ├── package.json
│   └── tsconfig.json
│
└── package.json       # Root workspace config (optional)
```

## Express Setup

### 1. **Initialize Backend**

```bash
mkdir backend
cd backend
pnpm init
pnpm install express cors dotenv
pnpm install -D typescript @types/express @types/cors @types/node tsx nodemon
pnpm install zod           # For validation
```

### 2. **TypeScript Configuration**

```json
// backend/tsconfig.json
{
  "compilerOptions": {
    "target": "ES2022",
    "module": "NodeNext",
    "moduleResolution": "NodeNext",
    "outDir": "./dist",
    "rootDir": "./src",
    "strict": true,
    "esModuleInterop": true,
    "skipLibCheck": true,
    "forceConsistentCasingInFileNames": true
  },
  "include": ["src/**/*"],
  "exclude": ["node_modules"]
}
```

### 3. **Main Server File**

```typescript
// backend/src/server.ts
import express, { Request, Response, NextFunction } from 'express'
import cors from 'cors'
import dotenv from 'dotenv'

dotenv.config()

const app = express()
const PORT = process.env.PORT || 3001

// Middleware
app.use(cors({
  origin: process.env.FRONTEND_URL || 'http://localhost:5173',
  credentials: true
}))
app.use(express.json())
app.use(express.urlencoded({ extended: true }))

// Health check
app.get('/health', (req, res) => {
  res.json({ status: 'ok', timestamp: new Date().toISOString() })
})

// Routes
import userRoutes from './routes/users'
app.use('/api/users', userRoutes)

// Error handling
import { errorHandler } from './middleware/errorHandler'
app.use(errorHandler)

// Start server
app.listen(PORT, () => {
  console.log(`🚀 Server running on http://localhost:${PORT}`)
})
```

### 4. **Example Route with Validation**

```typescript
// backend/src/routes/users.ts
import express, { Request, Response } from 'express'
import { z } from 'zod'
import { validate } from '../middleware/validation'

const router = express.Router()

// Validation schema
const createUserSchema = z.object({
  name: z.string().min(2).max(100),
  email: z.string().email(),
  age: z.number().int().min(18).optional(),
})

type CreateUserInput = z.infer<typeof createUserSchema>

// GET /api/users
router.get('/', async (req, res, next) => {
  try {
    // Fetch users from database
    const users = await getUsersFromDB()

    res.json({
      success: true,
      data: users
    })
  } catch (error) {
    next(error)
  }
})

// GET /api/users/:id
router.get('/:id', async (req, res, next) => {
  try {
    const { id } = req.params
    const user = await getUserByIdFromDB(id)

    if (!user) {
      return res.status(404).json({
        success: false,
        error: 'User not found'
      })
    }

    res.json({
      success: true,
      data: user
    })
  } catch (error) {
    next(error)
  }
})

// POST /api/users
router.post('/', validate(createUserSchema), async (req, res, next) => {
  try {
    const data: CreateUserInput = req.body
    const user = await createUserInDB(data)

    res.status(201).json({
      success: true,
      data: user
    })
  } catch (error) {
    next(error)
  }
})

// PUT /api/users/:id
router.put('/:id', validate(createUserSchema), async (req, res, next) => {
  try {
    const { id } = req.params
    const data: CreateUserInput = req.body
    const user = await updateUserInDB(id, data)

    res.json({
      success: true,
      data: user
    })
  } catch (error) {
    next(error)
  }
})

// DELETE /api/users/:id
router.delete('/:id', async (req, res, next) => {
  try {
    const { id } = req.params
    await deleteUserFromDB(id)

    res.status(204).send()
  } catch (error) {
    next(error)
  }
})

export default router
```

### 5. **Validation Middleware**

```typescript
// backend/src/middleware/validation.ts
import { Request, Response, NextFunction } from 'express'
import { z, ZodError } from 'zod'

export function validate(schema: z.ZodSchema) {
  return (req: Request, res: Response, next: NextFunction) => {
    try {
      schema.parse(req.body)
      next()
    } catch (error) {
      if (error instanceof ZodError) {
        return res.status(400).json({
          success: false,
          error: 'Validation error',
          details: error.errors
        })
      }
      next(error)
    }
  }
}
```

### 6. **Error Handler Middleware**

```typescript
// backend/src/middleware/errorHandler.ts
import { Request, Response, NextFunction } from 'express'

export class AppError extends Error {
  constructor(
    public statusCode: number,
    public message: string,
    public isOperational = true
  ) {
    super(message)
    Object.setPrototypeOf(this, AppError.prototype)
  }
}

export function errorHandler(
  err: Error | AppError,
  req: Request,
  res: Response,
  next: NextFunction
) {
  console.error('Error:', err)

  if (err instanceof AppError) {
    return res.status(err.statusCode).json({
      success: false,
      error: err.message
    })
  }

  // Default error
  res.status(500).json({
    success: false,
    error: 'Internal server error'
  })
}
```

### 7. **Package.json Scripts**

```json
// backend/package.json
{
  "name": "backend",
  "scripts": {
    "dev": "nodemon --exec tsx src/server.ts",
    "build": "tsc",
    "start": "node dist/server.js",
    "type-check": "tsc --noEmit"
  }
}
```

## Fastify Setup (Alternative)

### 1. **Install Dependencies**

```bash
pnpm install fastify @fastify/cors dotenv
pnpm install -D typescript @types/node tsx nodemon
pnpm install zod zod-to-json-schema
```

### 2. **Main Server File**

```typescript
// backend/src/server.ts
import Fastify from 'fastify'
import cors from '@fastify/cors'
import dotenv from 'dotenv'

dotenv.config()

const fastify = Fastify({
  logger: true
})

// CORS
fastify.register(cors, {
  origin: process.env.FRONTEND_URL || 'http://localhost:5173',
  credentials: true
})

// Health check
fastify.get('/health', async () => {
  return { status: 'ok', timestamp: new Date().toISOString() }
})

// Routes
import userRoutes from './routes/users'
fastify.register(userRoutes, { prefix: '/api/users' })

// Start server
const start = async () => {
  try {
    const PORT = Number(process.env.PORT) || 3001
    await fastify.listen({ port: PORT, host: '0.0.0.0' })
    console.log(`🚀 Server running on http://localhost:${PORT}`)
  } catch (err) {
    fastify.log.error(err)
    process.exit(1)
  }
}

start()
```

### 3. **Fastify Route Example**

```typescript
// backend/src/routes/users.ts
import { FastifyInstance, FastifyRequest, FastifyReply } from 'fastify'
import { z } from 'zod'
import { zodToJsonSchema } from 'zod-to-json-schema'

const createUserSchema = z.object({
  name: z.string().min(2).max(100),
  email: z.string().email(),
  age: z.number().int().min(18).optional(),
})

type CreateUserInput = z.infer<typeof createUserSchema>

export default async function userRoutes(fastify: FastifyInstance) {
  // GET /api/users
  fastify.get('/', async (request, reply) => {
    const users = await getUsersFromDB()
    return { success: true, data: users }
  })

  // GET /api/users/:id
  fastify.get<{ Params: { id: string } }>(
    '/:id',
    async (request, reply) => {
      const { id } = request.params
      const user = await getUserByIdFromDB(id)

      if (!user) {
        return reply.status(404).send({
          success: false,
          error: 'User not found'
        })
      }

      return { success: true, data: user }
    }
  )

  // POST /api/users
  fastify.post<{ Body: CreateUserInput }>(
    '/',
    {
      schema: {
        body: zodToJsonSchema(createUserSchema)
      }
    },
    async (request, reply) => {
      const data = request.body
      const user = await createUserInDB(data)

      return reply.status(201).send({
        success: true,
        data: user
      })
    }
  )
}
```

## Environment Variables

```env
# backend/.env
PORT=3001
FRONTEND_URL=http://localhost:5173
DATABASE_URL=postgresql://user:password@localhost:5432/db
NODE_ENV=development
```

## Frontend Integration

### 1. **Vite Proxy Configuration**

```typescript
// frontend/vite.config.ts
import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'

export default defineConfig({
  plugins: [react()],
  server: {
    proxy: {
      '/api': {
        target: 'http://localhost:3001',
        changeOrigin: true,
      }
    }
  }
})
```

### 2. **API Client**

```typescript
// frontend/src/lib/api.ts
const API_URL = import.meta.env.VITE_API_URL || 'http://localhost:3001'

export async function apiRequest<T>(
  endpoint: string,
  options?: RequestInit
): Promise<T> {
  const response = await fetch(`${API_URL}${endpoint}`, {
    ...options,
    headers: {
      'Content-Type': 'application/json',
      ...options?.headers,
    },
    credentials: 'include',
  })

  if (!response.ok) {
    const error = await response.json()
    throw new Error(error.error || 'Request failed')
  }

  return response.json()
}

// Usage in components
export const getUsers = () => apiRequest<{ data: User[] }>('/api/users')
export const createUser = (data: CreateUserInput) =>
  apiRequest<{ data: User }>('/api/users', {
    method: 'POST',
    body: JSON.stringify(data),
  })
```

## Production Deployment

### Option A: Monorepo (Vercel, Netlify)
- Frontend: Deploy to Vercel/Netlify
- Backend: Deploy to Railway, Render, or Fly.io
- Separate deployments, connected via API_URL

### Option B: Docker Compose
```yaml
# docker-compose.yml
version: '3.8'
services:
  frontend:
    build: ./frontend
    ports:
      - "5173:5173"
    environment:
      - VITE_API_URL=http://localhost:3001

  backend:
    build: ./backend
    ports:
      - "3001:3001"
    environment:
      - DATABASE_URL=${DATABASE_URL}
```

## Security Best Practices

1. **Authentication**: Use JWT tokens or sessions
2. **Rate Limiting**: Implement with `express-rate-limit` or `@fastify/rate-limit`
3. **Helmet**: Use `helmet` (Express) or `@fastify/helmet` (Fastify)
4. **Input Validation**: Always validate with Zod
5. **CORS**: Configure properly, don't use `*`
6. **Environment Variables**: Never commit .env files
7. **Error Messages**: Don't leak sensitive info in production

## What to Generate

1. **Server Setup** - Express or Fastify with TypeScript
2. **Route Structure** - REST endpoints with validation
3. **Middleware** - Auth, error handling, validation
4. **Type Definitions** - Shared types between frontend/backend
5. **Environment Config** - .env setup
6. **Development Scripts** - pnpm scripts for dev/build
7. **Frontend Integration** - API client and proxy setup

Generate a production-ready backend API server with proper structure, TypeScript, validation, error handling, and security best practices.
