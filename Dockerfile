FROM node:lts-bookworm-slim

RUN install -d -g node -o node /build && \
  npm install pm2 -g
WORKDIR /build

COPY --chown=node:node . .

USER node
RUN npm ci --ignore-scripts && \
  npm run postinstall

# Set some application defaults
ENV NODE_ENV=production \
    OUTPUT=/build/public/guide.xml \
    GZIP=true

EXPOSE 3000
CMD [ "pm2-runtime", "docker/ecosystem.config.js" ]
