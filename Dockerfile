#syntax=docker/dockerfile:1.9

FROM --platform=$BUILDPLATFORM golang:1.22-alpine as flarectl
ARG TARGETPLATFORM
# Set Golang build envs based on Docker platform string
RUN <<EOT
  set -eux
  case "$TARGETPLATFORM" in
      'linux/amd64') export GOARCH=amd64 ;;
      'linux/arm/v6') export GOARCH=arm GOARM=6 ;;
      'linux/arm/v7') export GOARCH=arm GOARM=7 ;;
      'linux/arm64') export GOARCH=arm64 ;;
      *) echo "Unsupported target: $TARGETPLATFORM" && exit 1 ;;
  esac
  go install -ldflags='-w -s' -trimpath github.com/cloudflare/cloudflare-go/cmd/flarectl@v0.100.0
EOT

FROM b3vis/borgmatic:1.8.13
WORKDIR /data

RUN apk add --no-cache jq

COPY --from=flarectl /go/bin /usr/local/bin

COPY rootfs/ /
ENTRYPOINT ["sh"]
CMD ["/entrypoint"]
