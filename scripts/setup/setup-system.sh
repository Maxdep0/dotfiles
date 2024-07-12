#!/usr/bin/env bash

source "$SCRIPT_SETUP_DIR/utils.sh"

#
# Pacman
#

install_and_setup_paccache() {
    logger "⏳PACCACHE SETUP STARTED"
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

    if if_not_installed_then_install pacman-contrib; then
        if if_no_backup_then_create "copy" "$PACMAN_CONF"; then
            if update_pacman_config; then
                if create_or_relink_symlink "$PACCACHE_TIMER"; then
                    if enable_and_restart paccache.timer; then
                        logger "✅ PACCACHE SETUP DONE"
                        return 0
                    fi
                fi
            fi
        fi
    fi

    logger "🔴 PACCACHE SETUP FAILED"
    return 1
}

#
# SSH
#

install_and_setup_sshd() {
    logger "⏳SSHD SETUP STARTED"

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

    if if_not_installed_then_install openssh; then
        if if_no_backup_then_create "copy" "$SSHD_CONFIG"; then
            if update_sshd_config; then
                if enable_and_restart sshd.service; then
                    logger "✅ SSHD SETUP DONE"
                    return 0
                fi
            fi

        fi
    fi

    logger "🔴 SSHD SETUP FAILED"
    return 1
}

#
# Reflector
#

#####
##### FIX: reflector.service restart stops logger.
#####

install_and_setup_reflector() {
    logger "⏳REFLECTOR SETUP STARTED"

    if if_not_installed_then_install reflector; then
        if if_no_backup_then_create "move" "$REFLECTOR_CONF"; then
            if copy_file_directly_from_src "$REFLECTOR_DIR" "reflector.conf"; then
                if create_or_relink_symlink "$REFLECTOR_TIMER"; then
                    if enable_and_restart reflector.service; then
                        if enable_and_restart reflector.timer; then
                            logger "✅ REFLECTOR SETUP DONE"
                            return 0
                        fi
                    fi
                fi
            fi
        fi
    fi

    logger "🔴 REFLECTOR SETUP FAILED"
    return 1
}

#
# Journalctl
#

setup_journalctl() {
    logger "⏳JOURNALCTL SETUP STARTED"

    update_journald_settings() {
        if sudo sed -i '/^#*SystemMaxUse/ s/^#*SystemMaxUse.*/SystemMaxUse=50M/' "$JOURNALD_CONF"; then
            logger "Successfully updated journald.conf"
            return 0
        else
            logger "Failed to update journald.conf"
            return 1
        fi
    }

    if if_no_backup_then_create "copy" "$JOURNALD_CONF"; then
        if update_journald_settings; then
            if sudo systemctl restart systemd-journald; then
                logger "Successfully restarted systemd-journald"
                logger "✅ JOURNALCTL SETUP DONE"
                return 0
            fi
        fi
    fi

    logger "🔴 JOURNALCTL SETUP FAILED"
    return 1
}

#
# Nftables
#

install_and_setup_nftables() {
    logger "⏳NFTABLES SETUP STARTED"

    if if_not_installed_then_install nftables; then
        if if_no_backup_then_create "move" "$NFTABLES_CONF"; then
            if create_or_relink_symlink "$NFTABLES_CONF"; then
                if enable_and_restart nftables.service; then
                    if sudo nft -f "$NFTABLES_CONF"; then
                        logger "✅ NFTABLES SETUP DONE"
                        return 0
                    else
                        logger "Failed to setup nftables."
                        return 1
                    fi
                fi
            fi
        fi
    fi

    logger "🔴 NFTABLES SETUP FAILED"
    return 1
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

    if if_not_installed_then_install networkmanager network-manager-applet; then
        if create_or_relink_symlink "$NM_DISPATCHER_DIR/99-update-hosts.sh" &&
            create_or_relink_symlink "$NM_DISPATCHER_DIR/99-update-dns.sh"; then
            if add_script_permissions; then
                if enable_and_restart NetworkManager.service; then
                    logger "💤 Sleeping for 5s..."
                    sleep 5s

                    logger "✅ NETWORKMANAGER SETUP DONE"
                    return 0
                fi
            fi
        fi
    fi

    logger "🔴 NETWORKMANAGER SETUP FAILED"
    return 1
}

main() {
    logger "⏳⏳ SYSTEM SETUP STARTED"

    if install_and_setup_paccache; then
        if install_and_setup_sshd; then
            if install_and_setup_nftables; then
                if install_and_setup_reflector; then
                    if install_and_setup_networkmanager; then
                        if setup_journalctl; then
                            if sudo systemctl daemon-reload; then
                                logger "✅✅ SYSTEM SETUP DONE"
                                return 0
                            fi
                        fi
                    fi
                fi
            fi
        fi
    fi

    logger "🔴🔴 SYSTEM SETUP FAILED"
    return 1
}

main
