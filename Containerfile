FROM mcr.microsoft.com/devcontainers/base:ubuntu-24.04

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
    git-delta \
    jq \
    just \
    ripgrep \
    starship \
    zoxide
apt-get autoremove -y
apt-get clean -y
rm -rf /var/lib/apt/lists/*
EOH

RUN mkdir /mise && chown -R vscode:vscode /mise

USER vscode

# Ensure github.com is known
RUN mkdir -p ~/.ssh && ssh-keyscan github.com >> ~/.ssh/known_hosts

# Install mise
ENV MISE_DATA_DIR="/home/vscode/.local/share/mise"
ENV MISE_INSTALL_PATH="/home/vscode/.local/bin/mise"
ENV PATH=/home/vscode/.local/bin:${MISE_DATA_DIR}/shims:$PATH
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

# Configure starship
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

# Configure fish
RUN mkdir -p /home/vscode/.config/fish

COPY --chown=vscode <<EOH /home/vscode/.config/fish/config.fish
set fish_greeting
fish_add_path /home/vscode/.local/bin
if status is-interactive
  # Commands to run in interactive sessions can go here
  if type -q mise; mise activate fish | source; end
  if type -q atuin; atuin init fish | source; end
  if type -q direnv; direnv hook fish | source; end
  if type -q starship; starship init fish | source; end
  if type -q zoxide; zoxide init fish | source; end
end
EOH

COPY <<EOH /home/vscode/.config/atuin/config.toml
update_check = false
EOH

COPY <<EOH /home/vscode/.config/mise/config.toml
[tools]
atuin = "latest"
pi = "latest"
node = "latest"
EOH

WORKDIR /workspaces

