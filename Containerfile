FROM quay.io/fedora/fedora:43

# Install packages without docs and suggested packages
RUN <<EOF
set -ex
dnf copr enable -y relativesure/all-packages
dnf install -y --nodocs --setopt install_weak_deps=False \
    atuin \
    bat \
    curl \
    direnv \
    fd-find \
    fish \
    git \
    git-delta \
    jq \
    mise \
    neovim \
    rbw \
    ripgrep \
    starship \
    zoxide
dnf clean all -y
EOF

# VSCode user Configuration
RUN groupadd --gid 1000 vscode && \
    useradd --uid 1000 --gid 1000 --create-home --shell /bin/fish vscode && \
    echo 'vscode ALL=(ALL) NOPASSWD:ALL' >>/etc/sudoers

USER vscode

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

# Install/configure fish
RUN mkdir -p /home/vscode/.config/fish
COPY --chown=vscode <<EOH /home/vscode/.config/fish/config.fish
set fish_greeting
fish_add_path /home/vscode/.local/bin
if status is-interactive
  # Commands to run in interactive sessions can go here
  atuin init fish | source
  direnv hook fish | source
  mise activate fish | source
  starship init fish | source
  zoxide init fish | source
end
EOH

