# Quick Start Guide

Get your application running with Docker in 5 minutes!

## 🚀 Development Setup (Neon Local)

### Prerequisites
- Docker Desktop running
- Neon account ([sign up free](https://console.neon.tech))

### Steps

1. **Get Neon Credentials**
   ```bash
   # Get your API key from: https://console.neon.tech/app/settings/api-keys
   # Get your Project ID from: Project Settings → General
   ```

2. **Configure Environment**
   ```bash
   # Copy the example file
   cp .env.example .env
   
   # Edit .env and add your credentials:
   # NEON_API_KEY=your_api_key
   # NEON_PROJECT_ID=your_project_id
   ```

3. **Start Development Environment**
   ```bash
   docker-compose -f docker-compose.dev.yml up
   ```

4. **Access Your App**
   - Open http://localhost:3000

That's it! 🎉

### What Just Happened?

- Neon Local created an ephemeral database branch
- Your app is connected to this fresh database
- Changes to your code auto-reload
- When you stop Docker, the branch is automatically cleaned up

### Stop Development
```bash
docker-compose -f docker-compose.dev.yml down
```

---

## 🚢 Production Setup (Neon Cloud)

### Steps

1. **Configure Production Environment**
   ```bash
   # Edit .env.production with your production Neon Cloud URL
   # Get connection string from: Neon Console → Dashboard → Connection Details
   ```

2. **Update Secrets**
   ```env
   DATABASE_URL=postgresql://user:pass@ep-xxx.aws.neon.tech/neondb?sslmode=require
   JWT_SECRET=strong_production_secret
   ARCJET_KEY=production_arcjet_key
   ```

3. **Run Production**
   ```bash
   docker-compose -f docker-compose.prod.yml up -d
   ```

4. **Access Your App**
   - Open http://localhost:3000

---

## 📚 Need More Details?

Check out [DOCKER_README.md](./DOCKER_README.md) for:
- Detailed configuration options
- Troubleshooting guide
- Architecture overview
- Advanced features

---

## ⚡ Common Commands

```bash
# View logs
docker-compose -f docker-compose.dev.yml logs -f

# Rebuild after changes
docker-compose -f docker-compose.dev.yml up --build

# Run migrations
docker-compose -f docker-compose.dev.yml exec app npm run db:migrate

# Access container shell
docker-compose -f docker-compose.dev.yml exec app sh

# Clean everything
docker-compose -f docker-compose.dev.yml down -v
```

---

## 🐛 Troubleshooting

**Can't connect to Neon Local?**
```bash
# Check if Neon Local is healthy
docker-compose -f docker-compose.dev.yml ps

# View Neon Local logs
docker-compose -f docker-compose.dev.yml logs neon-local
```

**Port already in use?**
```bash
# Change port in docker-compose.dev.yml
ports:
  - '3001:3000'  # Use port 3001 instead
```

For more help, see the [full troubleshooting guide](./DOCKER_README.md#troubleshooting).
