## Build dev image

```shell
podman build \
  --ssh default \
  --file Containerfile \
  --tag ghcr.io/bcachet/containers/dev:latest \
  --progress=plain \
  .
```

## devpod

```shell
devpod up \
  --ide none \
  --ssh-config ~/.ssh/devpod/config \
  --devcontainer-path ../bcachet/containers/.devcontainer/devcontainer.json \
  --workspace-env EXOSCALE_ARTIFACTS_USERNAME=$EXOSCALE_ARTIFACTS_USERNAME \
  --workspace-env EXOSCALE_ARTIFACTS_PASSWORD=$EXOSCALE_ARTIFACTS_PASSWORD \
  .
```
