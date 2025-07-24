# Multi-stage build for Outline
# Stage 1: Build dependencies and application
FROM node:18-alpine AS builder

# Set working directory
WORKDIR /opt/outline

# Install build dependencies
RUN apk add --no-cache \
    python3 \
    make \
    g++ \
    libc6-compat \
    vips-dev \
    git

# Copy package files
COPY package*.json ./
COPY yarn.lock ./

# Install dependencies
RUN yarn install --frozen-lockfile --network-timeout 1000000

# Copy source code
COPY . .

# Build the application
RUN yarn build

# Remove dev dependencies to reduce size
RUN yarn install --production --frozen-lockfile && yarn cache clean

# Stage 2: Runtime image
FROM node:18-alpine AS runtime

# Install runtime dependencies
RUN apk add --no-cache \
    vips \
    dumb-init \
    curl \
    ca-certificates

# Create non-root user
RUN addgroup -g 1001 -S outline && \
    adduser -S outline -u 1001 -G outline

# Set working directory
WORKDIR /opt/outline

# Copy built application from builder stage
COPY --from=builder --chown=outline:outline /opt/outline/build ./build
COPY --from=builder --chown=outline:outline /opt/outline/server ./server
COPY --from=builder --chown=outline:outline /opt/outline/shared ./shared
COPY --from=builder --chown=outline:outline /opt/outline/node_modules ./node_modules
COPY --from=builder --chown=outline:outline /opt/outline/public ./public
COPY --from=builder --chown=outline:outline /opt/outline/package.json ./package.json

# Create necessary directories
RUN mkdir -p /opt/outline/logs && \
    chown -R outline:outline /opt/outline

# Switch to non-root user
USER outline

# Health check
HEALTHCHECK --interval=30s --timeout=5s --start-period=60s --retries=3 \
    CMD curl -f http://localhost:${PORT:-3000}/api/auth.info || exit 1

# Expose port
EXPOSE 3000

# Use dumb-init to handle signals properly
ENTRYPOINT ["dumb-init", "--"]

# Start the application
CMD ["node", "server/index.js"]