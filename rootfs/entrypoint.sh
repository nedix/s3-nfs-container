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
#    Bootstrap s3fs services
# -------------------------------------------------------------------------------
{
    # -------------------------------------------------------------------------------
    #    Create s3fs-daemon environment
    # -------------------------------------------------------------------------------
    mkdir -p /run/s3fs-daemon/environment

    echo "$S3_ACCESS_KEY_ID"     > /run/s3fs-daemon/environment/S3_ACCESS_KEY_ID
    echo "$S3_BUCKET"            > /run/s3fs-daemon/environment/S3_BUCKET
    echo "$S3_ENDPOINT"          > /run/s3fs-daemon/environment/S3_ENDPOINT
    echo "$S3_REGION"            > /run/s3fs-daemon/environment/S3_REGION
    echo "$S3_SECRET_ACCESS_KEY" > /run/s3fs-daemon/environment/S3_SECRET_ACCESS_KEY
}

# -------------------------------------------------------------------------------
#    Liftoff!
# -------------------------------------------------------------------------------
exec env -i \
    S6_STAGE2_HOOK="/usr/bin/s6-stage2-hook" \
    /init
