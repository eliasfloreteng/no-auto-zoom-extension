# syntax=docker/dockerfile:1
# No dependencies: Bun serves the static site on its own.
FROM oven/bun:1-alpine
WORKDIR /app
ENV NODE_ENV=production PORT=3000

COPY server.ts ./
COPY site ./site

USER bun
EXPOSE 3000

HEALTHCHECK --interval=30s --timeout=5s --start-period=5s --retries=3 \
  CMD bun -e "fetch('http://localhost:3000/health').then(r=>{if(!r.ok)process.exit(1)}).catch(()=>process.exit(1))"

CMD ["bun", "server.ts"]
