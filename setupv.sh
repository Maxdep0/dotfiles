#!/usr/bin/bash

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
export HISTFILE="$XDG_CACHE_HOME/zsh/.zhistory"
export NVM_DIR="$HOME/.nvm"
SCRIPT_CONFIG_FILES="$HOME/dotfiles/scripts/configs"

timestamp=$(date +'%m-%d_%H-%M')
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
        git clone https://aur.archlinux.org/yay.git "$XDG_DOWNLOAD_DIR/yay" || log "clone yay"
        cd "$XDG_DOWNLOAD_DIR/yay" && makepkg -si --needed --noconfirm || log "makepkg yay" && cd "$HOME"
        rm -rf "$XDG_DOWNLOAD_DIR/yay" || log "rm yay"
    fi

    if ! [ -d "$NVM_DIR" ]; then
        mkdir "$NVM_DIR"
        sudo curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash || log "curl nvm"
        [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" || log "source nvm"
        [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion" || log "source bash comp"
    fi

    if ! cmd_check paru; then
        git clone https://aur.archlinux.org/paru.git "$XDG_DOWNLOAD_DIR/paru" || log "clone paru"
        cd "$XDG_DOWNLOAD_DIR/paru" && makepkg -si --needed --noconfirm || log "makepkg paru" && cd "$HOME"                                                          
        rm -rf "$XDG_DOWNLOAD_DIR/paru" || log "rm paru"
    fi
}

#
#
#

install_and_setup_neovim() {
    if [ ! -d "$XDG_DOWNLOAD_DIR/neovim" ] && ! cmd_check nvim; then
        git clone https://github.com/neovim/neovim "$XDG_DOWNLOAD_DIR/neovim" || log "clone nvim"
        make --directory="$XDG_DOWNLOAD_DIR/neovim" CMAKE_BUILD_TYPE=Release || log "make neovim cmake"
        sudo make --directory="$XDG_DOWNLOAD_DIR/neovim" install || log "make neovim install"
        rm -rf "$XDG_DOWNLOAD_DIR/neovim"
    fi

    [ ! -d "$XDG_CONFIG_HOME/nvim" ] && git clone https://github.com/Maxdep0/nvim.git "$XDG_CONFIG_HOME/nvim" 
}


#
#
#

install_graphics_drivers() {

    # Tools to find compatible driver packages
    # pac mesa-utils libva-utils
    # pac vulkan-tools vdpauinfo clinfo
    # pac vulkan-mesa-layers
    # yayi vulkan-caps-viewer-wayland


    # INTEL
    pac mesa
    pac intel-media-driver intel-gpu-tools intel-compute-runtime
    pac vulkan-intel 
    yayi auto-cpufreq # Interactive install

    # NVIDIA
    # Beta 555+ nvidia drivers
    pac linux-headers
    yayi nvidia-beta-dkms nvidia-utils-beta nvidia-settings-beta opencl-nvidia-beta
    pac vulkan-icd-loader
    pac nvtop nvidia-prime 

    # wlroots-nvidia is not needed for 1 monitor
    # it reduces screen glitches for multi monitor setup
    paru -S --removemake --cleanafter --noupgrademenu --skipreview --install wlroots-nvidia # Interactive install

    # grub 
    # nvidia-drm.fbdev=1 is experimental feature for 545+ drivers
    # It provides its own framebuffer console and replace efifb, vesafb
    sudo sed -i 's/^GRUB_CMDLINE_LINUX_DEFAULT="[^"]*"/GRUB_CMDLINE_LINUX_DEFAULT="loglevel=3 quiet rd.driver.blacklist=nouveau nvidia-drm.modeset=1 nvidia-drm.fbdev=1"/' "/etc/default/grub" || log "sed grub_cmdline_linux_default"

    sudo grub-mkconfig -o /boot/grub/grub.cfg || log "grub-mkconfig"

    # mkinitcpio
    sudo sed -i  \
        -e 's/^HOOKS=(.*)$/HOOKS=(base udev autodetect microcode modconf keyboard keymap consolefont block filesystems fsck)/' \
        -e 's/^MODULES=(.*)/MODULES=(i915 nvidia nvidia_modeset nvidia_uvm nvidia_drm)/' \
        "/etc/mkinitcpio.conf" || log_error "sed HOOKS, MODULES"

    sudo mkinitcpio -P || log "sudo mkinitcpio -P"

    sudo auto-cpufreq --install || log "sudo auto-cpufreq install"
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
             "/etc/ssh/sshd_config" || log "sed sshd_config"
    fi
    sudo systemctl enable --now sshd || log "sysctl enable sshd"
}

#
#
#

setup_nftables_config() {
    sudo stow --dir="$SCRIPT_CONFIG_FILES" --target="/etc" -D nftables || log "stow -d script config files"
    [[ -f "/etc/nftables.conf" ]] && sudo mv "/etc/nftables.conf" "/etc/nftables.conf.bak" 
    sudo rm -rf "/etc/nftables.conf" || log "rm nftables.conf"
    sudo stow --dir="$SCRIPT_CONFIG_FILES" --target="/etc" nftables || log "stow script config files"

    sudo systemctl enable --now nftables || log "sysctl enable nftables"
    sudo systemctl restart nftables || log "sysctl restart nftables"
    sudo nft -f /etc/nftables.conf || log "nft load config"
}


setup_reflector() {
    REFLECTOR='/etc/xdg/reflector'

    sudo stow --dir="$SCRIPT_CONFIG_FILES" --target="$REFLECTOR" -D reflector || log "stow -D reflector"
    [[ -f "$REFLECTOR/reflector.conf" ]] && sudo mv "$REFLECTOR/reflector.conf" "$REFLECTOR/reflector.conf.bak"
    sudo rm -rf "$REFLECTOR/reflector.conf" || log "rm reflector.conf"
    sudo stow --dir="$SCRIPT_CONFIG_FILES" --target="$REFLECTOR" reflector || log "stow reflector"
}

#
#
#

setup_networkmanager() {
    NETWORKMANAGER="/etc/NetworkManager"

    sudo systemctl enable --now NetworkManager.service || log "sysctl enable NetworkManager.service"

    sudo stow --dir="$SCRIPT_CONFIG_FILES" --target="$NETWORKMANAGER/dispatcher.d" -D networkmanager || log "stow -D networkmanager"
    sudo rm -rf "$NETWORKMANAGER/dispatcher.d/99-update-dns.sh" "$NETWORKMANAGER/dispatcher.d/99-update-hosts.sh" || log "rm 99-update-hosts.sh"
    sudo stow --dir="$SCRIPT_CONFIG_FILES" --target="$NETWORKMANAGER/dispatcher.d" networkmanager || log "stow networkmanager"

    sudo chown root:root /etc/NetworkManager/dispatcher.d/99-update-hosts.sh || log "chown 99-update-hosts.sh"
    sudo chown root:root /etc/NetworkManager/dispatcher.d/99-update-dns.sh || log "chown 99-update-dns.sh"
    sudo chmod +x /etc/NetworkManager/dispatcher.d/99-update-dns.sh || log "chmod 99-update-dns.sh"
    sudo chmod +x /etc/NetworkManager/dispatcher.d/99-update-hosts.sh || log "chmod 99-update-hosts.sh"
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
    mkdir -pv "$HOME/logs"
    mkdir -pv "$HOME/.config/zsh"


    # Stow config files
    stow --dir="$DOTFILES" -D gitconfig images satty sway waybar wezterm zsh wpaperd || log "stow .config"
    stow --dir="$DOTFILES" gitconfig images satty sway waybar wezterm zsh wpaperd || log "stow .config"

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


    # Install nvm, yay, paru
    install_aux_tools

    nvm install 22 || log "nvm install 22 failed or already installed"
    # npm install --global yarn || log "install yarn"

    install_and_setup_neovim

    # Install wayland
    pac wayland-protocols sway waybar wofi wpaperd

    # Install intel and prop nvidia drivers and nvidia-wsroots
    install_graphics_drivers

    # Turn on port, change auth, etc..
    setup_ssh

    # Setup firewall, backtup original file and stow custom file
    setup_nftables_config

    # Install reflector and stow custom config
    setup_reflector

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
    sudo sed -i 's/^#*\s*Color\.*/Color/' "/etc/pacman.conf" || log "sed pacman.conf"

    # Disable powerbutton so i can rebind it
    sudo sed -i 's/^#*\s*HandlePowerKey\s*=.*/HandlePowerKey=ignore/' /etc/systemd/logind.conf || log "sed powerbutton"

    wpaperd -d || log "wraperd -d"
    
    systemctl --user enable --now pulseaudio || log "sysctl enable pulseaudio"


    sudo systemctl enable --now reflector.timer || log "sysctl enable reflector.timer"
    sudo systemctl enable --now NetworkManager || log "sysctl enable network manager"
    sudo systemctl enable --now NetworkManager-dispatcher.service || log "sysctl enable networkmanager-dispatcher.service"
    sudo systemctl enable --now seatd || log "sysctl enable seatd"
    sudo systemctl enable --now paccache.timer || log "sysctl enable paccache.timer"

    sudo usermod -aG video,wheel,seat "$USER" || log "usermod -Ag"

    sudo systemctl restart nftables || log "sysctl restart nftables"
    sudo systemctl restart sshd || log "sysctl restart sshd"
    sudo systemctl restart systemd-logind || log "sysctl restart systemd-logind"
    sudo systemctl daemon-reload || log "sysctl daemon-reload"

    # Restart network connection
    sudo systemctl restart NetworkManager || log "sysctl restart networkmanager"

    # Last.. because it needs password and sometimes the script just skip it
    sudo systemctl enable --now auto-cpufreq || log "sysctl enable auto-cpufreq"

    rm -rf "$HOME/.bash_logout"
    rm -rf "$HOME/.bash_history"
    rm -rf "$HOME/.bash_profile"

   printf "\n\n DONE! REBOOT PC \n\n" 
}

main
