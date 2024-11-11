FROM ghcr.io/bcachet/containers/dev:latest

RUN sudo dnf install -y \
            go \
        --nodocs --setopt install_weak_deps=False \
    && sudo dnf clean all -y

