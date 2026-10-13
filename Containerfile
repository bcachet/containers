FROM mcr.microsoft.com/devcontainers/base:ubuntu26.04

# Install packages without docs and suggested packages
SHELL ["/bin/bash", "-eou", "pipefail", "-c"]

RUN <<EOH
set -ex -o pipefail
apt-get update
export DEBIAN_FRONTEND=noninteractive
apt-get -y install --no-install-recommends --no-install-suggests \
    dnsutils \
    netcat-traditional \
    atuin \
    ble.sh \
    direnv \
    eza \
    fd-find \
    fish \
    git-delta \
    jq \
    ripgrep \
    starship \
    zoxide
apt-get autoremove -y
apt-get clean -y
rm -rf /var/lib/apt/lists/*
EOH

# Ensure vscode owns mise/~.local files
RUN <<EOH
for DIR in /home/vscode/.local/{bin,share,state} /home/vscode/.config; do
  mkdir -p $DIR && chown -R vscode:vscode $DIR
done
EOH

USER vscode

# Ensure github.com is known
RUN mkdir -p ~/.ssh && ssh-keyscan github.com >> ~/.ssh/known_hosts

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

COPY --chown=vscode <<EOH /home/vscode/.config/atuin/config.toml
update_check = false
EOH

COPY --chown=vscode <<EOH /home/vscode/.config/fish/config.fish
set fish_greeting
if status is-interactive
  # Commands to run in interactive sessions can go here
  atuin init fish | source
  direnv hook fish | source
  starship init fish | source
  zoxide init fish | source
end
EOH


RUN <<EOH
echo 'source -- /usr/share/blesh/ble.sh' >> /home/vscode/.bashrc
echo 'eval "$(atuin init bash)"' >> /home/vscode/.bashrc
echo 'eval "$(direnv hook bash)"' >> /home/vscode/.bashrc
echo 'eval "$(starship init bash)"' >> /home/vscode/.bashrc
echo 'eval "$(zoxide init bash)"' >> /home/vscode/.bashrc
EOH

WORKDIR /home/vscode/workspace

