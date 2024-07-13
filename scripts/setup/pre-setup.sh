#!/usr/bin/bash

source "$SCRIPT_SETUP_DIR/utils.sh"

create_dirs() {
    logger "⏳CREATE DIRS STARTED"

    if mkdir -pv \
        "$HOME/Documents" \
        "$HOME/Downloads" \
        "$HOME/Pictures/Background" \
        "$HOME/Projects" \
        "$HOME/logs/setup" \
        "$HOME/Videos"; then
        logger "✅ DIRS CREATED"
        return 0
    fi

    logger "🔴  FAILED TO CREATE DIRS"
    return 1
}

stow_dirs() {
    logger "⏳STOW SETUP STARTED"

    if if_not_installed_then_install git openssh stow; then
        stow --dir="$DOTFILES" -D \
            gitconfig \
            images \
            satty \
            sway waybar \
            wezterm \
            zsh \
            wpaperd

        stow --dir="$DOTFILES" \
            gitconfig \
            images \
            satty \
            sway \
            waybar \
            wezterm \
            zsh \
            wpaperd

        logger "✅ STOW SETUP DONE"
        return 0
    fi

    logger "🔴 STOW SETUP FAILED"
    return 1
}

main() {
    logger "⏳⏳ PRE-SETUP STARTED"

    sudo pacman -Syu --noconfirm

        if create_dirs; then
            if stow_dirs; then
                logger "✅✅ PRE SETUP DONE"
                return 0
            fi
        fi

    logger "🔴🔴 PRE-SETUP FAILED"
    return 1
}

main
