#!/usr/bin/env bash
#shellcheck disable=SC2128,SC1091

source "$SCRIPT_SETUP_DIR/utils.sh"

DISPATCHER_DIR="/etc/NetworkManager/dispatcher.d"

setup_networkmanager_scripts() {
    logger "dispatcher.d setup in progress..."

    if [ -d "$DISPATCHER_DIR" ]; then
        if sudo stow --dir="$SCRIPT_SETUP_DIR/system" --ignore="setup-networkmanager.sh" --target="$DISPATCHER_DIR" -D networkmanager; then
            logger "dispatcher.d de-stowed."
        else
            logger "dispatcher.d de-stow failed."
            return 1
        fi

        if sudo rm -rf "$DISPATCHER_DIR/99-update-dns.sh" "$DISPATCHER_DIR/99-update-hosts.sh"; then
            logger "dispatcher.d scripts removed."
        else
            logger "dispatcher.d scripts remove failed."
            return 1
        fi

        if sudo stow --dir="$SCRIPT_SETUP_DIR/system" --ignore="setup-networkmanager.sh" --target="$DISPATCHER_DIR" networkmanager; then
            logger "dispatcher.d stowed."
            return 0
        else
            logger "dispatcher.d stow failed."
            return 1
        fi
    else
        logger "dispatcher.d not found."
        return 1
    fi

}

setup_networkmanager_scripts_permissions() {
    logger "dispatcher.d scripts permissions in progress..."
    if [ -f "$DISPATCHER_DIR/99-update-hosts.sh" ] && [ -f "$DISPATCHER_DIR/99-update-dns.sh" ]; then

        if [ -x "$DISPATCHER_DIR/99-update-hosts.sh" ] && [ -x "$DISPATCHER_DIR/99-update-dns.sh" ]; then
            logger "dispatcher.d scripts permissions already set."

        else
            sudo chown root:root "$DISPATCHER_DIR/99-update-hosts.sh" || return 1
            sudo chmod +x "$DISPATCHER_DIR/99-update-hosts.sh" || return 1

            sudo chown root:root "$DISPATCHER_DIR/99-update-dns.sh" || return 1
            sudo chmod +x "$DISPATCHER_DIR/99-update-dns.sh" || return 1
            return 0
        fi

    else
        logger "dispatcher.d scripts not found."
        return 1
    fi

    logger "dispatcher.d permissions set"
    return 0
}

main() {
    #     sudo systemctl enable --now NetworkManager.service || log "sudo sysctl enable --now NetworkManager.service | $LINENO"

    if setup_networkmanager_scripts; then
        logger "dispatcher.d setup done."

        if setup_networkmanager_scripts_permissions; then
            logger "dispatcher.d scripts permissions set."
        else
            logger "dispatcher.d scripts permissions failed."
            return 1
        fi
        return 0
    else
        logger "dispatcher.d setup failed."
        return 1
    fi
}

main
