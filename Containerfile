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
    fish \
    git-delta \
    jq \
    just \
    lazygit \
    neovim \
    ripgrep \
    starship \
    tree-sitter-cli \
    tmux \
    zoxide
apt-get autoremove -y
apt-get clean -y
rm -rf /var/lib/apt/lists/*
EOH

USER vscode

# Ensure some workdir are set with _vscode_ user
RUN mkdir -p /home/vscode/.m2 /home/vscode/.lein

# Install mise
ENV PATH=/home/vscode/.local/bin:/home/vscode/.local/share/mise/shims:$PATH
ARG CACHEBUST=1
RUN <<EOH
set -ex -o pipefail
gpg --keyserver hkps://keys.openpgp.org --recv-keys 24853EC9F655CE80B48E6C3A8B81C9D17413A06D
curl https://mise.jdx.dev/install.sh.sig | gpg --decrypt > /tmp/install.sh
MISE_QUIET=1 sh /tmp/install.sh
mise --version
EOH

COPY --chown=vscode <<EOH /home/vscode/.bashrc
eval "$(mise activate bash)"
EOH

# Install chezmoi
# Ensure github.com is known
RUN mkdir -p ~/.ssh && ssh-keyscan github.com >> ~/.ssh/known_hosts

RUN --mount=type=ssh,uid=1000,gid=1000 <<EOF
mise use --global chezmoi
chezmoi init --one-shot --ssh bcachet
nvim --headless +q || true
EOF

