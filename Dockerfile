# Dockerfile for Node.js application with multi-stage build
FROM node:20-alpine AS base

# Install dependencies only when needed
WORKDIR /app

# Copy package files
COPY package*.json ./

# Install dependencies
RUN npm ci --only=production && npm cache clean --force

# Build the application (if needed)
COPY . .

RUN addgroup -g 1001 -S nodejs && \
    adduser -S nodejs -u 1001

RUN chown -R nodejs:nodejs /app
USER nodejs

EXPOSE 3000

HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD node -e "require('http').get('http://localhost/health', (res) => { process.exit(res.statusCode === 200 ? 0 : 1) }).on('error',()=> { process.exit(1)})"

# Development stage
FROM base AS development
USER root
RUN npm ci && npm cache clean --force
USER nodejs
CMD ["npm", "run", "dev"]

# Production stage
FROM base AS production
CMD ["npm", "start"]
