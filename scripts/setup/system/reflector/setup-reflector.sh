#!/usr/bin/env bash

source "$SCRIPT_SETUP_DIR/utils.sh"

PACMAND="/etc/pacman.d"
REFLECTOR="/etc/xdg/reflector"

install_reflector() {

    if pac_check reflector; then
        logger "reflector is installed"
        return 0
    else
        logger "installing reflector..."
        if sudo pacman -S --noconfirm --needed reflector; then
            logger "reflector is installed"
            return 0
        else
            logger "reflector installation failed"
            return 1
        fi
    fi

}

setup_reflector_config() {

    echo "yes"

    if echo "--save /etc/pacman.d/mirrorlist 
--country GB,DE,FR,NL,SE,CZ,SK 
--protocol https 
--latest 20 
--sort rate
--age 24 
--completion-percent 100
--fastest 10" | sudo tee "$REFLECTOR/reflector.conf" >/dev/null; then
        logger "reflector config updated"
        return 0
    else
        logger "could not update reflector config"
        return 1
    fi

}

setup_reflector_timer() {
    logger "enabling reflector.timer..."
    if sudo systemctl enable --now reflector.timer; then
        logger "reflector.timer enabled"
        logger "starting daemon-reload..."
        if sudo systemctl daemon-reload; then
            logger "daemon-reload restarted"
            logger "restarting reflector.timer..."
            if sudo systemctl restart reflector.timer; then
                logger "reflector.timer restarted"
                return 0
            else
                logger "restarting reflector.timer failed"
                return 1
            fi
        else
            logger "starting daemon-reload failed"
            return 1
        fi
    else
        logger "enabling reflector.timer failed"
        return 1
    fi
}

main() {
    if install_reflector; then
        logger "reflector setup in progress..."

        if setup_reflector_config; then
            logger "reflector.timer setup in progres..."

            if setup_reflector_timer; then
                logger "reflector setup done"
                return 0
            else
                logger "reflector setup failed"
                return 1
            fi

        else
            logger "reflector failed"
            return 1
        fi

    else
        logger "reflector failed"
        return 1
    fi

}

main
