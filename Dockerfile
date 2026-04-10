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

# Install dependencies and build
RUN pnpm install --frozen-lockfile
RUN pnpm build:docker

# Stage 2: Runtime
FROM node:22-bookworm-slim

RUN apt-get update && apt-get install -y \
    curl \
    procps \
    git \
    lsof \
    openssl \
    && rm -rf /var/lib/apt/lists/* \
    && useradd -m -s /bin/bash node

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

USER node

EXPOSE 18789

CMD ["node", "dist/index.js", "gateway", "--allow-unconfigured", "--bind", "lan"]
