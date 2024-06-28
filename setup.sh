#!/bin/bash
# https://www.youtube.com/watch?v=gIVIHJmW1P0

DOWNLOADS=$HOME/Downloads
DOTFILES=$HOME/dotfiles
CONFIG="$HOME/.config"


pac() { sudo pacman -S --needed --noconfirm "$@"; }
par() { paru -S --needed --noconfirm "$@"; }

cmd_check() { command -v "$1" >/dev/null 2>&1; }

setup_environment() {
    pac git stow

    mkdir -p "$HOME/Downloads"
    mkdir -p "$HOME/Documents"
    mkdir -p "$HOME/Pictures"
    mkdir -p "$HOME/Projects"
    mkdir -p "$HOME/Videos"
    mkdir -p "$HOME/.config"

    # Stow .gitconfig
    stow --dir="$DOTFILES" images
    stow --dir="$DOTFILES" sway
    stow --dir="$DOTFILES" waybar
    stow --dir="$DOTFILES" zsh
    stow --dir="$DOTFILES" wezterm
    stow --dir="$DOTFILES" htop
    stow --dir="$DOTFILES" ranger
    stow --dir="$DOTFILES" gitconfig

}

install_packages() {
    # Essentials
    pac base base-devel polkit sudo nano
    pac ninja curl cmake meson wget curl tar
    pac unzip zip p7zip
    pac git stow openssh
    pac ripgrep fd fzf tree-sitter
    pac zsh wezterm
    pac polkit

    # Additionals
    pac ranger htop neofetch
    pac firefox

    # System services and utils
    pac networkmanager network-manager-applet
    pac pulseaudio pulseaudio-alsa pulseaudio-jack pulseaudio-zeroconf
    pac pavucontrol pamixer playerctl acpi
    pac brightnessctl
    yay -S clipman

    pac discord


    yay -S --needed --noconfirm spotify


    pac man-db man-pages textinfo
    # screenshot tool

    # Languages
    pac python python-pip python-pynvim
    pac jdk-openjdk
    nvm install 22


    # Fonts
	pac noto-fonts noto-fonts-emoji noto-fonts-extra
	pac ttf-dejavu ttf-liberation
	pac ttf-jetbrains-mono ttf-nerd-fonts-symbols-mono



    ## Nothing
    # pac mpv

}

install_aux_tools() {
	pac curl unzip 
    if ! cmd_check yay; then
        git clone https://aur.archlinux.org/yay.git "$DOWNLOADS/yay"
        cd "$DOWNLOADS/yay" && makepkg -si --needed --noconfirm && cd "$HOME"
        rm -rf "$DOWNLOADS/yay"
    fi

    if ! cmd_check nvm; then
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

install_sway() {
    pac wayland-protocols sway swaybg swaylock waybar wofi

    # Disable laptop poweroff key
    sudo sed -i 's/^#*\s*HandlePowerKey\s*=.*/HandlePowerKey=ignore/' /etc/systemd/logind.conf
}

setup_pacman() {
    # Cache cleaning
    pac pacman-contrib

    sudo systemctl enable paccache.timer
    sudo systemctl start paccache.timer

    # Pacman Configuration
    PACMAN=/etc/pacman.conf 

    sudo sed -i 's/^#*\s*Color\.*/Color/' "$PACMAN"
    sudo sed -i 's/^#*\s*ParallelDownloads\s*=.*/ParallelDownloads = 5/' "$PACMAN"


}

install_and_setup_networkmanager() {
    pac networkmanager network-manager-applet

    sudo systemctl enable NetworkManager.service
    sudo systemctl start Networkmanager.service

    # DNS Configuration         https://www.dnsleaktest.com/ 
    set_dns() {
        local conn_name=$1
        local ipv4_dns_servers="8.8.8.8, 8.8.4.4"
        local ipv6_dns_servers="2001:4860:4860::8888, 2001:4860:4860::8844"

        # IPv4
        nmcli connection modify "$conn_name" ipv4.dns "$ipv4_dns_servers"
        nmcli connection modify "$conn_name" ipv4.ignore-auto-dns yes

        # IPv6
        nmcli connection modify "$conn_name" ipv6.dns "$ipv6_dns_servers"
        nmcli connection modify "$conn_name" ipv6.ignore-auto-dns yes

        nmcli connection up "$conn_name"

        echo "Servers for '$conn_name' set to IPv4: '$ipv4_dns_servers', IPv6: '$ipv6_dns_servers'"
    }


    ## TODO: Check wired connection
    active_connect=$( nmcli -t -f NAME,TYPE connection show --active | grep -v '^lo:' | awk -F':' '{print $1}')


    if [ -z "$active_connect" ]; then
        echo "No active connection"
        exit 1
    else
        echo "Active connection: $active_connect"
        set_dns "$active_connect"
    fi

    sudo ln -sf /run/NetworkManager/resolv.conf /etc/resolv.conf

    # Mirrors     https://wiki.archlinux.org/title/General_recommendations#Mirrors 
}


install_graphics_drivers22222() {

    pac clinfo 

    # INTEL
    pac mesa mesa-utils
    pac intel-media-driver intel-gpu-tools intel-compute-runtime
    pac vulkan-intel vulkan-mesa-layers
    pac libva-utils

    # https://wiki.archlinux.org/title/CPU_frequency_scaling#Userspace_tools

    # NVIDIA
    pac linux-headers
    yay -S --needed nvidia-beta-dkms nvidia-utils-beta nvidia-settings-beta opencl-nvidia-beta
    pac vulkan-icd-loader vulkan-tools
    yay -S --needed vulkan-caps-viewer-wayland
    pac nvtop nvidia-prime vdpauinfo
    par wlroots-nvidia

    # Grub
    GRUB=/etc/default/grub

    ## GRUB_CMDLINE_LINUX_DEFAULT
    sudo sed -i 's/^GRUB_CMDLINE_LINUX_DEFAULT="[^"]*"/GRUB_CMDLINE_LINUX_DEFAULT="loglevel=3 quiet rd.driver.blacklist=nouveau nvidia-drm.modeset=1 nvidia-drm.fbdev=1"/' "$GRUB"

    sudo grub-mkconfig -o /boot/grub/grub.cfg

    # mkinitcpio.conf
    MKINITCPIO=/etc/mkinitcpio.conf

    ## Hooks
    sudo sed -i 's/^HOOKS=(.*)$/HOOKS=(base udev autodetect microcode modconf keyboard keymap consolefont block filesystems fsck)/' "$MKINITCPIO"

    ## Modules
    sudo sed -i 's/^MODULES=(.*)/MODULES=(i915 nvidia nvidia_modeset nvidia_uvm nvidia_drm)/' "$MKINITCPIO"

    sudo mkinitcpio -P


}


install_and_setup_neovim() {
    pac luarocks lua51
    if [ ! -d "$DOWNLOADS/neovim" ]; then
        git clone https://github.com/neovim/neovim "$DOWNLOADS/neovim"
        make --directory="$DOWNLOADS/neovim" CMAKE_BUILD_TYPE=Release
        sudo make --directory="$DOWNLOADS/neovim" install
        rm -rf "$DOWNLOADS/neovim"
    fi
    if [ ! -d "$CONFIG/nvim" ]; then
        git clone https://github.com/Maxdep0/nvim.git "$CONFIG/nvim"
    fi

}

main() {
    # sudo pacman -Syu --noconfirm

	# setup_environment 2>&1 | tee "$HOME/setup_environment" 
	# install_aux_tools 2>&1 | tee "$HOME/install_aux_tools.log" 
	# install_packages 2>&1 | tee "$HOME/install_packages.log" 
	# install_and_setup_neovim 2>&1 | tee "$HOME/install_and_setup_neovim.log" 
	# install_sway 2>&1 | tee "$HOME/install_sway.log"
    # install_graphics_drivers 2>&1 | tee "$HOME/intel-media-driver.log" 
    # setup_pacman

    # fc-cache -rv
    # sudo pacman -Syu --noconfirm
    # 
    # sudo systemctl enable NetworkManager
    # sudo systemctl start NetworkManager
    #
    # systemctl --user enable pulseaudio
    # systemctl --user start pulseaudio
    #
    # sudo systemctl enable seatd
    #
    # sudo systemctl restart systemd-logind
    #
    # sudo usermod -aG video,wheel,seat "$USER"
    #
    # chsh -s "$(which zsh)"
    #
    # echo "Reboot PC"

    # su
    # [root@archlinux dotfiles]# pacman -Qdtq | pacman -Rs -
    # sudo pacman -Syu && sudo pacman -Sc
    # sudo pacman -Rns $(pacman -Qdtq)


}

main
