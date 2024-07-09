#!/usr/bin/env bash

# shellcheck disable=SC2128,SC1091

source "$SCRIPT_SETUP_DIR/utils.sh"

ETC="/etc"

install_nftables() {

    if pac_check nftables; then
        logger "nftables is installed"
        return 0
    else
        logger "installing nftables..."
        if sudo pacman -S --noconfirm --needed nftables; then
            logger "nftables is installed"
            return 0
        else
            logger "nftables installation failed"
            return 1
        fi
    fi
}

setup_nftables_config() {

    if [ ! -f "$SCRIPT_SETUP_DIR/system/nftables/nftables.conf" ]; then
        logger "no nftable.conf found in dotfiles"
        return 1
    fi

    if [ ! -f "$ETC/nftables.conf.bak" ]; then
        logger "creating nftables.conf.bak..."
        if sudo mv "$ETC/nftables.conf" "$ETC/nftables.conf.bak"; then
            logger "nftables.conf.bak created"
        else
            logger "could not create nftables.conf.bak"
            return 1
        fi
    fi

    if [ -f "$ETC/nftables.conf" ]; then

        if sudo stow --dir="$SCRIPT_SETUP_DIR/system" --ignore="setup-nftables.sh" --target="$ETC" -D nftables; then
            logger "nftables.conf de-stowed."
        else
            logger "de-stow nftables.conf failed."
            return 1
        fi

        if sudo rm -rf "$ETC/nftables.conf"; then
            logger "nftables.conf removed."
        fi

        if sudo stow --dir="$SCRIPT_SETUP_DIR/system" --ignore="setup-nftables.sh" --target="$ETC" nftables; then
            logger "nftables.conf stowed."
            return 0
        else
            logger "stow nftables.conf failed."
            return 1
        fi

    else

        logger "stowing nftables.conf..."

        if sudo stow --dir="$SCRIPT_SETUP_DIR/system" --ignore="setup-nftables.sh" --target="$ETC" nftables; then
            logger "nftables.conf stowed."
            return 0
        else
            logger "stow nftables.conf failed."
            return 1
        fi

    fi
}

setup_nftables_service() {
    logger "enabling nftables.service..."
    if sudo systemctl enable --now nftables.service; then
        logger "nftables.service enabled"
        logger "nftables.service restarting..."
        if sudo systemctl restart nftables.service; then
            logger "nftables.service restarted"
            logger "updating nftables config..."
            if sudo nft -f "$ETC/nftables.conf"; then
                logger "nftable config updated"
                return 0
            else
                logger "updating nftables config failed"
                return 1
            fi
        else
            logger "restarting nftables.service failed"
            return 1
        fi
    else
        logger "enabling nftables.service failed"
        return 1
    fi
}

main() {
    if install_nftables; then
        logger "nftables setup in progress..."

        if setup_nftables_config; then
            logger "nftables.service setup in progres..."

            if setup_nftables_service; then
                logger "nftables setup done"
                return 0
            else
                logger "nftables.service setup failed"
                return 1
            fi

        else
            logger "nftables setup failed"
            return 1
        fi

    else
        logger "nftables installation failed"
        return 1
    fi

}

main
