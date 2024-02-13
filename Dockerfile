###################
# DEVELOPMENT
###################
FROM node:20.0.0-slim AS development

WORKDIR /usr/src/app

RUN apt-get update && apt-get -qq install -y --no-install-recommends \
    tzdata \
    tini \
    && rm -rf /var/lib/apt/lists/*

ENV NODE_ENV development

COPY --chown=node:node package*.json ./

RUN npm ci

COPY --chown=node:node . .

USER node


###################
# PRODUCTION BUILD
###################

FROM node:20.0.0-slim As build

WORKDIR /usr/src/app

ENV NODE_ENV production

COPY --chown=node:node package*.json ./

COPY --chown=node:node --from=development /usr/src/app/node_modules ./node_modules

COPY --chown=node:node . .

RUN npm run build

RUN npm ci --omit=dev && npm cache clean --force

USER node


###################
# PRODUCTION
###################

FROM node:20.0.0-slim

WORKDIR /usr/src/app

ENV NODE_ENV production

RUN apt-get update && apt-get -qq install -y --no-install-recommends \
    tzdata \
    tini \
    && rm -rf /var/lib/apt/lists/*

COPY --chown=node:node --from=build /usr/src/app/package.json ./
COPY --chown=node:node --from=build /usr/src/app/node_modules ./node_modules
COPY --chown=node:node --from=build /usr/src/app/dist ./dist

EXPOSE 3000

USER node

ENTRYPOINT ["/usr/bin/tini", "--"]
CMD [ "node", "dist/main.js" ]