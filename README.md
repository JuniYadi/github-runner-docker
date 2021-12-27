# github-runner-docker

## Build Image

```
docker build --tag runner-image .
```

## Run Docker

```
docker run \
    --detach \
    --env ORGANIZATION=<YOUR-GITHUB-ORGANIZATION> \
    --env ACCESS_TOKEN=<YOUR-GITHUB-ACCESS-TOKEN> \
    --name runner \
    runner-image
```

## Check Logs

```
docker logs runner -f
```

Reference: https://testdriven.io/blog/github-actions-docker/