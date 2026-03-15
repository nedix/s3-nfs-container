ARG ALPINE_VERSION=3.23
ARG JUICEFS_VERSION=1.3.1
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
        gcc \
        go \
        make

RUN apk add git

FROM build-base AS juicefs

WORKDIR /build/juicefs/

ARG JUICEFS_VERSION

RUN git clone --depth 1 --recursive https://github.com/juicedata/juicefs.git . \
    && git fetch origin tag "v${JUICEFS_VERSION}" \
    && git checkout "tags/v${JUICEFS_VERSION}" \
    && make

FROM base

RUN apk add \
        nfs-utils
#        fuse3 \

COPY --link --from=juicefs /build/juicefs/juicefs /usr/bin/

COPY /rootfs/ /

ENTRYPOINT ["/entrypoint.sh"]

# NFS
EXPOSE 2049

HEALTHCHECK \
    --start-period=15s \
    CMD nc -z 127.0.0.1 2049
