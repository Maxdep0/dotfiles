#!/bin/bash


pac() {
    local packages=("$@")
    sudo pacman -S --needed --noconfirm "${packages[@]}"
}

cmd_exists() {
    command -v "$1" >/dev/null 2>&1
}

mkdir -p $HOME/Downloads
mkdir -p $HOME/Documents
mkdir -p $HOME/Pictures
mkdir -p $HOME/Repository
mkdir -p $HOME/Videos
mkdir -p $HOME/.config

DOTFILES_DIR="$HOME/dotfiles"
CONFIG_DIR="$HOME/.config"

install_yay() {
    echo "↙️↙️↙️↙️↙️↙️↙️↙️↙️↙️ YAY ↙️↙️↙️↙️↙️↙️↙️↙️↙️↙️"
    if ! cmd_exists yay; then
        cd "$HOME/Downloads"
        git clone https://aur.archlinux.org/yay.git
        cd yay
        makepkg -si
        cd .. && rm -rf yay && cd "$HOME"
    fi
}

install_nvm() {
    echo "↙️↙️↙️↙️↙️↙️↙️↙️↙️↙️ NVM ↙️↙️↙️↙️↙️↙️↙️↙️↙️↙️"

    if ! cmd_exists nvm; then
        sudo curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
        export NVM_DIR="$HOME/.nvm"
        [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
        [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
    fi
}

install_system_services_and_utils() {
    echo "↙️↙️↙️↙️↙️↙️↙️↙️↙️↙️ SERVICES AND UTILS ↙️↙️↙️↙️↙️↙️↙️↙️↙️↙️"

    # NetworkManager
    pac networkmanager network-manager-applet

    sudo systemctl enable NetworkManager
    sudo systemctl start NetworkManager


    # PulseAudio
    pac pulseaudio pulseaudio-alsa pulseaudio-jack pulseaudio-zeroconf
    pac pavucontrol pamixer playerctl acpi

    systemctl --user enable pulseaudio
    systemctl --user start pulseaudio

    # Brightness
    pac brightnessctl


}


install_sway() {
    echo "↙️↙️↙️↙️↙️↙️↙️↙️↙️↙️ SWAY ↙️↙️↙️↙️↙️↙️↙️↙️↙️↙️"

    pac wayland-protocols sway swaybg swaylock waybar wofi


    # Disable laptop poweroff key
    sudo sed -i 's/^#*\s*HandlePowerKey\s*=.*/HandlePowerKey=ignore/' /etc/systemd/logind.conf
    sudo systemctl restart systemd-logind
}


install_neovim() {
    echo "↙️↙️↙️↙️↙️↙️↙️↙️↙️↙️ NEOVIM ↙️↙️↙️↙️↙️↙️↙️↙️↙️↙️"

    cd "$HOME/Downloads"
    sudo curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux64.tar.gz
    sudo rm -rf /opt/nvim
    sudo tar -C /opt -xzf nvim-linux64.tar.gz

    sudo ln -s /opt/nvim-linux64/bin/nvim /usr/local/bin/nvim

    rm -fr nvim-linux64.tar.gz && cd "$HOME"


    if [ ! -d "$CONFIG_DIR/nvim" ]; then
        git clone https://github.com/Maxdep0/nvim.git "$CONFIG_DIR/nvim"
    fi

    pac python python-pip python-pynvim
    nvm install 22

}

install_proprietary_nvidia_drivers() {
    echo "↙️↙️↙️↙️↙️↙️↙️↙️↙️↙️ NVIDIA ↙️↙️↙️↙️↙️↙️↙️↙️↙️↙️"

    pac nvidia-dkms nvidia-utils linux-headers

    if ! cmd_exists paru; then
        cd $HOME/Downloads
        git clone https://aur.archlinux.org/paru.git

        cd paru
        makepkg -si
        paru -S wlroots-nvidia
        cd .. && rm -rf paru && cd "$HOME"

    fi

    # grub
    sudo sed -i 's/^GRUB_CMDLINE_LINUX_DEFAULT="[^"]*"/GRUB_CMDLINE_LINUX_DEFAULT="loglevel=3 quiet rd.driver.blacklist=nouveau nvidia_drm.modeset=1"/' /etc/default/grub
    sudo sed -i 's/^#GRUB_DISABLE_OS_PROBER=false/GRUB_DISABLE_OS_PROBER=false/' /etc/default/grub
    sudo grub-mkconfig -o /boot/grub/grub.cfg

    # mkinitcpio
    sudo sed -i 's/^MODULES=(.*)/MODULES=(nvidia nvidia_modeset nvidia_uvm nvidia_drm)/' /etc/mkinitcpio.conf
    sudo mkinitcpio -P
}

install_shell_and_terminal() {
    echo "↙️↙️↙️↙️↙️↙️↙️↙️↙️↙️ SHELL AND TERMINAL ↙️↙️↙️↙️↙️↙️↙️↙️↙️↙️"

    pac zsh wezterm

    if ! cmd_exists oh-my-posh; then
        sudo curl -s https://ohmyposh.dev/install.sh | sudo bash -s
    fi
}

install_packages() {
    echo "↙️↙️↙️↙️↙️↙️↙️↙️↙️↙️ PACKAGES ↙️↙️↙️↙️↙️↙️↙️↙️↙️↙️"

    sudo pacman -Syu
    
    pac base base-devel zsh curl wget cmake sudo polkit unzip zip p7zip tar
    pac git openssh ripgrep fd fzf man-db man-pages mpv ranger htop neofetch
    pac ttf-dejavu noto-fonts ttf-ubuntu-font-family ttf-fira-code ttf-liberation
    pac ttf-ms-win10 noto-fonts-emoji ttf-symbola
    pac ttf-nerd-fonts-symbols ttf-nerd-fonts-symbols-mono ttf-nerd-fonts-symbols-common
    pac ttf-jetbrains-mono-nerd

    pac firefox

    install_yay
    yay -S --needed --noconfirm clipman
}

install_and_setup_stow() {
    echo "↙️↙️↙️↙️↙️↙️↙️↙️↙️↙️ STOW SETUP ↙️↙️↙️↙️↙️↙️↙️↙️↙️↙️"

    pac stow

    stow --dir="$DOTFILES_DIR" images
    stow --dir="$DOTFILES_DIR" sway
    stow --dir="$DOTFILES_DIR" waybar
    stow --dir="$DOTFILES_DIR" zsh
    stow --dir="$DOTFILES_DIR" wezterm
    stow --dir="$DOTFILES_DIR" htop
    stow --dir="$DOTFILES_DIR" ranger
}

main() {
    install_and_setup_stow
    install_packages
    install_system_services_and_utils
    install_shell_and_terminal
    install_nvm
    install_neovim
    install_sway
    install_proprietary_nvidia_drivers

    sudo pacman -Syu

    sudo systemctl enable seatd
    sudo usermod -aG video,wheel,seat "$USER"

    chsh -s "$(which zsh)"

    zsh

    echo "Reboot your PC"

}

main



