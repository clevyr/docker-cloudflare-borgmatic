FROM --platform=$BUILDPLATFORM golang:1.21-alpine as flarectl
ARG TARGETPLATFORM
# Set Golang build envs based on Docker platform string
RUN set -x \
    && case "$TARGETPLATFORM" in \
        'linux/amd64') export GOARCH=amd64 ;; \
        'linux/arm/v6') export GOARCH=arm GOARM=6 ;; \
        'linux/arm/v7') export GOARCH=arm GOARM=7 ;; \
        'linux/arm64') export GOARCH=arm64 ;; \
        *) echo "Unsupported target: $TARGETPLATFORM" && exit 1 ;; \
    esac \
    && go install -ldflags='-w -s' github.com/cloudflare/cloudflare-go/cmd/flarectl@v0.75.0

FROM b3vis/borgmatic:1.8.3
WORKDIR /data

RUN apk add --no-cache jq

COPY --from=flarectl /go/bin /usr/local/bin

COPY rootfs/ /
ENTRYPOINT ["sh"]
CMD ["/entrypoint"]
