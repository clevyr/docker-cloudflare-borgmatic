#syntax=docker/dockerfile:1

FROM --platform=$BUILDPLATFORM tonistiigi/xx:1.6.1 AS xx

FROM --platform=$BUILDPLATFORM golang:1.24.1-alpine AS flarectl
WORKDIR /app

COPY --from=xx / /

ARG CF_REPO=cloudflare/cloudflare-go
ARG CF_VERSION=v0.107.0
RUN <<EOT
  set -eux
  apk add --no-cache git
  git clone -q \
    --config advice.detachedHead=false \
    --branch "$CF_VERSION" \
    --depth 1 \
     "https://github.com/$CF_REPO.git" .
  go mod download
EOT

# Set Golang build envs based on Docker platform string
ARG TARGETPLATFORM
RUN --mount=type=cache,target=/root/.cache \
  CGO_ENABLED=0 xx-go build -ldflags='-w -s' -trimpath ./cmd/flarectl


FROM b3vis/borgmatic:1.8.14
WORKDIR /data

RUN apk add --no-cache jq

COPY --from=flarectl /app/flarectl /usr/local/bin

COPY rootfs/ /
ENTRYPOINT ["sh"]
CMD ["/entrypoint"]
