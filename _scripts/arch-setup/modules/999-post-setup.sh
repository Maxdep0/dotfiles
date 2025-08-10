#!/usr/bin/env bash

install_packages() {
    paci_install \
        noto-fonts-emoji noto-fonts noto-fonts-extra \
        ttf-dejavu ttf-liberation ttf-jetbrains mono \
        ttf-nerd-fonts-symbols-mono
    paci_install \
        python python-pip jdk-openjdk \
        mpv feh libreoffice-fresh \
        man-db man-pages man \
        acpi htop tree
    return 0
}
fast_clean() {
    fs_remove "$HOME/.bash_layout"
    fs_remove "$HOME/.bash_history"
    fs_remove "$HOME/.bash_profile"
    fc-cache -fv
    sudo pacman -Rns --noconfirm "$(sudo pacman -Qdtq)"
    if mapfile -t _orph < <(pacman -Qdtq); then
        if ((${#_orph[@]})); then
            sudo pacman -Rns --noconfirm -- "${_orph[@]}"
            logger info "Orphaned packages removed: ${_orph[*]}"
        else
            logger info "No orphaned packages."
        fi
    else
        logger warn "Failed to query orphans."
    fi
    return 0
}
run_post_setup() {
    logger progress "Post-setup started..."
    logger progress "Installing packages..."
    if install_packages; then
        logger ok "Packages installed successfully"
        logger progress "Updating packages..."
        if sudo pacman -Syu --noconfirm; then
            logger ok "Packages updated successfully"
            logger progress "Fast cleaning..."
            if fast_clean; then
                logger ok "Fast clean completed successfully"
                logger ok "Post-setup done"
                return 0
            fi
        fi
    fi
    logger error "Post-setup failed"
    return 1
}

run_post_setup
