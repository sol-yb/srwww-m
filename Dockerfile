FROM node:22.17.1-bookworm-slim

# Environment
ENV NODE_ENV=production \
    NPM_CONFIG_UPDATE_NOTIFIER=false \
    NPM_CONFIG_FUND=false

WORKDIR /app

# Copy manifests and install deps
COPY package.json package-lock.json* ./
RUN npm ci && npm cache clean --force

# Copy source
COPY . /app

# Build TypeScript
RUN npm run build

# Create non-root user
RUN groupadd -r appgroup && \
    useradd -r -g appgroup appuser && \
    chown -R appuser:appgroup /app
USER appuser

# Healthcheck
HEALTHCHECK --interval=30s --timeout=10s --start-period=30s --retries=3 \
    CMD node -e "process.exit(0)"

EXPOSE 3000

# Run compiled app
CMD ["node", "dist/index.js"]
