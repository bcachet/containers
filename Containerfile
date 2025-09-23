FROM quay.io/fedora/fedora:42

# Install packages
RUN <<EOH
dnf install -y \
    atuin-18.6.1 \
    curl-8.11.1 \
    git-2.51.0 \
    direnv-2.35.0 \
    fd-find-10.2.0 \
    fish-4.0.2 \
    fzf-0.65.2 \
    git-delta-0.18.2 \
    jq-1.7.1 \
    just-1.42.4 \
    ripgrep-14.1.1 \
    zoxide-0.9.8
dnf clean all && \
    rm -rf /var/cache/dnf \
           /var/lib/dnf \
           /var/log/*.log
EOH


# Create vscode user
ARG USERNAME=vscode
ARG USER_UID=1000
ARG USER_GID=$USER_UID
RUN <<EOH
groupadd --gid $USER_GID $USERNAME
useradd -s /bin/bash --uid $USER_UID --gid $USER_GID -m $USERNAME
echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME
chmod 0440 /etc/sudoers.d/$USERNAME
EOH

USER vscode

WORKDIR /home/vscode
RUN mkdir -p /home/vscode/.local/bin

SHELL ["/bin/bash", "-eou", "pipefail", "-c"]
# Install eza
RUN <<EOH
curl -L https://github.com/eza-community/eza/releases/latest/download/eza_x86_64-unknown-linux-gnu.tar.gz --output - | tar xz
chmod +x eza
mv eza /home/vscode/.local/bin/
EOH

# Install starship
RUN <<EOH
    curl -fsSL https://starship.rs/install.sh | sh -s -- --yes
    mkdir -p /home/vscode/.cache/starship
    mkdir -p /home/vscode/.config
EOH

ENV PATH="$PATH:/home/vscode/.local/bin"

RUN mkdir -p /home/vscode/.m2

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
  starship init fish | source
  direnv hook fish | source
  zoxide init fish | source
end
EOH

