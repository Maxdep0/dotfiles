#!/usr/bin/bash

source "$SCRIPT_SETUP_DIR/utils.sh"

SYSTEMD="/etc/systemd"

setup_journalctl() {
    logger "journald.conf setup in progress..."

    if [ -f "$SYSTEMD/journald.conf" ]; then

        if [ ! -f "$SYSTEMD/journald.conf.bak" ]; then
            if sudo cp "$SYSTEMD/journald.conf" "$SYSTEMD/journald.conf.bak"; then
                logger "backup created"
            else
                logger "copy original file failed"
                return 1
            fi

        fi

        if [ -f "$SYSTEMD/journald.conf.bak" ]; then
            if sudo sed -i '/^#*SystemMaxUse/ s/^#*SystemMaxUse.*/SystemMaxUse=50M/' "$SYSTEMD/journald.conf"; then
                logger "journald.conf updated"
                return 0
            else
                logger "jornald.conf update failed"
                return 1
            fi
        else
            logger "journald.conf.bak not found"
            return 1
        fi

    else
        logger "journald.conf not found"
        return 1
    fi
}

main() {
    if setup_journalctl; then
        logger "journald.conf setup done"
        return 0
    else
        logger "journald.conf setup failed"
        return 1
    fi
}

main
