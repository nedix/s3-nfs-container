#!/usr/bin/env sh

: ${BUFFER_SIZE}
: ${CACHE_MAX_AGE}
: ${CACHE_MAX_SIZE}
: ${CACHE_MIN_FREE_SPACE}
: ${CACHE_READ_AHEAD:=0}
: ${CACHE_WRITE_BACK}
: ${DIR_CACHE_TIME:=10}
: ${S3_ACCESS_KEY_ID}
: ${S3_BUCKET}
: ${S3_ENDPOINT}
: ${S3_REGION}
: ${S3_SECRET_ACCESS_KEY}

HOME_DIRECTORY="/${HOME_DIRECTORY#/}"
HOME_DIRECTORY="${HOME_DIRECTORY%/}"
ROOT_DIRECTORY="/${ROOT_DIRECTORY#/}"
ROOT_DIRECTORY="${ROOT_DIRECTORY%/}"

# -------------------------------------------------------------------------------
#    Bootstrap rclone services
# -------------------------------------------------------------------------------
{
    # -------------------------------------------------------------------------------
    #    Create rclone-configure environment
    # -------------------------------------------------------------------------------
    mkdir -p /run/rclone-configure/environment

    echo "$S3_ACCESS_KEY_ID"     > /run/rclone-configure/environment/S3_ACCESS_KEY_ID
    echo "$S3_BUCKET"            > /run/rclone-configure/environment/S3_BUCKET
    echo "$S3_ENDPOINT"          > /run/rclone-configure/environment/S3_ENDPOINT
    echo "$S3_REGION"            > /run/rclone-configure/environment/S3_REGION
    echo "$S3_SECRET_ACCESS_KEY" > /run/rclone-configure/environment/S3_SECRET_ACCESS_KEY

    # -------------------------------------------------------------------------------
    #    Create rclone-mount environment
    # -------------------------------------------------------------------------------
    mkdir -p /run/rclone-mount/environment

    echo "$BUFFER_SIZE"          > /run/rclone-mount/environment/BUFFER_SIZE
    echo "$CACHE_MAX_AGE"        > /run/rclone-mount/environment/CACHE_MAX_AGE
    echo "$CACHE_MAX_SIZE"       > /run/rclone-mount/environment/CACHE_MAX_SIZE
    echo "$CACHE_MIN_FREE_SPACE" > /run/rclone-mount/environment/CACHE_MIN_FREE_SPACE
    echo "$CACHE_READ_AHEAD"     > /run/rclone-mount/environment/CACHE_READ_AHEAD
    echo "$CACHE_WRITE_BACK"     > /run/rclone-mount/environment/CACHE_WRITE_BACK
    echo "$S3_BUCKET"            > /run/rclone-mount/environment/S3_BUCKET

    # -------------------------------------------------------------------------------
    #    Create rclone-refresh environment
    # -------------------------------------------------------------------------------
    mkdir -p /run/rclone-refresh/environment

    echo "$DIR_CACHE_TIME" > /run/rclone-refresh/environment/DIR_CACHE_TIME
}

# -------------------------------------------------------------------------------
#    Liftoff!
# -------------------------------------------------------------------------------
exec env -i \
    S6_STAGE2_HOOK="/usr/bin/s6-stage2-hook" \
    /init
