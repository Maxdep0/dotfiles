#!/usr/bin/env bash
install_packages() {
    paci_install sudo
    sudo pacman -Syu --noconfirm
    paci_install \
        base base-devel archlinux-keyring \
        ninja curl cmake make wget tar unzip zip p7zip \
        ripgrep grep fd fzf bat jq
    return 0
}
create_dirs() {
    fs_mkdir "$HOME/.config"
    fs_mkdir "$HOME/Documents"
    fs_mkdir "$HOME/Downloads"
    fs_mkdir "$HOME/Pictures/Background"
    fs_mkdir "$HOME/Projects"
    fs_mkdir "$HOME/.local/bin"
    return 0
}
stow_dirs() {
    paci_install stow
    stow --dir="$DOTFILES" -D gitconfig htop hypr images satty waybar wezterm wpaperd zsh
    stow --dir="$DOTFILES" gitconfig htop hypr zsh wezterm images htop satty hypr wpaperd waybar
    return 0
}
run_pre_setup() {
    logger progress "Pre-setup started..."
    logger progress "Installing packages..."
    if install_packages; then
        logger ok "Packages installed successfully"
        logger progress "Creating dirs..."
        if create_dirs; then
            logger ok "Dirs created successfully"
            logger progress "Stowing dirs..."
            if stow_dirs; then
                logger ok "Stow directories completed successfully"
                logger ok "Pre-setup done"
                return 0
            fi
        fi
    fi
    logger error "Pre-setup failed"
    return 1
}

run_pre_setup
