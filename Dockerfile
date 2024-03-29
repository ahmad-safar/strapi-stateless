# Install dependencies only when needed
FROM strapi/base:alpine AS deps
WORKDIR /srv/app

COPY . .
RUN yarn install --frozen-lockfile

# Rebuild the source code only when needed
FROM strapi/base:alpine AS builder
WORKDIR /srv/app
ENV NODE_ENV production

COPY . .
COPY --from=deps ./srv/app/node_modules ./node_modules
RUN yarn build && yarn install --production --ignore-scripts --prefer-offline

# Production image, copy all the files and run app
FROM strapi/base:alpine AS runner
RUN mkdir /srv/app && chown 1000:1000 -R /srv/app

WORKDIR /srv/app
ENV NODE_ENV production

COPY --from=builder /srv/app .

VOLUME /srv/app

EXPOSE 1337

CMD ["yarn", "develop"]
