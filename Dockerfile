#syntax=docker/dockerfile:1.10

FROM --platform=$BUILDPLATFORM golang:1.23.2-alpine AS flarectl
WORKDIR /app

ARG CF_REPO=cloudflare/cloudflare-go
ARG CF_VERSION=v0.115.0
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
RUN <<EOT
  set -eux
  case "$TARGETPLATFORM" in
      'linux/amd64') export GOARCH=amd64 ;;
      'linux/arm/v6') export GOARCH=arm GOARM=6 ;;
      'linux/arm/v7') export GOARCH=arm GOARM=7 ;;
      'linux/arm64') export GOARCH=arm64 ;;
      *) echo "Unsupported target: $TARGETPLATFORM" && exit 1 ;;
  esac
  go build -ldflags='-w -s' -trimpath ./cmd/flarectl
EOT

FROM b3vis/borgmatic:1.8.14
WORKDIR /data

RUN apk add --no-cache jq

COPY --from=flarectl /app/flarectl /usr/local/bin

COPY rootfs/ /
ENTRYPOINT ["sh"]
CMD ["/entrypoint"]
