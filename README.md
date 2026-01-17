## Build dev image

```shell
set GITHUB_TOKEN=$(gh-token)
podman build \
  --ssh default \
  --file Containerfile \
  --tag ghcr.io/bcachet/containers/dev:latest \
  --secret id=github-token,env=GITHUB_TOKEN \
  --progress=plain \
  .
```

## devpod

```shell
devpod up \
  --ide none \
  --ssh-config ~/.ssh/devpod/config \
  --devcontainer-path ../bcachet/containers/.devcontainer/devcontainer.json
  .
```
