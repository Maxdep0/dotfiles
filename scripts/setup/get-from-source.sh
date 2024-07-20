#!/usr/bin/env bash

source "$HOME/dotfiles/scripts/setup/env.sh"
source "$HOME/dotfiles/scripts/setup/utils.sh"

#
# NVM
#

install_nvm() {
    [ -d "$NVM_DIR" ] || mkdir "$NVM_DIR"

    sudo curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash || return 0

    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

    nvm install node

    return 0
}

#
# PARU
#

install_paru() {

    [ -d "$XDG_DOWNLOAD_DIR/paru" ] && sudo rm -rf "$XDG_DOWNLOAD_DIR/paru"

    git clone "https://aur.archlinux.org/paru.git" "$XDG_DOWNLOAD_DIR/paru" || return 1
    (cd "$XDG_DOWNLOAD_DIR/paru" && makepkg -si --needed --noconfirm) || return 1

    [ -d "$XDG_DOWNLOAD_DIR/paru" ] && sudo rm -rf "$XDG_DOWNLOAD_DIR/paru"

    return 0
}

#
# YAY
#

install_yay() {
    [ -d "$XDG_DOWNLOAD_DIR/yay" ] && sudo rm -rf "$XDG_DOWNLOAD_DIR/yay"

    git clone "https://aur.archlinux.org/yay.git" "$XDG_DOWNLOAD_DIR/yay" || return 1
    (cd "$XDG_DOWNLOAD_DIR/yay" && makepkg -si --needed --noconfirm) || return 1

    [ -d "$XDG_DOWNLOAD_DIR/yay" ] && sudo rm -rf "$XDG_DOWNLOAD_DIR/yay"

    return 0
}

#
# NEOVIM
#

install_neovim() {

    [ -d "$XDG_DOWNLOAD_DIR/neovim" ] && sudo rm -rf "$XDG_DOWNLOAD_DIR/neovim"

    if_not_installed_then_install \
        base-devel cmake unzip ninja curl \
        python-pynvim luarocks lua51 \
        tree-sitter tree-sitter-cli bat

    nvm install node || install_nvm

    git clone https://github.com/neovim/neovim "$XDG_DOWNLOAD_DIR/neovim" || return 1
    make --directory="$XDG_DOWNLOAD_DIR/neovim" CMAKE_BUILD_TYPE=Release || return 1
    sudo make --directory="$XDG_DOWNLOAD_DIR/neovim" install || return 1

    [ -d "$XDG_DOWNLOAD_DIR/neovim" ] && sudo rm -rf "$XDG_DOWNLOAD_DIR/neovim"

    [ -d "$XDG_CONFIG_HOME/nvim" ] || git clone https://github.com/Maxdep0/nvim.git "$XDG_CONFIG_HOME/nvim"

    return 0
}

case "$1" in
nvm)
    logger "Installing nvm from source..."
    if install_nvm; then
        logger "Successfully installed nvm."
    fi
    ;;
yay)
    logger "Installing yay from source..."
    if install_yay; then
        logger "Successfully installed yay."
    fi
    ;;
paru)
    logger "Installing paru from source..."
    if install_paru; then
        logger "Successfully installed paru."
    fi
    ;;
nvim)
    logger "Installing neovim from source..."
    if install_neovim; then
        logger "Successfully installed neovim."
    fi
    ;;
*)
    echo "Invalid parameter. Use 'install-nvm', 'install-yay', 'update-paru', 'install-neovim'"
    ;;
esac
