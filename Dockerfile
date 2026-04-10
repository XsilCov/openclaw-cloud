# Stage 1: Build
FROM node:22-bookworm AS build

WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y \
    curl \
    git \
    procps \
    lsof \
    && rm -rf /var/lib/apt/lists/*

# Enable corepack for pnpm
RUN corepack enable && corepack prepare pnpm@latest --activate

# Clone OpenClaw source
RUN git clone https://github.com/openclaw/openclaw.git .

# Install dependencies
RUN pnpm install --frozen-lockfile

# Build - skip a2ui bundle if it fails
RUN pnpm build:docker || \
    (mkdir -p src/canvas-host/a2ui && \
     echo "/* A2UI stub */" > src/canvas-host/a2ui/a2ui.bundle.js && \
     echo "stub" > src/canvas-host/a2ui/.bundle.hash && \
     rm -rf vendor/a2ui apps/shared/OpenClawKit/Tools/CanvasA2UI && \
     pnpm build:docker)

# Stage 2: Runtime
FROM node:22-bookworm-slim

RUN apt-get update && apt-get install -y \
    curl \
    procps \
    git \
    lsof \
    openssl \
    hostname \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copy built application
COPY --from=build /app/dist ./dist
COPY --from=build /app/node_modules ./node_modules
COPY --from=build /app/package.json .
COPY --from=build /app/openclaw.mjs .
COPY --from=build /app/ui ./ui
COPY --from=build /app/extensions ./extensions
COPY --from=build /app/skills ./skills
COPY --from=build /app/docs ./docs
COPY --from=build /app/qa ./qa

# Copy configuration
COPY openclaw-config/config.json /home/node/.openclaw/openclaw.json

# Create directories
RUN mkdir -p /home/node/.openclaw/workspace

EXPOSE 18789

CMD ["node", "dist/index.js", "gateway", "--allow-unconfigured", "--bind", "lan"]
