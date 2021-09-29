FROM golang:alpine as flarectl
RUN go install -ldflags='-w -s' github.com/cloudflare/cloudflare-go/cmd/flarectl@latest

FROM alpine
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
