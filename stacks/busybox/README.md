# Busybox stack

## 1. Change directory to stack

```shell
cd ./stacks/busybox/
```

## 2. Create and configure .env

```shell
test -e .env || cp .env.example .env && nano .env
```

## 3. Run stack

```shell
make setup && make down; make up
```
