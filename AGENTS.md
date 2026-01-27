# AGENTS.md

This file provides guidance to WARP (warp.dev) when working with code in this repository.

## Project Overview
This is a Node.js/Express REST API for an acquisitions system. It uses:
- **Database**: PostgreSQL via Neon serverless, managed with Drizzle ORM
- **Authentication**: JWT tokens with HTTP-only cookies
- **Validation**: Zod schemas
- **Logging**: Winston (logs to `logs/error.log` and `logs/combined.log`)

## Common Commands

### Development
```powershell
npm run dev              # Start dev server with watch mode on port 3000
```

### Code Quality
```powershell
npm run lint             # Check code with ESLint
npm run lint:fix         # Auto-fix ESLint issues
npm run format           # Format code with Prettier
npm run format:check     # Check code formatting
```

### Database Operations
```powershell
npm run db:generate      # Generate Drizzle migrations from schema changes
npm run db:migrate       # Run pending migrations
npm run db:studio        # Open Drizzle Studio for database management
```

## Architecture

### Request Flow
`Route (routes/) → Controller (controllers/) → Service (services/) → Database (models/)`

### Module Structure
The codebase uses package.json import aliases for clean imports:
- `#config/*` - Configuration (database connection, logger)
- `#controllers/*` - Request handlers (validate, call services, return responses)
- `#models/*` - Drizzle ORM schema definitions
- `#routes/*` - Express route definitions
- `#services/*` - Business logic (database operations, password hashing)
- `#utils/*` - Utility functions (JWT, cookies, formatters)
- `#validations/*` - Zod validation schemas
- `#middlewares/*` - Express middlewares (currently empty)

### Entry Point
`src/index.js` → `src/server.js` → `src/app.js`

### Key Patterns
1. **Validation**: Controllers use Zod schemas with `safeParse()` and return formatted errors via `formatValidationErrors()`
2. **Database**: All DB access through Drizzle ORM (`db` from `#config/database.js`)
3. **Error Handling**: Controllers catch errors, log with Winston, and return appropriate HTTP status codes
4. **Authentication**: JWT tokens stored in HTTP-only cookies with 15-minute expiration

### Database Schema
Models are defined in `src/models/*.js` using Drizzle's pgTable. Currently:
- `users` table with id, name, email, password (hashed), role, createdAt, updatedAt

### Environment Variables Required
- `PORT` - Server port (default: 3000)
- `NODE_ENV` - Environment (development/production)
- `LOG_LEVEL` - Winston log level (default: info)
- `DATABASE_URL` - PostgreSQL connection string
- `JWT_SECRET` - Secret for signing JWT tokens

### Code Style
- ESLint enforces: 2-space indent, single quotes, semicolons, unix line endings
- Prettier configured with same settings
- Unused vars allowed if prefixed with `_`
- Arrow functions preferred over function callbacks
