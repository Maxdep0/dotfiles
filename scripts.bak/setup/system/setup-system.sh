#!/usr/bin/env bash

source "$SCRIPT_SETUP_DIR/utils.sh"

main() {

    # SSHD > NFTABLES  > NETWORKMANAGER

    # bash "$SCRIPT_SETUP_DIR/system/journalctl/setup-journalctl.sh" || logger
    # if bash "$SCRIPT_SETUP_DIR/system/journalctl/setup-journalctl.sh"; then
    #     echo ""
    # else
    #     return 1
    # fi
    #
    if bash "$SCRIPT_SETUP_DIR/system/nftables/setup-nftables.sh"; then
        echo ""
    else
        return 1
    fi

    # if bash "$SCRIPT_SETUP_DIR/system/reflector/setup-reflector.sh"; then
    #     echo ""
    # else
    #
    #     return 1
    # fi

    # Add configuration for network manger.. systemcl etc..
    # if bash "$SCRIPT_SETUP_DIR/system/networkmanager/setup-networkmanager.sh"; then
    #     echo ""
    # else
    #     return 1
    # fi
}

main
