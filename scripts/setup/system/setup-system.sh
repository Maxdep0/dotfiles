#!/usr/bin/env bash

source "$SCRIPT_SETUP_DIR/utils.sh"

main() {
    # bash "$SCRIPT_SETUP_DIR/system/journalctl/setup-journalctl.sh" || logger
    # if bash "$SCRIPT_SETUP_DIR/system/journalctl/setup-journalctl.sh"; then
    #     logger "journalctl OK"
    # else
    #     logger "journalctl NOT OK"
    # fi
    #
    # if bash "$SCRIPT_SETUP_DIR/system/networkmanager/setup-networkmanager.sh"; then
    #     logger "NetworkManager OK"
    # else
    #     logger "NetworkManager NOT OK"
    # fi

    # if bash "$SCRIPT_SETUP_DIR/system/nftables/setup-nftables.sh"; then
    #     logger "nftables OK"
    # else
    #     logger "nftables NOT OK"
    # fi

    if bash "$SCRIPT_SETUP_DIR/system/reflector/setup-reflector.sh"; then
        logger "reflector OK"
    else
        logger "reflector NOT OK"
    fi
}

main
