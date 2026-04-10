FROM openclaw/openclaw:latest
WORKDIR /app
COPY openclaw-config/config.json /home/node/.openclaw/openclaw.json
ENV NODE_ENV=production
EXPOSE 18789
CMD ["node", "openclaw.mjs", "gateway", "--allow-unconfigured", "--bind", "lan", "--port", "18789"]
