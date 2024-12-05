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
GITHUB_TOKEN=$(gh-token) \
EXOSCALE_ARTIFACTS_USERNAME=$(bw-get --raw "Exoscale maven artifacts" | jq -r .data.username) \
EXOSCALE_ARTIFACTS_PASSWORD=$(bw-get --raw "Exoscale maven artifacts" | jq -r .data.password) \
podman build \
  --ssh default \
  --secret id=github-token,env=GITHUB_TOKEN \
  --secret id=exo-artifacts-user,env=EXOSCALE_ARTIFACTS_USERNAME \
  --secret id=exo-artifacts-pwd,env=EXOSCALE_ARTIFACTS_PASSWORD \
  --file Containerfile.exoscale \
  --tag ghcr.io/bcachet/containers/exoscale:latest \
  --progress=plain \
  .
```
