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
RUN <<EOH
set -ex -o pipefail
if [[ -v GITHUB_TOKEN ]]; then
  export MISE_GITHUB_TOKEN=$GITHUB_TOKEN
fi
# atuin version shipped in APT repo
# is not working as expected with fish
# => install it through mise
mise use --global \
  atuin \
  lazygit \
  neovim \
  node \
  starship \
  uv@latest
mise trust --all /workspaces
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

# Configure atuin
COPY --chown=vscode <<EOH /home/vscode/.config/atuin/config.toml
update_check = false
EOH

# Configure fish
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

## AI tooling
RUN <<EOH
set -ex -o pipefail
if [[ -v GITHUB_TOKEN ]]; then
  export MISE_GITHUB_TOKEN=$GITHUB_TOKEN
fi
mise use --global \
  claude-code \
  npm:@zed-industries/claude-code-acp \
  npm:@mariozechner/pi-coding-agent \
  pipx:batrachian-toad
EOH

