#!/bin/bash

CONFIG_FILES="$HOME/dotfiles/scripts/configs"

DOWNLOADS=$HOME/Downloads
DOTFILES=$HOME/dotfiles
CONFIG="$HOME/.config"


pac() { sudo pacman -S --needed --noconfirm "$@"; }
# par() { paru -S --needed --noconfirm "$@"; }
cmd_check() { command -v "$1" >/dev/null 2>&1; }

install_aux_tools() {
    if ! cmd_check yay; then
        git clone https://aur.archlinux.org/yay.git "$DOWNLOADS/yay"
        cd "$DOWNLOADS/yay" && makepkg -si --needed --noconfirm && cd "$HOME"
        rm -rf "$DOWNLOADS/yay"
    fi

    if ! [ -d "$HOME/.nvm" ]; then
        sudo curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
        export NVM_DIR="$HOME/.nvm"
        [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
        [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
    fi

    if ! cmd_check paru; then
        git clone https://aur.archlinux.org/paru.git "$DOWNLOADS/paru"
        cd "$DOWNLOADS/paru" && makepkg -si --needed --noconfirm && cd "$HOME"
        rm -rf "$DOWNLOADS/paru"
    fi

    if ! cmd_check oh-my-posh; then
        sudo curl -s https://ohmyposh.dev/install.sh | sudo bash -s
    fi
}

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

setup_nftables_config() {
    sudo stow --dir="$CONFIG_FILES" --target="/etc" -D nftables
    [[ -f "/etc/nftables.conf" ]] && sudo mv "/etc/nftables.conf" "/etc/nftables.conf.bak"
    sudo rm -rf "/etc/nftables.conf"
    sudo stow --dir="$CONFIG_FILES" --target="/etc" nftables

    sudo systemctl enable --now nftables
    sudo systemctl restart nftables
    sudo nft -f /etc/nftables.conf
}


setup_networkmanager() {
    NETWORKMANAGER="/etc/NetworkManager"

    sudo systemctl enable --now NetworkManager.service

    sudo stow --dir="$CONFIG_FILES" --target="$NETWORKMANAGER/dispatcher.d" -D networkmanager
    sudo rm -rf "$NETWORKMANAGER/dispatcher.d/99-update-dns.sh" "$NETWORKMANAGER/dispatcher.d/99-update-hosts.sh"
    sudo stow --dir="$CONFIG_FILES" --target="$NETWORKMANAGER/dispatcher.d" networkmanager

    sudo chown root:root /etc/NetworkManager/dispatcher.d/99-update-hosts.sh
    sudo chown root:root /etc/NetworkManager/dispatcher.d/99-update-dns.sh
    sudo chmod +x /etc/NetworkManager/dispatcher.d/99-update-dns.sh
    sudo chmod +x /etc/NetworkManager/dispatcher.d/99-update-hosts.sh
}

setup_reflector() {
    REFLECTOR='/etc/xdg/reflector'

    sudo stow --dir="$CONFIG_FILES" --target="$REFLECTOR" -D reflector
    [[ -f "$REFLECTOR/reflector.conf" ]] && sudo mv "$REFLECTOR/reflector.conf" "$REFLECTOR/reflector.conf.bak"
    sudo rm -rf "$REFLECTOR/reflector.conf"
    sudo stow --dir="$CONFIG_FILES" --target="$REFLECTOR" reflector
}


install_graphics_drivers() {

    # INTEL
    pac mesa mesa-utils
    pac intel-media-driver intel-gpu-tools intel-compute-runtime
    pac vulkan-intel vulkan-mesa-layers
    pac libva-utils
    yay -S --needed auto-cpufreq # Interactive install

    # NVIDIA
    pac linux-headers
    yay -S --needed nvidia-beta-dkms nvidia-utils-beta nvidia-settings-beta opencl-nvidia-beta
    pac vulkan-icd-loader vulkan-tools
    yay -S --needed vulkan-caps-viewer-wayland
    pac nvtop nvidia-prime vdpauinfo clinfo
    paru -S --needed wlroots-nvidia # Interactive install

    ## grub
    sudo sed -i 's/^GRUB_CMDLINE_LINUX_DEFAULT="[^"]*"/GRUB_CMDLINE_LINUX_DEFAULT="loglevel=3 quiet rd.driver.blacklist=nouveau nvidia-drm.modeset=1 nvidia-drm.fbdev=1"/' "/etc/default/grub"

    sudo grub-mkconfig -o /boot/grub/grub.cfg

    # mkinitcpio
    sudo sed -i  \
        -e 's/^HOOKS=(.*)$/HOOKS=(base udev autodetect microcode modconf keyboard keymap consolefont block filesystems fsck)/' \
        -e 's/^MODULES=(.*)/MODULES=(i915 nvidia nvidia_modeset nvidia_uvm nvidia_drm)/' \
        "/etc/mkinitcpio.conf"

    sudo mkinitcpio -P

    systemctl enable --now auto-cpufreq
}

install_and_setup_neovim() {
    if [ ! -d "$DOWNLOADS/neovim" ]; then
        git clone https://github.com/neovim/neovim "$DOWNLOADS/neovim"
        make --directory="$DOWNLOADS/neovim" CMAKE_BUILD_TYPE=Release
        sudo make --directory="$DOWNLOADS/neovim" install
        rm -rf "$DOWNLOADS/neovim"
    fi

    [ ! -d "$CONFIG/nvim" ] && git clone https://github.com/Maxdep0/nvim.git "$CONFIG/nvim" 
}



main() {
    sudo pacman -Syu --noconfirm

    pac git stow openssh

    mkdir -p "$HOME/Downloads" "$HOME/Documents" "$HOME/Pictures" "$HOME/Projects" "$HOME/Videos" "$HOME/.config"

    stow --dir="$DOTFILES" gitconfig htop images satty sway waybar wezterm zsh #ranger

    pac base base-devel archlinux-keyring polkit sudo nano firefox
    pac ninja curl cmake meson wget curl tar unzip zip p7zip
    pac ripgrep fd fzf tree-sitter
    pac zsh wezterm
    pac polkit nftables netcat conntrack-tools pacman-contrib
    pac networkmanager network-manager-applet reflector
    pac pulseaudio pulseaudio-alsa pulseaudio-jack pulseaudio-zeroconf
    pac pavucontrol pamixer playerctl acpi
    pac brightnessctl
    pac python python-pip python-pynvim luarocks jdk-openjdk lua51
    pac ranger htop neofetch
   # pac firefox
    pac noto-fonts noto-fonts-emoji noto-fonts-extra
    pac ttf-dejavu ttf-liberation
    pac ttf-jetbrains-mono ttf-nerd-fonts-symbols-mono
    pac discord

    pac mpv feh
	

    pac grim slurp


    setup_reflector
    setup_networkmanager
    install_aux_tools

    nvm install 22
    yay -S --needed --noconfirm clipman satty
    yay -S --needed spotify # Interactive install

    install_and_setup_neovim
    setup_ssh
    setup_nftables_config

    pac wayland-protocols sway swaybg swaylock waybar wofi


    install_graphics_drivers

    sudo pacman -Syu --noconfirm
   
    fc-cache -rv

    sudo sed -i 's/^#*\s*Color\.*/Color/' "/etc/pacman.conf"
    sudo sed -i 's/^#*\s*HandlePowerKey\s*=.*/HandlePowerKey=ignore/' /etc/systemd/logind.conf

    
    sudo systemctl --user enable --now pulseaudio

    sudo systemctl enable --now reflector.timer
    sudo systemctl enable --now NetworkManager
    sudo systemctl enable --now NetworkManager-dispatcher.service
    sudo systemctl enable --now seatd
    sudo systemctl enable --now paccache.timer

    sudo usermod -aG video,wheel,seat "$USER"

    sudo systemctl restart nftables
    sudo systemctl restart sshd
    sudo systemctl restart systemd-logind
    sudo systemctl daemon-reload


    sudo systemctl restart NetworkManager

    chsh -s "$(which zsh)"

   printf "\n\n DONE! REBOOT PC \n\n" 

}

main
