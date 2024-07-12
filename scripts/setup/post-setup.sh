#!/usr/bin/env bash

remove_files() {
    sudo rm -rf \
        "$HOME/.bash_logout" \
        "$HOME/.bash_history" \
        "$HOME/.bash_profile"

    return 0
}

main() {
    logger "⏳⏳ POST SETUP STARTED"

    if sudo pacman -Syu --noconfirm; then
        if remove_files; then
            logger "✅✅ POST SETUP DONE"
            return 0
        fi
    fi

    logger "🔴🔴 POST SETUP FAILED"
    return 1

}

main
