## Build dev image
```shell
podman build \
  --ssh default \
  --file Containerfile.dev \
  --tag ghcr.io/bcachet/containers/dev:latest \
  --progress=plain \
  .
```


## Build exoscale image

```shell
podman build \
  --ssh default \
  --file Containerfile.exo \
  --tag ghcr.io/bcachet/containers/exo:latest \
  --progress=plain \
  .
```
