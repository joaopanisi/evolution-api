# Dockerfile — Evolution API (Discloud)
FROM node:20-bullseye

# 1) Dependências nativas necessárias no build
#    - git: evita "spawn git ENOENT" no npm install
#    - python3 + build-essential: para libs nativas (ex.: sharp)
#    - ffmpeg: usado pela Evolution para mídia
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      git \
      python3 \
      build-essential \
      ffmpeg \
      ca-certificates && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app

# 2) Manifests primeiro (melhor cache para npm ci)
COPY package*.json ./

# 3) Instalar **somente** deps de produção
RUN npm ci --omit=dev

# 4) Copiar o restante do código
COPY . .

# 5) Prisma + build (usa seu runWithProvider.js para escolher o schema por provider)
RUN npm run db:generate && \
    npm run db:deploy && \
    npm run build

ENV NODE_ENV=production
EXPOSE 8080

# 6) Sobe a app compilada
CMD ["node", "dist/main"]
