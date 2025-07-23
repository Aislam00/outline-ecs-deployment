# Dockerfile - CORRECTED VERSION
FROM node:20-slim AS builder

WORKDIR /opt/outline

# Copy package files
COPY package.json yarn.lock ./

# Install dependencies including dev dependencies for build
RUN yarn install --frozen-lockfile

# Copy source code (need all source files)
COPY . .

# Build the application
RUN yarn build

# Production stage  
FROM node:20-slim AS runner

LABEL org.opencontainers.image.source="https://github.com/outline/outline"

ARG APP_PATH=/opt/outline
WORKDIR $APP_PATH

ENV NODE_ENV=production

# Install system dependencies
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        wget \
        ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Copy built application from builder stage
COPY --from=builder $APP_PATH/build ./build
COPY --from=builder $APP_PATH/server ./server
COPY --from=builder $APP_PATH/public ./public
COPY --from=builder $APP_PATH/.sequelizerc ./.sequelizerc
COPY --from=builder $APP_PATH/package.json ./package.json
COPY --from=builder $APP_PATH/node_modules ./node_modules

# Create a non-root user
RUN groupadd --gid 1001 nodejs \
    && useradd --uid 1001 --gid nodejs nodejs \
    && mkdir -p /var/lib/outline/data \
    && chown -R nodejs:nodejs $APP_PATH \
    && chown -R nodejs:nodejs /var/lib/outline

# Switch to non-root user
USER nodejs

# Expose port
EXPOSE 3000

# Health check
HEALTHCHECK --interval=30s --timeout=5s --start-period=60s --retries=3 \
    CMD wget --no-verbose --tries=1 --spider http://localhost:3000/ || exit 1

# Start the application  
CMD ["yarn", "start"]# Dockerfile
# Multi-stage build for production optimization

# Build stage
FROM node:20-slim AS builder

WORKDIR /opt/outline

# Copy package files
COPY package.json yarn.lock ./

# Install dependencies
RUN yarn install --frozen-lockfile --production=false

# Copy source code
COPY . .

# Build the application
RUN yarn build

# Production stage
FROM node:20-slim AS runner

LABEL org.opencontainers.image.source="https://github.com/outline/outline"
LABEL maintainer="outline-ecs-deployment"

ARG APP_PATH=/opt/outline
WORKDIR $APP_PATH

ENV NODE_ENV=production

# Install system dependencies
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        wget \
        ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Copy built application from builder stage
COPY --from=builder $APP_PATH/build ./build
COPY --from=builder $APP_PATH/server ./server
COPY --from=builder $APP_PATH/public ./public
COPY --from=builder $APP_PATH/.sequelizerc ./.sequelizerc
COPY --from=builder $APP_PATH/package.json ./package.json

# Install only production dependencies
COPY package.json yarn.lock ./
RUN yarn install --frozen-lockfile --production=true \
    && yarn cache clean

# Create a non-root user
RUN groupadd --gid 1001 nodejs \
    && useradd --uid 1001 --gid nodejs nodejs \
    && mkdir -p /var/lib/outline/data \
    && chown -R nodejs:nodejs $APP_PATH \
    && chown -R nodejs:nodejs /var/lib/outline

# Switch to non-root user
USER nodejs

# Expose port
EXPOSE 3000

# Health check
HEALTHCHECK --interval=30s --timeout=5s --start-period=60s --retries=3 \
    CMD wget --no-verbose --tries=1 --spider http://localhost:3000/ || exit 1

# Start the application
CMD ["yarn", "start"]
