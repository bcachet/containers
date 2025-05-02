FROM mcr.microsoft.com/devcontainers/base:ubuntu-24.04

# Install packages without docs and suggested packages
RUN <<EOH
apt-get update
export DEBIAN_FRONTEND=noninteractive
apt-get -y install --no-install-recommends \
    curl \
    git \
    direnv \
    eza \
    fd-find \
    fzf \
    jq \
    just \
    procps \
    ripgrep \
    yq
apt-get autoremove -y
apt-get clean -y
rm -rf /var/lib/apt/lists/*
EOH

# Install starship
RUN curl -fsSL https://starship.rs/install.sh | sh -s -- --yes

USER vscode
