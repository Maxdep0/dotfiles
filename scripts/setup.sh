#!/usr/bin/bash

mkdir -pv "$HOME/logs"

export PATH="$HOME/.local/bin:/usr/local/bin:/usr/bin:$PATH"
export LOGS_DIR="$HOME/logs"
export SHELL=/usr/bin/zsh
export DOTFILES="$HOME/dotfiles"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_STATE_HOME="$HOME/.local/state"
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_BIN_HOME="$HOME/.local/bin"
export XDG_DATA_DIRS="/usr/local/share:/usr/share"
export XDG_CONFIG_DIRS="/etc/xdg"
export XDG_RUNTIME_DIR="/run/user/$UID"
export XDG_DOCUMENTS_DIR="$HOME/Documents"
export XDG_DOWNLOAD_DIR="$HOME/Downloads"
export XDG_PICTURES_DIR="$HOME/Pictures"
export XDG_VIDEOS_DIR="$HOME/Videos"
export XDG_MUSIC_DIR="$HOME/Videos"
export ZDOTDIR="$XDG_CONFIG_HOME/zsh"
export ZSH_PLUGINS_DIR="$XDG_DATA_HOME/zsh/plugins"
export HISTFILE="$ZDOTDIR/.zhistory"
export NVM_DIR="$HOME/.nvm"
SCRIPT_CONFIG_FILES="$HOME/dotfiles/scripts/configs"

timestamp=$(date +'%d-%m_%H-%M')
exec > >(tee -a "$LOGS_DIR/setup-output-$timestamp.log") 2>&1
log() { echo "$(date '+%H:%M:%S') - $1" >> "$LOGS_DIR/setup-error-$timestamp.log"; }

pac() { 
	for pkg in "$@"; do
	sudo pacman -S --needed --noconfirm "$pkg" || log "Pacman: Failed package: $pkg"
	done 
}

yayi() {
	for pkg in "$@"; do
	yay -S --needed --answerclean no --answerdiff n "$pkg" || log "Yay: Failed package: $pkg"
	done 
}


cmd_check() { command -v "$1" >/dev/null 2>&1; }
pac_check() { pacman -Qi "$1" &> /dev/null 2>&1; }


install_aux_tools() {
    if ! cmd_check yay; then
        git clone https://aur.archlinux.org/yay.git "$XDG_DOWNLOAD_DIR/yay" || log "git clone yay | $LINENO"
        cd "$XDG_DOWNLOAD_DIR/yay" && makepkg -si --needed --noconfirm || log "makepkg yay | $LINENO " && cd "$HOME"
        rm -rf "$XDG_DOWNLOAD_DIR/yay" || log "rm yay | $LINENO"
    fi

    if ! [ -d "$NVM_DIR" ]; then
        mkdir "$NVM_DIR"
        sudo curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash || log "sudo curl nvm instal.sh | $LINENO"
        [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" || log "source nvm.sh | $LINENO"
        [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion" || log "source bash_completion | $LINENO"
    fi

    if ! cmd_check paru; then
        git clone https://aur.archlinux.org/paru.git "$XDG_DOWNLOAD_DIR/paru" || log "git clone paru | $LINENO"
        cd "$XDG_DOWNLOAD_DIR/paru" && makepkg -si --needed --noconfirm || log "makepkg paru" && cd "$HOME"                                                          
        rm -rf "$XDG_DOWNLOAD_DIR/paru" || log "rm paru | $LINENO"
    fi
}

#
#
#

install_and_setup_neovim() {
    if [ ! -d "$XDG_DOWNLOAD_DIR/neovim" ] && ! cmd_check nvim; then
        git clone https://github.com/neovim/neovim "$XDG_DOWNLOAD_DIR/neovim" || log "git clone nvim | $LINENO"
        make --directory="$XDG_DOWNLOAD_DIR/neovim" CMAKE_BUILD_TYPE=Release || log "make CMAKE_BUILD neovim | $LINENO"
        sudo make --directory="$XDG_DOWNLOAD_DIR/neovim" install || log "sudo make neovim install | $LINENO"
        rm -rf "$XDG_DOWNLOAD_DIR/neovim"
    fi

    [ ! -d "$XDG_CONFIG_HOME/nvim" ] && git clone https://github.com/Maxdep0/nvim.git "$XDG_CONFIG_HOME/nvim" 
}


#
#
#

install_graphics_drivers() {

    # Tools to find compatible driver packages
    # pac libva-utils
    # pac vulkan-tools vdpauinfo clinfo
    # yayi vulkan-caps-viewer-wayland



    # INTEL
    pac mesa mesa-utils
    pac intel-media-driver intel-gpu-tools intel-compute-runtime
    pac vulkan-intel vulkan-mesa-layers
    yayi auto-cpufreq # Interactive install

    # NVIDIA
    # Beta 555+ nvidia drivers
    pac linux-headers
    yayi nvidia-beta-dkms nvidia-utils-beta nvidia-settings-beta opencl-nvidia-beta
    pac vulkan-icd-loader
    pac nvtop nvidia-prime 

    # wlroots-nvidia is not needed for 1 monitor
    # it reduces screen glitches for multi monitor setup
    paru -S wlroots-nvidia # Interactive install

    # grub 
    # nvidia-drm.fbdev=1 is experimental feature for 545+ drivers
    # It provides its own framebuffer console and replace efifb, vesafb
    sudo sed -i 's/^GRUB_CMDLINE_LINUX_DEFAULT="[^"]*"/GRUB_CMDLINE_LINUX_DEFAULT="loglevel=3 quiet rd.driver.blacklist=nouveau nvidia-drm.modeset=1 nvidia-drm.fbdev=1"/' "/etc/default/grub" || log "sudo sed grub_cmdline_linux_default | $LINENO"

    sudo grub-mkconfig -o /boot/grub/grub.cfg || log "sudo grub-mkconfig | $LINENO"

    # mkinitcpio
    sudo sed -i  \
        -e 's/^HOOKS=(.*)$/HOOKS=(base udev autodetect microcode modconf keyboard keymap consolefont block filesystems fsck)/' \
        -e 's/^MODULES=(.*)/MODULES=(i915 nvidia nvidia_modeset nvidia_uvm nvidia_drm)/' \
        "/etc/mkinitcpio.conf" || log_error "sudo sed HOOKS, MODULES | $LINENO"

    sudo mkinitcpio -P || log "sudo sudo mkinitcpio -P | $LINENO"

    sudo auto-cpufreq --install || log "sudo auto-cpufreq install | $LINENO"
}


#
#
#   

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
             "/etc/ssh/sshd_config" || log "sed sshd_config | $LINENO"
    fi
    sudo systemctl enable --now sshd || log "sudo sysctl enable --run sshd | $LINENO"
}

#
#
#

setup_nftables_config() {
    sudo stow --dir="$SCRIPT_CONFIG_FILES" --target="/etc" -D nftables || log "sudo stow -D nftables | $LINENO"
    [[ -f "/etc/nftables.conf" ]] && sudo mv "/etc/nftables.conf" "/etc/nftables.conf.bak" 
    sudo rm -rf "/etc/nftables.conf" || log "rm nftables.conf | $LINENO"
    sudo stow --dir="$SCRIPT_CONFIG_FILES" --target="/etc" nftables || log "sudo stow nftables | $LINENO"

    sudo systemctl enable --now nftables || log "sudi sysctl enable --now nftables | $LINENO"
    sudo systemctl restart nftables || log "sudo sysctl restart nftables | $LINENO"
    sudo nft -f /etc/nftables.conf || log "nft -f /etc/nftables.conf | $LINENO"
}


setup_reflector() {
    REFLECTOR='/etc/xdg/reflector'

    sudo stow --dir="$SCRIPT_CONFIG_FILES" --target="$REFLECTOR" -D reflector || log "sudo stow -D reflector | $LINENO"
    [[ -f "$REFLECTOR/reflector.conf" ]] && sudo mv "$REFLECTOR/reflector.conf" "$REFLECTOR/reflector.conf.bak"
    sudo rm -rf "$REFLECTOR/reflector.conf" || log "sudo rm reflector.conf | $LINENO"
    sudo stow --dir="$SCRIPT_CONFIG_FILES" --target="$REFLECTOR" reflector || log "sudo stop reflector | $LINENO"
}

#
#
#

setup_networkmanager() {
    NETWORKMANAGER="/etc/NetworkManager"

    sudo systemctl enable --now NetworkManager.service || log "sudo sysctl enable --now NetworkManager.service | $LINENO"

    sudo stow --dir="$SCRIPT_CONFIG_FILES" --target="$NETWORKMANAGER/dispatcher.d" -D networkmanager || log "sudo stow -D networkmanager | $LINENO"
    sudo rm -rf "$NETWORKMANAGER/dispatcher.d/99-update-dns.sh" "$NETWORKMANAGER/dispatcher.d/99-update-hosts.sh" || log "sudo rm 99-update-hosts.sh | $LINENO"
    sudo stow --dir="$SCRIPT_CONFIG_FILES" --target="$NETWORKMANAGER/dispatcher.d" networkmanager || log "sudo stow networkmanager | $LINENO"

    sudo chown root:root /etc/NetworkManager/dispatcher.d/99-update-hosts.sh || log "sudo chown 99-update-hosts.sh | $LINENO"
    sudo chown root:root /etc/NetworkManager/dispatcher.d/99-update-dns.sh || log "sudo chown 99-update-dns.sh | $LINENO"
    sudo chmod +x /etc/NetworkManager/dispatcher.d/99-update-dns.sh || log "sudo chmod 99-update-dns.sh | $LINENO"
    sudo chmod +x /etc/NetworkManager/dispatcher.d/99-update-hosts.sh || log "sudo chmod 99-update-hosts.sh | $LINENO"
}



main() {
    sudo pacman -Syu --noconfirm

    pac git stow openssh

    # Create folders
    mkdir -pv "$HOME/Downloads"
    mkdir -pv "$HOME/Documents"
    mkdir -pv "$HOME/Pictures/Background"
    mkdir -pv "$HOME/Projects"
    mkdir -pv "$HOME/Videos"
    mkdir -pv "$HOME/.config/zsh"


    # Stow config files
    stow --dir="$DOTFILES" -D gitconfig images satty sway waybar wezterm zsh wpaperd || log "stow -D .config | $LINENO"
    stow --dir="$DOTFILES" gitconfig images satty sway waybar wezterm zsh wpaperd || log "stow .config | $LINENO"

    # Essential packages
    pac base base-devel archlinux-keyring sudo nano

    # Development tools
    pac ninja curl cmake make wget curl tar unzip zip p7zip
    pac ripgrep fd fzf tree-sitter tree-sitter-cli bat
    pac python python-pip python-pynvim luarocks jdk-openjdk lua51

    # Shell / Terminal
    pac zsh wezterm

    # System utilities
    pac polkit nftables pacman-contrib reflector
    pac networkmanager network-manager-applet
    pac pulseaudio pulseaudio-alsa pulseaudio-jack
    pac pavucontrol pamixer playerctl 
    pac brightnessctl
    pac grim slurp
    pac mpv feh libreoffice-fresh #ranger
    pac acpi

    pac htop neofetch 

    # pac netcat conntrack-tools

    # Other
    pac discord firefox

    log "install_aux_tools | $LINENO"
    # Install nvm, yay, paru
    install_aux_tools

    nvm install 22 || log "nvm install 22 failed or already installed | $LINENO"
    # npm install --global yarn || log "install yarn"

    log "install_and_setup_neovim | $LINENO"
    install_and_setup_neovim

    # Install wayland
    pac wayland-protocols sway waybar wofi wpaperd xorg-server-xwayland

    log "install_graphics_drivers | $LINENO"
    # Install intel and prop nvidia drivers and nvidia-wsroots
    install_graphics_drivers

    log "setup_ssh | $LINENO"
    # Turn on port, change auth, etc..
    setup_ssh 

    log "setup_nftables_config | $LINENO"
    # Setup firewall, backtup original file and stow custom file
    setup_nftables_config

    log "setup_reflector | $LINENO"
    # Install reflector and stow custom config
    setup_reflector

    log "setup_networkmanager | $LINENO"
    # Stow script to update dns
    setup_networkmanager

    yay -S --needed --noconfirm clipman satty
    yay -S --needed spotify # Interactive install

    sudo pacman -Syu --noconfirm


    # Fonts
    pac ttf-dejavu ttf-liberation
    pac ttf-jetbrains-mono ttf-nerd-fonts-symbols-mono
    pac noto-fonts noto-fonts-emoji noto-fonts-extra
    fc-cache -rv

    # Add pacman colors
    sudo sed -i 's/^#*\s*Color\.*/Color/' "/etc/pacman.conf" || log "sudo sed pacman.conf | $LINENO"

    # Disable powerbutton so i can rebind it
    sudo sed -i 's/^#*\s*HandlePowerKey\s*=.*/HandlePowerKey=ignore/' /etc/systemd/logind.conf || log "sudo sed powerbutton | $LINENO"

    wpaperd -d || log "wraperd -d"
    
    systemctl --user enable --now pulseaudio || log "sysctl src enable --now pulseaudio | $LINENO"


    sudo systemctl enable --now reflector.timer || log "sudo sysctl enable --now reflector.timer | $LINENO"
    sudo systemctl enable --now NetworkManager || log "sudo sysctl enable --now network manager | $LINENO"
    sudo systemctl enable --now NetworkManager-dispatcher.service || log "sudo sysctl enable --now networkmanager-dispatcher.service | $LINENO"
    sudo systemctl enable --now seatd || log "sudo sysctl enable --now seatd | $LINENO"
    sudo systemctl enable --now paccache.timer || log "sudo sysctl enable --now paccache.timer | $LINENO"

    sudo usermod -aG video,wheel,seat "$USER" || log "sudo usermod -Ag | $LINENO"

    sudo systemctl restart nftables || log "sudo sysctl restart nftables | $LINENO"
    sudo systemctl restart sshd || log "sudo sysctl restart sshd | $LINENO"
    sudo systemctl restart systemd-logind || log "sudo sysctl restart systemd-logind | $LINENO"
    sudo systemctl daemon-reload || log "sudo sysctl daemon-reload | $LINENO"

    # Restart network connection
    sudo systemctl restart NetworkManager || log "sudo sysctl restart networkmanager | $LINENO"

    # Last.. because it needs password and sometimes the script just skip it
    sudo systemctl enable --now auto-cpufreq || log "sudo sysctl enable --now auto-cpufreq | $LINENO"

    rm -rf "$HOME/.bash_logout"
    rm -rf "$HOME/.bash_history"
    rm -rf "$HOME/.bash_profile"

   printf "\n\n DONE! REBOOT PC \n\n" 
}

# main


# call() {
#
# }
