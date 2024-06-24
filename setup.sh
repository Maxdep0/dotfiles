#!/bin/bash

DOWNLOADS=$HOME/Downloads
DOTFILES=$HOME/dotfiles
CONFIG="$HOME/.config"

## pacman discord, spotify

pac() { sudo pacman -S --needed --noconfirm "$@"; }
par() { paru -S --needed --noconfirm "$@"; }
ya() { yay -S --needed --noconfirm "$@"; }

cmd_check() { command -v "$1" >/dev/null 2>&1; }

setup_environment() {
    pac git stow

    mkdir -p "$HOME/Downloads"
    mkdir -p "$HOME/Documents"
    mkdir -p "$HOME/Pictures"
    mkdir -p "$HOME/Repository"
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

}

install_essential_packages() {
    pac base-devel cmake unzip ninja curl tree-sitter
    pac zsh wezterm
    pac python python-pip python-pynvim

    pac networkmanager network-manager-applet
    pac pulseaudio pulseaudio-alsa pulseaudio-jack pulseaudio-zeroconf
    pac pavucontrol pamixer playerctl acpi
    pac brightnessctl

    # screenshot tool
}

install_aux_tools() {
    if ! cmd_check yay; then
        git clone https://aur.archlinux.org/yay.git "$DOWNLOADS/yay"
        makepkg -si --needed --noconfirm -p "$DOWNLOADS/yay/PKGBUILD"
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
        makepkg -si -needed --noconfirm -p "$DOWNLOADS/paru/PKGBUILD"
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

install_proprietary_nvidia_drivers_for_sway() {
    pac nvidia-dmks nvidia-utils linux-headers
    par wlroots-nvidia

    sudo sed -i 's/^GRUB_CMDLINE_LINUX_DEFAULT="[^"]*"/GRUB_CMDLINE_LINUX_DEFAULT="loglevel=3 quiet rd.driver.blacklist=nouveau nvidia_drm.modeset=1"/' /etc/default/grub
    sudo grub-mkconfig -o /boot/grub/grub.cfg

    sudo sed -i 's/^MODULES=(.*)/MODULES=(nvidia nvidia_modeset nvidia_uvm nvidia_drm)/' /etc/mkinitcpio.conf
    sudo mkinitcpio -P
}

install_and_setup_neovim() {
    if [ ! -d "$DOWNLOADS/neovim" ]; then
        git clone https://github.com/neovim/neovim "$DOWNLOADS/neovim"
        make --directory="$DOWNLOADS/neovim" CMAKE_BUILD_TYPE=Release
        sudo make --directory="$DOWNLOADS/neovim" install
    fi
    if [ ! -d "$CONFIG/nvim" ]; then
        git clone https://github.com/Maxdep0/nvim.git "$CONFIG/nvim"
    fi

    nvm install 22
}

main() {
    sudo pacman -Syu --noconfirm
    # Call function in correct order
    # Call function in correct order
    # Call function in correct order

    fc-cache -rv
    sudo pacman -Syu --noconfirm

    sudo systemctl enable NetworkManager
    sudo systemctl start NetworkManager

    systemctl --user enable pulseaudio
    systemctl --user start pulseaudio

    sudo systemctl enable seatd

    sudo systemctl restart systemd-logind

    sudo usermod -aG video,wheel,seat "$USER"

    chsh -s "$(which zsh)"

    echo "Reboot PC"
}
