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
#    Bootstrap juicefs services
# -------------------------------------------------------------------------------
{
    # -------------------------------------------------------------------------------
    #    Create juicefs-format environment
    # -------------------------------------------------------------------------------
    mkdir -p /run/juicefs-format/environment

    echo "$S3_ACCESS_KEY_ID"     > /run/juicefs-format/environment/S3_ACCESS_KEY_ID
    echo "$S3_BUCKET"            > /run/juicefs-format/environment/S3_BUCKET
    echo "$S3_ENDPOINT"          > /run/juicefs-format/environment/S3_ENDPOINT
    echo "$S3_REGION"            > /run/juicefs-format/environment/S3_REGION
    echo "$S3_SECRET_ACCESS_KEY" > /run/juicefs-format/environment/S3_SECRET_ACCESS_KEY

    # -------------------------------------------------------------------------------
    #    Create juicefs-mount environment
    # -------------------------------------------------------------------------------
    mkdir -p /run/juicefs-mount/environment

    echo "$S3_BUCKET" > /run/juicefs-mount/environment/S3_BUCKET
}

# -------------------------------------------------------------------------------
#    Liftoff!
# -------------------------------------------------------------------------------
exec env -i \
    S6_STAGE2_HOOK="/usr/bin/s6-stage2-hook" \
    /init
