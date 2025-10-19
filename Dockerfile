FROM node:20-bullseye

RUN apt-get update && apt-get install -y --no-install-recommends \
    git python3 build-essential ffmpeg ca-certificates && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY package*.json ./
RUN npm ci --omit=dev
COPY . .
RUN npm run db:generate && npm run db:deploy && npm run build
ENV NODE_ENV=production
EXPOSE 8080
CMD ["node", "dist/main"]
