# [s3-nfs-container][project]

Mount an S3 bucket as an NFS filesystem so it can be used as a Docker or Docker Compose volume.


## Usage as a Compose volume

The example Compose manifest will start the s3-nfs container on localhost port `2049`.
It will then make the NFS filesystem available to other services by configuring it as a volume.
The `service_healthy` condition ensures that a connection to the bucket is successfully established before the other services will start using it.
Multiple services can use the same volume.


### 1. Create the Compose manifest

```shell
wget -q https://raw.githubusercontent.com/nedix/s3-nfs-container/main/examples/compose.yml
```


### 2. Start the container

```shell
docker compose up -d
```


### 3. List the S3 bucket contents from inside the example container

```shell
docker compose exec example-container ls /data
```


## Usage as a directory mount

The following example mounts a bucket to a local directory named `s3-nfs`.


### 1. Start the container

```shell
docker run \
    --cap-add SYS_ADMIN \
    --device /dev/fuse \
    --name s3-nfs \
    --pull always \
    --rm \
    -e S3_ACCESS_KEY_ID="qux" \
    -e S3_BUCKET="baz" \
    -e S3_ENDPOINT="foo" \
    -e S3_REGION="bar" \
    -e S3_SECRET_ACCESS_KEY="quux" \
    -p 127.0.0.1:2049:2049 \
    nedix/s3-nfs
```


### 2. Create a target directory

```shell
mkdir s3-nfs
```


### 3. Mount the directory

```shell
mount -v -o vers=4 -o port=2049 127.0.0.1:/ ./s3-nfs
```


[project]: https://hub.docker.com/r/nedix/s3-nfs
