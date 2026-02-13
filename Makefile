setup:
	@test -e .env || cp .env.example .env
	@docker build --progress=plain -f Containerfile -t s3-nfs .

destroy:
	-@docker rm -fv s3-nfs

up: NFS_PORT = "2049"
up:
	@docker run \
		--cap-add SYS_ADMIN \
		--device /dev/fuse \
		--env-file .env \
		--name s3-nfs \
		--rm \
		-p 127.0.0.1:$(NFS_PORT):2049 \
		-d \
		s3-nfs
	@docker logs -f s3-nfs

down:
	-@docker stop s3-nfs

shell:
	@docker exec -it s3-nfs /bin/sh

test:
	@$(CURDIR)/tests/index.sh
