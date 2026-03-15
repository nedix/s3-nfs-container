ARG FEDORA_VERSION=43
ARG MOUNTPOINT_VERSION=1.22.1
ARG S6_OVERLAY_VERSION=3.2.2.0

FROM ghcr.io/nedix/fedora-base-container:${FEDORA_VERSION} AS base

ARG BUILD_DEPENDENCIES=" \
    tar \
    wget \
    xz \
"

ARG S6_OVERLAY_VERSION

RUN dnf makecache --refresh \
    && dnf install -y $BUILD_DEPENDENCIES \
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
    && dnf remove -y $BUILD_DEPENDENCIES

FROM base

RUN dnf install -y \
        nfs-utils \
        s3fs-fuse \
    && dnf clean all

COPY /rootfs/ /

ENTRYPOINT ["/entrypoint.sh"]

# NFS
EXPOSE 2049

HEALTHCHECK \
    --start-period=15s \
    CMD nc -z 127.0.0.1 2049
