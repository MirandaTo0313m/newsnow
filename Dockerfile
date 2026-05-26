FROM node:20.12.2-alpine AS builder
WORKDIR /usr/src
COPY . .
RUN corepack enable
RUN pnpm install
RUN pnpm run build

FROM node:20.12.2-alpine
WORKDIR /usr/app
COPY --from=builder /usr/src/dist/output ./output
# Changed default port from 4444 to 3000 for local dev consistency
ENV HOST=0.0.0.0 PORT=3000 NODE_ENV=production
EXPOSE $PORT
# Add HEALTHCHECK so Docker knows when the app is ready
# Increased start-period to 20s to give the app more time to initialize
HEALTHCHECK --interval=30s --timeout=5s --start-period=20s --retries=3 \
  CMD wget -qO- http://localhost:$PORT/ || exit 1
CMD ["node", "output/server/index.mjs"]
