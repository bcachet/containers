FROM mcr.microsoft.com/devcontainers/base:ubuntu-24.04

# Install packages without docs and suggested packages
SHELL ["/bin/bash", "-eou", "pipefail", "-c"]
RUN <<EOH
apt-get update
export DEBIAN_FRONTEND=noninteractive
apt-get -y install --no-install-recommends \
    curl \
    git \
    direnv \
    eza \
    fd-find \
    fish \
    fzf \
    jq \
    just \
    procps \
    ripgrep
apt-get autoremove -y
apt-get clean -y
rm -rf /var/lib/apt/lists/*
EOH

RUN <<EOH
curl -sSfL https://github.com/dandavison/delta/releases/download/0.18.2/git-delta_0.18.2_amd64.deb -o git-delta_0.18.2_amd64.deb
dpkg -i git-delta_0.18.2_amd64.deb
rm git-delta_0.18.2_amd64.deb
EOH

USER vscode

ENV PATH="$PATH:/home/vscode/.local/bin"

# Install zoxide
RUN curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh

RUN mkdir -p /home/vscode/.m2

SHELL ["/bin/bash", "-eou", "pipefail", "-c"]
# Install starship
RUN <<EOH
    curl -fsSL https://starship.rs/install.sh | sh -s -- --yes
    mkdir -p /home/vscode/.cache/starship
    mkdir -p /home/vscode/.config
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

# Install atuin
RUN <<EOH
curl --proto '=https' --tlsv1.2 -LsSf https://setup.atuin.sh | sh
mkdir -p /home/vscode/.config/atuin
EOH

COPY --chown=vscode <<EOH /home/vscode/.config/atuin/config.toml
update_check = false
EOH

# Install/configure fish
RUN mkdir -p /home/vscode/.config/fish
COPY --chown=vscode <<EOH /home/vscode/.config/fish/config.fish
set fish_greeting
fish_add_path /home/vscode/.local/bin
fish_add_path /usr/lib/cargo/bin
if status is-interactive
  # Commands to run in interactive sessions can go here
  starship init fish | source
  direnv hook fish | source
  zoxide init fish | source
end
EOH

