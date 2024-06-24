#!/bin/bash

pac() {
    local packages=("$@")
    sudo pacman -S --needed --noconfirm "${packages[@]}"
}

cmd_check() {
    command -v "$1" >/dev/null 2>&1
}

mkdir -p "$HOME/Downloads"
mkdir -p "$HOME/.config"

DOWNLOADS=$HOME/Downloads
DOTFILES=$HOME/dotfiles
CONFIG="$HOME/.config"

install_essential_packages() {
    pac base-devel cmake unzip ninja curl tree-sitter
    pac python python-pip python-pynvim

}

install_aux_tools() {
    if ! cmd_check yay; then
        git clone https://aur.archlinux.org/yay.git "$DOWNLOADS/yay"
        makepkg -si --needed --noconfirm -p "$DOWNLOADS/yay/PKGBUILD"
        rm -rf "$DOWNLOADS/yay"
    fi

    if ! cmd_check nvm; then
        curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
        export NVM_DIR="$HOME/.nvm"
        [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
        [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
    fi
}

install_and_setup_neovim() {
    if [ ! -d "$DOWNLOADS/neovim" ]; then
        git clone https://github.com/neovim/neovim "$DOWNLOADS/neovim"
        make --directory="$DOWNLOADS/neovim" CMAKE_BUILD_TYPE=Release
        sudo make --directory="$DOWNLOADS/neovim" install
    fi
    if [ ! -d "$CONFIG/nvim" ]; then
        git clone https://github.com/Maxdep0/nvim.git "$CONFIG/nvim"
    fi

    nvm install 22
}

install_essential_packages
install_aux_tools
install_and_setup_neovim
