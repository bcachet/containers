FROM ghcr.io/bcachet/containers/dev:latest

RUN sudo dnf install -y \
            go \
        --nodocs --setopt install_weak_deps=False \
    && sudo dnf clean all -y

RUN brew install golangci-lint

RUN go install golang.org/x/tools/gopls@latest && \
    go install github.com/go-delve/delve/cmd/dlv@master && \
    go install go.uber.org/mock/mockgen@latest
