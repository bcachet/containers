FROM docker.io/library/buildpack-deps:testing-curl

# Install packages without docs and suggested packages
SHELL ["/bin/bash", "-eou", "pipefail", "-c"]

RUN <<EOH
set -ex -o pipefail
apt-get update
export DEBIAN_FRONTEND=noninteractive
apt-get -y install --no-install-recommends --no-install-suggests \
    git \
    fish \
    apt-utils \
    bash-completion \
    openssh-client \
    gnupg2 \
    dirmngr \
    iproute2 \
    procps \
    lsof \
    htop \
    net-tools \
    psmisc \
    tree \
    wget \
    rsync \
    ca-certificates \
    unzip \
    bzip2 \
    xz-utils \
    zip \
    nano \
    vim-tiny \
    less \
    lsb-release \
    apt-transport-https \
    dialog \
    libatomic1 \
    libc6 \
    libgcc1 \
    libkrb5-3 \
    libgssapi-krb5-2 \
    libicu[0-9][0-9] \
    liblttng-ust[0-9] \
    libstdc++6 \
    zlib1g \
    locales \
    sudo \
    ncdu \
    man-db \
    strace \
    manpages \
    manpages-dev \
    init-system-helpers
apt-get autoremove -y
apt-get clean -y
rm -rf /var/lib/apt/lists/*
EOH

ARG USERNAME=vscode
ARG USER_UID=1000
ARG USER_GID=$USER_UID
RUN <<EOF
groupadd --gid $USER_GID $USERNAME
useradd -s /bin/bash --uid $USER_UID --gid $USERNAME -m $USERNAME
echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME
chmod 0440 /etc/sudoers.d/$USERNAME
EOF

USER vscode

# Install mise
RUN <<EOH
set -ex -o pipefail
curl -sSfL https://mise.run | MISE_QUIET=1 sh
EOH

COPY --chown=vscode <<EOH /home/vscode/.bashrc
eval "$(mise activate bash)"
EOH

ENV PATH=/home/vscode/.local/bin:$PATH

# Install tooling through mise
ARG GITHUB_TOKEN
ENV GITHUB_TOKEN=$GITHUB_TOKEN
RUN <<EOH
set -ex -o pipefail
if [[ -v GITHUB_TOKEN ]]; then
  export MISE_GITHUB_TOKEN=$GITHUB_TOKEN
fi
mise use --global \
  atuin@18.10     \
  delta@0.18      \
  direnv@2.37     \
  eza@0.23        \
  fd@10.3         \
  fzf@0.67        \
  jq@1.8          \
  just@1.45       \
  lazygit@0.57    \
  node@25.2       \
  ripgrep@15.1    \
  starship@1.24   \
  zoxide@0.9
mise trust --all /workspaces
EOH

COPY --chown=vscode <<EOH /home/vscode/.config/starship.toml
palette = 'catppuccin_frappe'
command_timeout = 5000
scan_timeout = 5000
add_newline = false

[palettes.catppuccin_frappe]
rosewater = "#f2d5cf"
flamingo = "#eebebe"
pink = "#f4b8e4"
mauve = "#ca9ee6"
red = "#e78284"
maroon = "#ea999c"
peach = "#ef9f76"
yellow = "#e5c890"
green = "#a6d189"
teal = "#81c8be"
sky = "#99d1db"
sapphire = "#85c1dc"
blue = "#8caaee"
lavender = "#babbf1"
text = "#c6d0f5"
subtext1 = "#b5bfe2"
subtext0 = "#a5adce"
overlay2 = "#949cbb"
overlay1 = "#838ba7"
overlay0 = "#737994"
surface2 = "#626880"
surface1 = "#51576d"
surface0 = "#414559"
base = "#303446"
mantle = "#292c3c"
crust = "#232634"
EOH

# Configure atuin
COPY --chown=vscode <<EOH /home/vscode/.config/atuin/config.toml
update_check = false
EOH

# Install/configure fish
ENV SHELL=/usr/bin/fish
RUN mkdir -p /home/vscode/.config/fish
COPY --chown=vscode <<EOH /home/vscode/.config/fish/config.fish
set fish_greeting
fish_add_path /home/vscode/.local/bin
if status is-interactive
  # Commands to run in interactive sessions can go here
  mise activate fish | source
  atuin init fish | source
  direnv hook fish | source
  starship init fish | source
  zoxide init fish | source
end
EOH

# Ensure some workdir are set with _vscode_ user
RUN mkdir -p /home/vscode/.m2 /home/vscode/.lein

