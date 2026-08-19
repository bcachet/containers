FROM mcr.microsoft.com/devcontainers/base:ubuntu

# Install packages without docs and suggested packages
SHELL ["/bin/bash", "-eou", "pipefail", "-c"]

RUN <<EOH
set -ex -o pipefail
apt-get update
export DEBIAN_FRONTEND=noninteractive
apt-get -y install --no-install-recommends --no-install-suggests \
    direnv \
    eza \
    fd-find \
    fish \
    fzf \
    git-delta \
    jq \
    just \
    ripgrep \
    zoxide
apt-get autoremove -y
apt-get clean -y
rm -rf /var/lib/apt/lists/*
EOH

USER vscode

# Ensure some workdir are set with _vscode_ user
RUN mkdir -p /home/vscode/.m2 /home/vscode/.lein
