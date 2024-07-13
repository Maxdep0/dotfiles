#!/usr/bin/bash

# source "$SCRIPT_SETUP_DIR/env.sh"
source "$SCRIPT_SETUP_DIR/utils.sh"

#
# Packages
#

install_packages() {
    logger "⏳PACKAGES SETUP STARTED"

    if if_not_installed_then_install base base-devel archlinux-keyring sudo vim \
        ninja curl cmake make wget curl tar unzip zip p7zip \
        ripgrep fd fzf tree-sitter tree-sitter-cli bat \
        python python-pip python-pynvim luarocks jdk-openjdk lua51 \
        polkit brightnessctl grim slurp network-manager-applet \
        mpv feh libreoffice-fresh acpi htop tree \
        neofetch discord firefox zsh wezterm \
	    noto-fonts noto-fonts-emoji noto-fonts-extra \
	    ttf-dejavu ttf-liberation ttf-jetbrains-mono ttf-nerd-fonts-symbols-mono; then
        logger "✅ PACKAGES SETUP DONE"
        return 0
        echo "OK"

    fi

    logger "🔴 PACKAGES SETUP FAILED"
    return 1
}

#
# Aux Tools
#

install_aux_tools() {
    logger "⏳AUX TOOLS SETUP STARTED"

    install_nvm() {
        if [ ! -d "$NVM_DIR" ]; then
            mkdir "$NVM_DIR"
            if ! sudo curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash; then
                logger "Failed to install nvm."
                return 1
            fi
        else
            logger "nvm already installed."
            return 0
        fi
        return 0
    }

    if if_not_installed_then_install curl; then
        if clone_makepkg https://aur.archlinux.org/yay.git; then
            if clone_makepkg https://aur.archlinux.org/paru.git; then
                if install_nvm; then
                    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
                    if nvm install node; then
                        logger "✅ AUX TOOLS SETUP DONE"
                        return 0
                    else
                        logger "Failed to install node"
                        return 1
                    fi

                fi
            fi
        fi
    fi

    logger "🔴 AUX TOOLS SETUP FAILED"
    return 1
}

#
# Audio
#

install_and_setup_audio() {
    logger "⏳AUDIO SETUP STARTED"

    if if_not_installed_then_install pulseaudio pulseaudio-alsa pulseaudio-jack; then
        if if_not_installed_then_install pavucontrol pamixer playerctl; then
            if systemctl --user enable --now pulseaudio; then
                logger "✅ AUDIO SETUP DONE"
                return 0
            fi
        fi
    fi

    logger "🔴 AUDIO SETUP FAILED"
    return 1

}

### SYSTEM
 disable_powerbutton() {
     if ! sudo sed -i 's/^#*\s*HandlePowerKey\s*=.*/HandlePowerKey=ignore/' \
         /etc/systemd/logind.conf; then
             logger "Failed to update logind.conf"
             return 1
     fi
     return 0
 }

#
# Neovim
#

install_and_setup_neovim() {
    logger "⏳NEOVIM SETUP STARTED"

    install_neovim() {
        if [ ! -d "$XDG_DOWNLOAD_DIR/neovim" ] && ! cmd_check nvim; then
            git clone https://github.com/neovim/neovim "$XDG_DOWNLOAD_DIR/neovim"
            make --directory="$XDG_DOWNLOAD_DIR/neovim" CMAKE_BUILD_TYPE=Release
            sudo make --directory="$XDG_DOWNLOAD_DIR/neovim" install
            rm -rf "$XDG_DOWNLOAD_DIR/neovim"

            logger "Successfully installed neovim."
            return 0
        fi
    }

    clone_config() {
        if [ ! -d "$XDG_CONFIG_HOME/nvim" ]; then
            git clone https://github.com/Maxdep0/nvim.git "$XDG_CONFIG_HOME/nvim"

            logger "Successfully cloned nvim."
            return 0
        else
            logger "nvim config already exits."
            return 0
        fi
    }

    if install_neovim; then
        if clone_config; then
            logger "✅ NEOVIM SETUP DONE"
            return 0
        fi
    fi

    logger "🔴 NEOVIM SETUP FAILED"
    return 1
}

#
# Wayland
#

install_and_setup_wayland() {
    logger "⏳WAYLAND SETUP STARTED"

    if if_not_installed_then_install wayland-protocols sway xorg-server-xwayland; then
        if if_not_installed_then_install wpaperd waybar wofi; then
            logger "✅ WAYLAND SETUP DONE"
            return 0
        fi
    fi

    logger "🔴 WAYLAND SETUP FAILED"
    return 1
}

#
# Intel Drivers
#

install_intel_drivers() {
    logger "⏳INTEL DRIVERS SETUP STARTED"

    if if_not_installed_then_install mesa mesa-utils; then
        if if_not_installed_then_install intel-media-driver intel-gpu-tools intel-compute-runtime; then
            if if_not_installed_then_install vulkan-intel vulkan-mesa-layers; then
                sudo auto-cpufreq --install
                logger "✅ INTEL DRIVERS SETUP DONE"
                return 0
            fi
        fi
    fi

    logger "🔴 INTEL DRIVERS SETUP FAILED"
    return 1
}

#
# Nvidia Drivers
#

install_nvidia_drivers() {
    logger "⏳NVIDIA DRIVERS SETUP STARTED"

    update_grub() {
        # grub
        # nvidia-drm.fbdev=1 is experimental feature for 545+ drivers
        # It provides its own framebuffer console and replace efifb, vesafb
        if sudo sed -i 's/^GRUB_CMDLINE_LINUX_DEFAULT="[^"]*"/GRUB_CMDLINE_LINUX_DEFAULT="loglevel=3 quiet rd.driver.blacklist=nouveau nvidia-drm.modeset=1 nvidia-drm.fbdev=1"/' \
            "/etc/default/grub"; then
            sudo grub-mkconfig -o /boot/grub/grub.cfg

            logger "Successfully updated grub."
            return 0
        fi

        logger "Failed to update grub."
    }

    update_mkinitcpio() {
        if sudo sed -i \
            -e 's/^HOOKS=(.*)$/HOOKS=(base udev autodetect microcode modconf keyboard keymap consolefont block filesystems fsck)/' \
            -e 's/^MODULES=(.*)/MODULES=(i915 nvidia nvidia_modeset nvidia_uvm nvidia_drm)/' \
            "/etc/mkinitcpio.conf"; then

            sudo mkinitcpio -P
            logger "Successfully updated mkinitcpio."
            return 0

        fi
        logger "Failed to update mkinitcpio."
    }

    if if_not_installed_then_install_yay nvidia-beta-dkms nvidia-utils-beta nvidia-settings-beta opencl-nvidia-beta; then
        if if_not_installed_then_install linux-headers vulkan-icd-loader nvidia-prime nvtop; then
            if update_grub; then
                if update_mkinitcpio; then
                    if paru -S wlroots-nvidia; then
                        logger "✅ NVIDIA DRIVERS SETUP DONE"
                        return 0
                    fi
                fi
            fi

        fi
    fi

    logger "🔴 NVIDIA DRIVERS SETUP FAILED"
    return 1
}

add () {
	# yay clipman satty
	#
}

main() {
    logger "⏳⏳ BASE SETUP STARTED"

    if install_packages; then
	    if disable_powerbutton; then
        if install_aux_tools; then
            if install_and_setup_audio; then
                if install_and_setup_neovim; then
                    if install_and_setup_wayland; then
                        if install_intel_drivers; then
                            if install_nvidia_drivers; then
                                logger "✅✅ BASE SETUP DONE"
				yay -S --needed --noconfirm clipman satty
                                return 0
                            fi
                        fi
                    fi
                fi
	    fi
            fi
        fi
    fi

    logger "🔴🔴 BASE SETUP FAILED"
    return 1
}

main
