# syntax = docker/dockerfile:1.1-experimental
# https://docs.docker.com/engine/reference/builder/
# https://docs.docker.com/develop/develop-images/build_enhancements/#new-docker-build-secret-information
# https://github.com/moby/buildkit/blob/master/frontend/dockerfile/docs/experimental.md
# https://hub.docker.com/r/docker/dockerfile/tags

FROM elixir:1.11.2-alpine@sha256:e921c5c58de6c812562e0ab505332c0cf7637ea3f99a36c489d7d3325a0763ba as builder

RUN apk add --no-cache \
    gcc \
    g++ \
    git \
    make \
    musl-dev \
    openssh-client

# Cache-busting variable
ARG HEX_VERSION=0.20.5
RUN mix local.rebar --force && \
    mix local.hex --force

WORKDIR /app
ENV MIX_ENV=prod

################################################
FROM builder as raw-deps
COPY mix.* /app/

RUN mkdir -p -m 0600 ~/.ssh && ssh-keyscan github.com >> ~/.ssh/known_hosts
RUN --mount=type=secret,id=hex-auth,dst=/root/.hex-auth \
    --mount=type=ssh \
    mix deps.get --only prod && \
    rm -rf /root/.hex

################################################
FROM raw-deps as deps
COPY config/config.exs /app/config/config.exs
COPY config/prod.exs /app/config/prod.exs
COPY config/prod.secret.exs /app/config/prod.secret.exs
RUN mix deps.compile 

################################################
FROM node:13.14.0-alpine as frontend-base
WORKDIR /app
RUN npm install -g npm@6.14.4
COPY --from=raw-deps /app/deps/phoenix /deps/phoenix
COPY --from=raw-deps /app/deps/phoenix_html /deps/phoenix_html
COPY --from=raw-deps /app/deps/phoenix_live_view /deps/phoenix_live_view

################################################
FROM frontend-base as frontend
COPY /assets/package*.json /app/
RUN --mount=type=secret,id=npmrc,dst=/app/.npmrc npm install
COPY /assets /app
RUN --mount=type=secret,id=npmrc,dst=/app/.npmrc npm run build


################################################
FROM deps as releaser-base
COPY . /app/
RUN mix compile --force 
COPY --from=frontend /app/public /app/priv/static
COPY --from=frontend /priv/static /app/priv/static
RUN mix phx.digest
COPY rel/config.exs app/rel/config.exs

################################################
FROM releaser-base as releaser-funny-web
RUN mix release --overwrite

################################################
FROM alpine:3.11 as runner-base
RUN apk add --no-cache \
    ncurses \
    ncurses-dev 

################################################
FROM runner-base as actual-runner
COPY  --from=releaser-funny-web /app/_build/prod/rel/demo /app
EXPOSE 80
ENTRYPOINT ["/app/bin/demo"]
CMD ["start"]
