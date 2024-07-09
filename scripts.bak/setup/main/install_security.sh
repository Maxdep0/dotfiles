
setup_ssh() {

    if [[ -f "/etc/ssh/sshd_config" ]]; then
        sudo sed -i \
            -e 's/^#*\s*Port.*/Port 15243/' \
            -e 's/^#*\s*PermitRootLogin.*/PermitRootLogin no/' \
            -e 's/^#*\s*PasswordAuthentication.*/PasswordAuthentication no/' \
            -e 's/^#*\s*PubkeyAuthentication.*/PubkeyAuthentication yes/' \
            -e 's/^#*\s*PermitEmptyPasswords.*/PermitEmptyPasswords no/' \
            -e 's/^#*\s*X11Forwarding.*/X11Forwarding no/' \
            -e 's/^#*\s*AllowTcpForwarding.*/AllowTcpForwarding no/' \
            -e 's/^#*\s*X11Forwarding.*/X11Forwarding no/'  \
             "/etc/ssh/sshd_config"
    fi

    sudo systemctl enable --now sshd
}


setup_nftables() {
    sudo stow --dir="$SCRIPT_CONFIG_FILES" --target="/etc" -D nftables
    [[ -f "/etc/nftables.conf" ]] && sudo mv "/etc/nftables.conf" "/etc/nftables.conf.bak" 
    sudo rm -rf "/etc/nftables.conf"
    sudo stow --dir="$SCRIPT_CONFIG_FILES" --target="/etc" nftables

    sudo systemctl enable --now nftables
    sudo systemctl restart nftables
    sudo nft -f /etc/nftables.conf
}



setup_dns() {
    NETWORKMANAGER="/etc/NetworkManager"

    sudo systemctl enable --now NetworkManager.service 

    sudo stow --dir="$SCRIPT_CONFIG_FILES" --target="$NETWORKMANAGER/dispatcher.d" -D networkmanager
    sudo rm -rf "$NETWORKMANAGER/dispatcher.d/99-update-dns.sh" "$NETWORKMANAGER/dispatcher.d/99-update-hosts.sh"
    sudo stow --dir="$SCRIPT_CONFIG_FILES" --target="$NETWORKMANAGER/dispatcher.d" networkmanager

    sudo chown root:root /etc/NetworkManager/dispatcher.d/99-update-hosts.sh
    sudo chown root:root /etc/NetworkManager/dispatcher.d/99-update-dns.sh
    sudo chmod +x /etc/NetworkManager/dispatcher.d/99-update-dns.sh
    sudo chmod +x /etc/NetworkManager/dispatcher.d/99-update-hosts.sh 
}



main() {
    setup_ssh
    setup_nftables
    setup_dns
}
