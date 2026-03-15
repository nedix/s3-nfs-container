#!/usr/bin/env sh

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
#    Bootstrap mountpoint services
# -------------------------------------------------------------------------------
{
    # -------------------------------------------------------------------------------
    #    Create mountpoint-daemon environment
    # -------------------------------------------------------------------------------
    mkdir -p /run/mountpoint-daemon/environment

    echo "$S3_ACCESS_KEY_ID"     > /run/mountpoint-daemon/environment/S3_ACCESS_KEY_ID
    echo "$S3_BUCKET"            > /run/mountpoint-daemon/environment/S3_BUCKET
    echo "$S3_ENDPOINT"          > /run/mountpoint-daemon/environment/S3_ENDPOINT
    echo "$S3_REGION"            > /run/mountpoint-daemon/environment/S3_REGION
    echo "$S3_SECRET_ACCESS_KEY" > /run/mountpoint-daemon/environment/S3_SECRET_ACCESS_KEY
}

# -------------------------------------------------------------------------------
#    Liftoff!
# -------------------------------------------------------------------------------
exec env -i \
    S6_STAGE2_HOOK="/usr/bin/s6-stage2-hook" \
    /init
