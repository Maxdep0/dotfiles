#!/usr/bin/bash

source "$SCRIPT_SETUP_DIR/env.sh"
source "$SCRIPT_SETUP_DIR/utils.sh"

install_packages() {
    if_not_installed_then_install \
        base base-devel archlinux-keyring sudo \
        ninja curl cmake make wget tar unzip zip p7zip \
        ripgrep grep fd fzf bat \
        python python-pip jdk-openjdk \
        mpv feh libreoffice-fresh \
        acpi htop tree

    return 0
}

create_dirs() {
    mkdir -pv \
        "$HOME/Documents" \
        "$HOME/Downloads" \
        "$HOME/Pictures/Background" \
        "$HOME/Projects" \
        "$HOME/logs/setup" \
        "$HOME/Videos"

    return 0
}

stow_dirs() {
    if_not_installed_then_install git openssh stow

    stow --dir="$DOTFILES" -D gitconfig zsh wezterm images htop satty hypr wpaperd waybar
    stow --dir="$DOTFILES" gitconfig zsh wezterm images htop satty hypr wpaperd waybar

    return 0
}

main() {
    logger "⏳⏳ PRE-SETUP STARTED"

    sudo pacman -Syu --noconfirm

    logger "Creating dirs..."
    if create_dirs; then
        logger "Successfully created dirs."
        logger "Stowing dirs..."
        if stow_dirs; then
            logger "Successfully stowed dirs."
            logger "Installing packages..."
            if install_packages; then
                logger "Successfully installed packages."
                logger "✅✅ PRE SETUP DONE"
                return 0
            fi
        fi
    fi

    logger "🔴🔴 PRE-SETUP FAILED"
    return 1
}

main
