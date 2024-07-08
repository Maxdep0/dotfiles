#!/usr/bin/env bash

source "$SCRIPT_SETUP_DIR/utils.sh"

main() {
    # bash "$SCRIPT_SETUP_DIR/system/journalctl/setup-journalctl.sh" || logger
    if bash "$SCRIPT_SETUP_DIR/system/journalctl/setup-journalctl.sh"; then
        logger "journalctl OK"
    else
        logger "journalctl NOT OK"
    fi

    if bash "$SCRIPT_SETUP_DIR/system/networkmanager/setup-networkmanager.sh"; then
        logger "NetworkManager OK"
    else
        logger "NetworkManager NOT OK"
    fi
}

main
