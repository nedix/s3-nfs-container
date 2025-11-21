ARG ALPINE_VERSION=3.22
ARG RCLONE_VERSION=1.72.0
ARG RCLONE_WEBUI_VERSION=2.0.5
ARG S6_OVERLAY_VERSION=3.2.1.0

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

FROM rclone/rclone:${RCLONE_VERSION} AS rclone

FROM base AS rclone-webui

ARG RCLONE_WEBUI_VERSION

WORKDIR /build/rclone-webui

RUN wget -qO- "https://github.com/rclone/rclone-webui-react/releases/download/v${RCLONE_WEBUI_VERSION}/currentbuild.zip" \
    | unzip - \
    && mkdir -p /var/rclone/webgui \
    && mv -T build /var/rclone/webgui

FROM base

RUN apk add \
        fuse3 \
        nfs-utils

COPY --link --from=rclone /usr/local/bin/rclone /usr/bin/
COPY --link --from=rclone-webui /var/rclone/webgui/ /var/rclone/webgui/

COPY /rootfs/ /

ENTRYPOINT ["/entrypoint.sh"]

# NFS
EXPOSE 2049

# Rclone
EXPOSE 5572/tcp

VOLUME /var/rclone

HEALTHCHECK \
    --start-period=15s \
    CMD nc -z 127.0.0.1 2049
