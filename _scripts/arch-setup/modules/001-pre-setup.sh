#!/usr/bin/env bash

testt() {
    logger "START" "Pre-setup START test"

    if sudo systemctl enable --now reflector.timer; then
        logger "INFO" "Info 1 reflector.timer test"

        if sudo systemctl restart reflector.timer; then
            logger "INFO" "Info 2 reflector.timer test"
            # return 0
        else
            logger "ERROR" "Err 3 reflector.timer test"
            # return 1
        fi

    else
        logger "ERROR" "Err 4 reflector.timer test"
        # return 1
    fi

    logger "PROGRESS" "Progress a1 eza delete --noconfirm test"
    sudo pacman -R --noconfirm eza
    logger "INFO" "Info 2 eza test"

    logger "PROGRESS" "Progress a2 eza install --noconfirm test"
    sudo pacman -S --noconfirm eza
    logger "INFO" "Info 2 eza test"

    logger "PROGRESS" "Progress b1 eza delete test"
    sudo pacman -R eza
    logger "INFO" "Info 2 eza test"

    logger "PROGRESS" "Progress b2 eza install test"
    sudo pacman -S eza
    logger "INFO" "Info 2 eza test"

    logger "OK" "Pre-setup OK test"

}

pre_setup() {
    logger "INFO" "$TEST1"
    logger "INFO" "$TEST2"
    # testt
}

pre_setup
