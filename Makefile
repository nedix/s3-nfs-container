setup:
	@test -e .env || cp .env.example .env
	@docker build --progress=plain -f Containerfile -t s3-nfs .

destroy:
	-@docker rm -fv s3-nfs

up: NFS_PORT = "2049"
up:
	@docker run --rm -d --name s3-nfs \
        --cap-add SYS_ADMIN \
        --device /dev/fuse \
        --env-file .env \
        -p 127.0.0.1:$(NFS_PORT):2049 \
        s3-nfs
	@docker logs -f s3-nfs

down:
	-@docker stop s3-nfs

shell:
	@docker exec -it s3-nfs /bin/sh

test:
	@$(CURDIR)/tests/index.sh
