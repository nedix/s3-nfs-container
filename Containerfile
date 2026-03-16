ARG ALPINE_VERSION=3.23
ARG S6_OVERLAY_VERSION=3.2.2.0
ARG ZEROFS_VERSION=1.0.6

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
        ca-certificates \
        cargo \
        cmake \
        g++ \
        git \
        linux-headers \
        make \
        openssl-dev \
        pkgconf

FROM build-base AS zerofs

WORKDIR /build/zerofs/

ARG ZEROFS_VERSION

RUN git clone --depth 1 --recursive https://github.com/Barre/ZeroFS . \
    && git fetch origin tag "v${ZEROFS_VERSION}" \
    && git checkout "tags/v${ZEROFS_VERSION}" \
    && (cd zerofs && cargo build --release --target-dir "${PWD}/../output/")

FROM base

RUN apk add \
        fuse3 \
        nfs-utils

RUN apk add nbd-client
RUN apk add e2fsprogs

COPY --link --from=zerofs /build/zerofs/output/release/zerofs /usr/bin/

COPY /rootfs/ /

ENTRYPOINT ["/entrypoint.sh"]

# NFS
EXPOSE 2049

##HEALTHCHECK \
##    --start-period=15s \
##    CMD nc -z 127.0.0.1 2049
