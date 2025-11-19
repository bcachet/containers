# FROM docker.io/library/ubuntu:25.04
FROM mcr.microsoft.com/devcontainers/base:ubuntu-24.04

SHELL ["/bin/bash", "-eou", "pipefail", "-c"]

# Install packages without docs and suggested packages
RUN <<EOF
apt-get update
export DEBIAN_FRONTEND=noninteractive
apt-get -y install --no-install-recommends \
    ca-certificates \
    curl \
    git
apt-get autoremove -y
apt-get clean -y
rm -rf /var/lib/apt/lists/*
EOF

# # VSCode user Configuration
# RUN groupadd --gid 1000 vscode && \
#     useradd --uid 1000 --gid 1000 -m vscode && \
#     echo 'vscode ALL=(ALL) NOPASSWD:ALL' >>/etc/sudoers

USER vscode

RUN NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

ENV PATH=$PATH:/home/linuxbrew/.linuxbrew/bin/:/home/vscode/.local/bin

RUN brew install chezmoi

RUN mkdir -p ~/.ssh && ssh-keyscan github.com >> ~/.ssh/known_hosts
RUN --mount=type=ssh,uid=1000,gid=1000 <<EOF
# mkdir -p ~/.local/share/chezmoi && mkdir -p ~/.config/chezmoi
chezmoi init --one-shot --no-tty --no-pager --progress=true git@github.com:bcachet/dotfiles.git
# nvim --headless +q || true
EOF


