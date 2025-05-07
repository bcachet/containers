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


COPY --chown=vscode:vscode config/m2/ /home/vscode/.m2

USER vscode

# Install starship
RUN curl -fsSL https://starship.rs/install.sh | sh -s -- --yes

RUN <<EOF
mkdir -p /home/vscode/.bashrc.d
cat <<EOH >> /home/vscode/.bashrc
# User specific aliases and functions
if [ -d ~/.bashrc.d ]; then
  for rc in ~/.bashrc.d/*; do
    if [ -f "\$rc" ]; then
      . "\$rc"
    fi
  done
fi
EOH
EOF

COPY <<EOH /home/vscode/.bashrc.d/starship
if command -v starship &> /dev/null; then
  eval "$(starship init bash)"
fi
EOH

COPY <<EOH /home/vscode/.config/starship.toml
palette = 'catppuccin_frappe'
command_timeout = 5000
scan_timeout = 5000


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

