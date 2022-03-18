ARG GO_VERSION=1

FROM --platform=$BUILDPLATFORM golang:$GO_VERSION-alpine as flarectl
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
    && go install -ldflags='-w -s' github.com/cloudflare/cloudflare-go/cmd/flarectl@latest

FROM alpine:3.15
WORKDIR /data

RUN set -x \
    && apk add --no-cache \
        borgbackup \
        ca-certificates \
        jq \
        openssh-client \
        py3-pip \
        python3 \
    && pip3 install --no-cache-dir borgmatic

COPY --from=flarectl /go/bin /usr/local/bin

COPY rootfs/ /
CMD ["/entrypoint"]
