ARG ALPINE_VERSION=3.23
ARG GOOFYS_VERSION=350ff312abaa1abcf21c5a06e143c7edffe9e2f4
ARG S6_OVERLAY_VERSION=3.2.2.0

FROM alpine:${ALPINE_VERSION} AS base

ARG S6_OVERLAY_VERSION

RUN apk add --virtual .build-deps \
        xz \
    && case "$(uname -m)" in \
        aarch64) \
            S6_OVERLAY_ARCHITECTURE="aarch64" \
        ;; arm*) \
            S6_OVERLAY_ARCHITECTURE="arm" \
        ;; x86_64) \
            S6_OVERLAY_ARCHITECTURE="x86_64" \
        ;; *) echo "Unsupported architecture: $(uname -m)"; exit 1; ;; \
    esac \
    && wget -qO- "https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-noarch.tar.xz" \
    | tar -xpJf- -C / \
    && wget -qO- "https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-${S6_OVERLAY_ARCHITECTURE}.tar.xz" \
    | tar -xpJf- -C / \
    && apk del .build-deps

FROM base AS build-base

RUN apk add \
        git \
        go

FROM build-base AS goofys

WORKDIR /build/goofys/

ARG GOOFYS_VERSION

RUN git clone --depth 1 --recursive https://github.com/kahing/goofys.git . \
    && git checkout "$GOOFYS_VERSION" \
    && git submodule update --depth 1 --recursive \
    && GOBIN="${PWD}/output/" go install

FROM base

RUN apk add \
        fuse3 \
        nfs-utils

COPY --link --from=goofys /build/goofys/output/goofys /usr/bin/

COPY /rootfs/ /

ENTRYPOINT ["/entrypoint.sh"]

# NFS
EXPOSE 2049

#HEALTHCHECK \
#    --start-period=15s \
#    CMD nc -z 127.0.0.1 2049
