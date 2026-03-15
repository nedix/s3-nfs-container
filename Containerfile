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

FROM base AS build-base

RUN dnf install -y \
        wget

FROM build-base AS mountpoint

WORKDIR /build/mountpoint/

ARG MOUNTPOINT_VERSION

RUN dnf install -y \
        fuse \
        fuse-devel \
    && case "$(uname -m)" in \
        aarch64|arm*) \
            MOUNTPOINT_ARCHITECTURE="arm64" \
        ;; x86_64) \
            MOUNTPOINT_ARCHITECTURE="x86_64" \
        ;; *) echo "Unsupported architecture: $(uname -m)"; exit 1; ;; \
    esac \
    && wget -qO mount-s3.rpm "https://s3.amazonaws.com/mountpoint-s3-release/${MOUNTPOINT_VERSION}/${MOUNTPOINT_ARCHITECTURE}/mount-s3-${MOUNTPOINT_VERSION}-${MOUNTPOINT_ARCHITECTURE}.rpm" \
    && wget -qO mount-s3.rpm.asc "https://s3.amazonaws.com/mountpoint-s3-release/${MOUNTPOINT_VERSION}/${MOUNTPOINT_ARCHITECTURE}/mount-s3-${MOUNTPOINT_VERSION}-${MOUNTPOINT_ARCHITECTURE}.rpm.asc" \
    && wget -qO- https://s3.amazonaws.com/mountpoint-s3-release/public_keys/KEYS | gpg --import - \
    && gpg --verify mount-s3.rpm.asc \
    && rpm -i \
        --badreloc \
        --nodigest \
        --nofiledigest \
        --relocate="/=${PWD}/output/" \
        mount-s3.rpm

FROM base

RUN dnf install -y \
        fuse \
        fuse-libs \
        nfs-utils \
    && dnf clean all

COPY --link --from=mountpoint /build/mountpoint/output/ /

COPY /rootfs/ /

ENTRYPOINT ["/entrypoint.sh"]

# NFS
EXPOSE 2049

HEALTHCHECK \
    --start-period=15s \
    CMD nc -z 127.0.0.1 2049
