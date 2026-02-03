# Docker Setup Guide

This guide explains how to run the application using Docker with different configurations for development and production environments.

## Table of Contents

- [Overview](#overview)
- [Prerequisites](#prerequisites)
- [Environment Variables](#environment-variables)
- [Development Setup (with Neon Local)](#development-setup-with-neon-local)
- [Production Setup (with Neon Cloud)](#production-setup-with-neon-cloud)
- [Common Commands](#common-commands)
- [Troubleshooting](#troubleshooting)

## Overview

The application uses different database configurations for development and production:

- **Development**: Uses **Neon Local** via Docker to create ephemeral database branches
- **Production**: Connects directly to **Neon Cloud** database

## Prerequisites

- Docker Desktop installed and running
- Docker Compose (comes with Docker Desktop)
- Neon account with a project created
- Neon API key (for development with Neon Local)

### Get Your Neon Credentials

1. **Neon API Key**: 
   - Go to [Neon Console](https://console.neon.tech)
   - Navigate to Account Settings → API Keys
   - Generate a new API key

2. **Neon Project ID**:
   - Go to your project in Neon Console
   - Navigate to Project Settings → General
   - Copy the Project ID

3. **Production Database URL**:
   - Go to your project in Neon Console
   - Navigate to Dashboard → Connection Details
   - Copy the connection string

## Environment Variables

The application uses different environment files:

### `.env.development` (for local development)

```env
PORT=3000
NODE_ENV=development
log_level=debug

# Database connection to Neon Local proxy
DATABASE_URL=postgres://neon:npg@neon-local:5432/neondb

# JWT Secret (use a different secret in production)
JWT_SECRET=dev_secret_change_in_production

# Arcjet Key (use test key for development)
ARCJET_KEY=ajkey_test_development
```

### `.env.production` (for production)

```env
PORT=3000
NODE_ENV=production
log_level=info

# Database connection to Neon Cloud
DATABASE_URL=postgresql://your_user:your_password@ep-xxx.aws.neon.tech/neondb?sslmode=require

# JWT Secret (use a strong secret in production)
JWT_SECRET=your_production_jwt_secret_here

# Arcjet Key (use production key)
ARCJET_KEY=your_production_arcjet_key_here
```

### Additional Environment Variables for Neon Local

Create a `.env` file in the root directory with your Neon credentials:

```env
# Required for Neon Local (development only)
NEON_API_KEY=your_neon_api_key_here
NEON_PROJECT_ID=your_neon_project_id_here

# Optional: Parent branch for ephemeral branches (defaults to 'main')
PARENT_BRANCH_ID=main

# Optional: Keep branches after container stops (defaults to true for auto-delete)
DELETE_BRANCH=true
```

## Development Setup (with Neon Local)

### How It Works

In development, the application connects to a **Neon Local** proxy that:
- Creates ephemeral database branches automatically when the container starts
- Deletes branches when the container stops (unless configured otherwise)
- Provides a fresh copy of your database for each development session
- Supports Git branch-based database branching

### Step 1: Configure Environment

1. Copy `.env.development` and update if needed (default values work fine)
2. Create a `.env` file with your Neon credentials (see above)

### Step 2: Start Development Environment

```bash
# Start all services (Neon Local + App)
docker-compose -f docker-compose.dev.yml up

# Or run in detached mode
docker-compose -f docker-compose.dev.yml up -d

# View logs
docker-compose -f docker-compose.dev.yml logs -f
```

### Step 3: Access the Application

- Application: http://localhost:3000
- Database: Available at `localhost:5432` (if you need direct access)

### Step 4: Stop Development Environment

```bash
# Stop and remove containers
docker-compose -f docker-compose.dev.yml down

# Stop and remove containers + volumes (clean slate)
docker-compose -f docker-compose.dev.yml down -v
```

### Development Features

#### Hot Reload

The development setup mounts your source code, so changes are reflected immediately:

```yaml
volumes:
  - ./src:/app/src
```

#### Ephemeral Database Branches

Each time you start the development environment:
1. Neon Local creates a new branch from your parent branch (default: `main`)
2. Your app connects to this fresh branch
3. When you stop the containers, the branch is automatically deleted

#### Persistent Branches (Optional)

To keep branches between restarts, set in your `.env`:

```env
DELETE_BRANCH=false
```

This enables Git branch-based database branching, where each Git branch gets its own persistent database branch.

## Production Setup (with Neon Cloud)

### How It Works

In production, the application connects directly to your **Neon Cloud** database without any proxy.

### Step 1: Configure Environment

1. Update `.env.production` with your actual Neon Cloud connection string
2. Set strong secrets for `JWT_SECRET` and production `ARCJET_KEY`

**Important**: Never commit `.env.production` with real secrets to version control!

### Step 2: Build and Run Production Container

```bash
# Build the production image
docker-compose -f docker-compose.prod.yml build

# Start production environment
docker-compose -f docker-compose.prod.yml up -d

# View logs
docker-compose -f docker-compose.prod.yml logs -f
```

### Step 3: Access the Application

- Application: http://localhost:3000

### Step 4: Stop Production Environment

```bash
# Stop containers
docker-compose -f docker-compose.prod.yml down
```

### Production Considerations

1. **Environment Variables**: In production deployments (AWS, Azure, etc.), inject environment variables through your platform's secrets management:
   - AWS: Parameter Store / Secrets Manager
   - Azure: Key Vault
   - Kubernetes: Secrets
   - Docker Swarm: Docker Secrets

2. **Database Migrations**: Run migrations before starting the app:
   ```bash
   docker-compose -f docker-compose.prod.yml run --rm app npm run db:migrate
   ```

3. **Health Checks**: The production setup includes health checks. Monitor container health:
   ```bash
   docker ps
   ```

4. **Scaling**: Use Docker Swarm or Kubernetes for horizontal scaling

## Common Commands

### View Running Containers

```bash
docker ps
```

### View Logs

```bash
# Development
docker-compose -f docker-compose.dev.yml logs -f app
docker-compose -f docker-compose.dev.yml logs -f neon-local

# Production
docker-compose -f docker-compose.prod.yml logs -f app
```

### Rebuild Containers

```bash
# Development
docker-compose -f docker-compose.dev.yml up --build

# Production
docker-compose -f docker-compose.prod.yml up --build
```

### Run Database Migrations

```bash
# Development
docker-compose -f docker-compose.dev.yml exec app npm run db:migrate

# Production
docker-compose -f docker-compose.prod.yml exec app npm run db:migrate
```

### Access Container Shell

```bash
# Development
docker-compose -f docker-compose.dev.yml exec app sh

# Production
docker-compose -f docker-compose.prod.yml exec app sh
```

### Clean Up Everything

```bash
# Remove all containers, networks, volumes
docker-compose -f docker-compose.dev.yml down -v
docker-compose -f docker-compose.prod.yml down -v

# Remove all unused Docker resources
docker system prune -a
```

## Troubleshooting

### Neon Local Connection Issues

**Problem**: App can't connect to Neon Local

**Solutions**:
1. Check Neon Local is healthy:
   ```bash
   docker-compose -f docker-compose.dev.yml ps
   ```

2. Verify environment variables are set:
   ```bash
   docker-compose -f docker-compose.dev.yml exec neon-local env | grep NEON
   ```

3. Check Neon Local logs:
   ```bash
   docker-compose -f docker-compose.dev.yml logs neon-local
   ```

### Invalid Neon Credentials

**Problem**: Neon Local fails to start with authentication errors

**Solutions**:
1. Verify your `NEON_API_KEY` and `NEON_PROJECT_ID` are correct
2. Check your API key has proper permissions in Neon Console
3. Ensure the project exists and is active

### Database Connection Timeout

**Problem**: App times out connecting to database

**Solutions**:
1. Ensure Neon Local is healthy before app starts (handled by `depends_on`)
2. Check network connectivity:
   ```bash
   docker-compose -f docker-compose.dev.yml exec app ping neon-local
   ```

### Port Already in Use

**Problem**: Port 3000 or 5432 is already in use

**Solutions**:
1. Change ports in `docker-compose.*.yml`:
   ```yaml
   ports:
     - '3001:3000'  # Map to different host port
   ```

2. Or stop conflicting services

### Hot Reload Not Working

**Problem**: Code changes don't reflect in development

**Solutions**:
1. Verify volume mounts in `docker-compose.dev.yml`
2. Restart the container:
   ```bash
   docker-compose -f docker-compose.dev.yml restart app
   ```

### Production Database Connection Fails

**Problem**: Can't connect to Neon Cloud in production

**Solutions**:
1. Verify `DATABASE_URL` in `.env.production` is correct
2. Check connection string includes `?sslmode=require`
3. Ensure IP allowlist in Neon Console allows your production IP
4. Test connection string locally:
   ```bash
   docker-compose -f docker-compose.prod.yml exec app node -e "console.log(process.env.DATABASE_URL)"
   ```

### Git Branch Detection Issues (Mac)

**Problem**: Neon Local doesn't detect Git branches on Docker Desktop for Mac

**Solution**:
1. Open Docker Desktop settings
2. Go to General → Choose file sharing implementation
3. Select "gRPC FUSE" instead of "VirtioFS"
4. Restart Docker Desktop

## Architecture Overview

```
Development Environment:
┌─────────────────┐         ┌──────────────────┐
│                 │         │                  │
│  Application    │────────▶│   Neon Local     │
│  Container      │         │   Proxy          │
│                 │         │                  │
└─────────────────┘         └──────────┬───────┘
                                       │
                                       │ Creates ephemeral
                                       │ branches
                                       ▼
                            ┌──────────────────┐
                            │                  │
                            │   Neon Cloud     │
                            │   (Your Project) │
                            │                  │
                            └──────────────────┘

Production Environment:
┌─────────────────┐
│                 │
│  Application    │───────────────────────────▶
│  Container      │   Direct connection
│                 │
└─────────────────┘         ┌──────────────────┐
                            │                  │
                            │   Neon Cloud     │
                            │   (Production)   │
                            │                  │
                            └──────────────────┘
```

## Additional Resources

- [Neon Local Documentation](https://neon.com/docs/local/neon-local)
- [Neon Console](https://console.neon.tech)
- [Docker Compose Documentation](https://docs.docker.com/compose/)

---

**Need Help?** Check the troubleshooting section or review application logs for detailed error messages.
