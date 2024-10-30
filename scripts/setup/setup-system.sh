#!/usr/bin/env bash

source "$HOME/dotfiles/scripts/setup/env.sh"
source "$HOME/dotfiles/scripts/setup/utils.sh"

#
# Pacman
#

install_and_setup_paccache() {
    logger "⏳PACMAN SETUP STARTED"

    update_pacman_config() {
        if ! sudo sed -i \
            -e 's/^#*\s*Color.*/Color/' \
            -e 's/^#*\s*CheckSpace.*/CheckSpace/' \
            -e 's/^#*\s*VerbosePkgLists.*/VerbosePkgLists/' \
            -e 's/^#*\s*ParallelDownloads.*/ParallelDownloads = 5/' \
            -e 's/^#*\s*CleanMethod.*/CleanMethod = KeepInstalled/' \
            "$PACMAN_CONF"; then
            logger "Failed to update pacman.conf. (sed -i)"
            return 1
        fi

        if ! grep -q "^ILoveCandy" "$PACMAN_CONF" &&
            ! sudo sed -i '/^\[options\]/a ILoveCandy' "$PACMAN_CONF"; then
            logger "Failed to update pacman.conf. (ILoveCandy)"
            return 1
        fi

        logger "Successfully updated pacman.conf"
        return 0
    }

    if_not_installed_then_install pacman-contrib || return 1
    if_no_backup_then_create "copy" "$PACMAN_CONF" || return 1
    update_pacman_config || return 1
    copy_file_directly_from_src "$SYSTEMD_SYSTEM" "paccache.timer" || return 1
    enable_and_restart paccache.timer || return 1

    logger "✅ PACMAN SETUP DONE"
    return 0
}

#
# SSH
#

install_and_setup_sshd() {
    logger "⏳SSH SETUP STARTED"

    update_sshd_config() {
        sudo sed -i \
            -e 's/^#*\s*Port.*/Port 15243/' \
            -e 's/^#*\s*PermitRootLogin.*/PermitRootLogin no/' \
            -e 's/^#*\s*PasswordAuthentication.*/PasswordAuthentication no/' \
            -e 's/^#*\s*PubkeyAuthentication.*/PubkeyAuthentication yes/' \
            -e 's/^#*\s*PermitEmptyPasswords.*/PermitEmptyPasswords no/' \
            -e 's/^#*\s*X11Forwarding.*/X11Forwarding no/' \
            -e 's/^#*\s*AllowTcpForwarding.*/AllowTcpForwarding no/' \
            -e 's/^#*\s*X11Forwarding.*/X11Forwarding no/' \
            "$SSHD_CONFIG"
    }

    copy_file_directly_from_src "$SSH_DIR" "config" || return 1

    update_sshd_config || return 1
    if_no_backup_then_create "copy" "$SSHD_CONFIG" || return 1
    update_sshd_config || return 1
    enable_and_restart sshd.service || return 1

    logger "✅ SSHD SETUP DONE"
    return 0

}

#
# Reflector
#

install_and_setup_reflector() {
    logger "⏳REFLECTOR SETUP STARTED"

    if_not_installed_then_install reflector || return 1
    if_no_backup_then_create "move" "$REFLECTOR_CONF" || return 1
    copy_file_directly_from_src "$REFLECTOR_DIR" "reflector.conf" || return 1
    copy_file_directly_from_src "$SYSTEMD_SYSTEM" "reflector.timer" || return 1
    enable_and_restart reflector.service || return 1
    enable_and_restart reflector.timer || return 1

    logger "✅ REFLECTOR SETUP DONE"
    return 0
}

#
# Journalctl
#

setup_journalctl() {
    logger "⏳JOURNALCTL SETUP STARTED"

    if_no_backup_then_create "copy" "$JOURNALD_CONF" || return 1
    sudo sed -i '/^#*SystemMaxUse/ s/^#*SystemMaxUse.*/SystemMaxUse=50M/' "$JOURNALD_CONF" || return 1
    sudo systemctl restart systemd-journald || return 1

    logger "✅ JOURNALCTL SETUP DONE"
    return 0
}

#
# Nftables
#

install_and_setup_nftables() {
    logger "⏳NFTABLES SETUP STARTED"

    if_not_installed_then_install nftables || return 1
    if_no_backup_then_create "move" "$NFTABLES_CONF" || return 1
    create_or_relink_symlink "$NFTABLES_CONF" || return 1
    enable_and_restart nftables.service || return 1
    sudo nft -f "$NFTABLES_CONF" || return 1

    logger "✅ NFTABLES SETUP DONE"
    return 0
}

#
# Network Manager
#

install_and_setup_networkmanager() {
    logger "⏳NETWORKMANAGER SETUP STARTED"

    add_script_permissions() {
        local files=("99-update-hosts.sh" "99-update-dns.sh")
        for file in "${files[@]}"; do
            if ! sudo chown root:root "$NM_DISPATCHER_DIR/$file" || ! sudo chmod +x "$NM_DISPATCHER_DIR/$file"; then
                logger "Failed to add permissions to $file"
                return 1
            fi
        done
        return 0
    }

    if_not_installed_then_install networkmanager network-manager-applet || return 1
    create_or_relink_symlink "$NM_DISPATCHER_DIR/99-update-hosts.sh" || return 1
    create_or_relink_symlink "$NM_DISPATCHER_DIR/99-update-dns.sh" || return 1
    add_script_permissions || return 1
    enable_and_restart NetworkManager.service || return 1

    logger "💤 Sleeping for 5s..."
    sleep 5s

    logger "✅ NETWORKMANAGER SETUP DONE"
    return 0
}

#
# Audio
#

install_and_setup_audio() {
    logger "⏳AUDIO SETUP STARTED"

    if_not_installed_then_install pulseaudio pulseaudio-alsa pulseaudio-jack || return 1
    if_not_installed_then_install pavucontrol pamixer playerctl || return 1
    systemctl --user enable --now pulseaudio || return 1

    logger "✅ AUDIO SETUP DONE"
    return 0
}

#
# Power Button
#

disable_powerbutton() {
    if ! sudo sed -i 's/^#*\s*HandlePowerKey\s*=.*/HandlePowerKey=ignore/' \
        /etc/systemd/logind.conf; then
        logger "Failed to update logind.conf"
        return 1
    fi
    return 0
}

main() {
    logger "⏳⏳ SYSTEM SETUP STARTED"

    install_and_setup_paccache || return 1
    install_and_setup_sshd || return 1
    install_and_setup_nftables || return 1
    install_and_setup_reflector || return 1
    install_and_setup_networkmanager || return 1
    install_and_setup_audio || return 1
    disable_powerbutton || return 1
    setup_journalctl || return 1
    sudo systemctl daemon-reload || return 1

    logger "✅✅ SYSTEM SETUP DONE"
    return 0
}

main
