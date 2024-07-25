#!/usr/bin/bash

source "$SCRIPT_SETUP_DIR/env.sh"
source "$SCRIPT_SETUP_DIR/utils.sh"

#
# Wayland
#

install_and_setup_wayland() {
    logger "⏳WAYLAND SETUP STARTED"

    if_not_installed_then_install wayland-protocols hyprland xorg-server-xwayland || return 1
    if_not_installed_then_install wpaperd waybar wofi || return 1

    logger "✅ WAYLAND SETUP DONE"
    return 0
}

#
# Intel Drivers
#

install_intel_drivers() {
    logger "⏳INTEL DRIVERS SETUP STARTED"

    if_not_installed_then_install mesa mesa-utils || return 1
    if_not_installed_then_install intel-media-driver intel-gpu-tools intel-compute-runtime || return 1
    if_not_installed_then_install vulkan-intel vulkan-mesa-layers || return 1

    yay -S --needed auto-cpufreq
    sudo auto-cpufreq --install

    logger "✅ INTEL DRIVERS SETUP DONE"
    return 0
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
        if sudo sed -i 's/^GRUB_CMDLINE_LINUX_DEFAULT="[^"]*"/GRUB_CMDLINE_LINUX_DEFAULT="loglevel=4 quiet rd.driver.blacklist=nouveau nvidia-drm.modeset=1 nvidia-drm.fbdev=1"/' \
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
            -e 's/^MODULES=(.*)/MODULES=(nvidia nvidia_modeset nvidia_uvm nvidia_drm)/' \
            "/etc/mkinitcpio.conf"; then
            # -e 's/^MODULES=(.*)/MODULES=(i916 nvidia nvidia_modeset nvidia_uvm nvidia_drm)/' \

            sudo mkinitcpio -P
            logger "Successfully updated mkinitcpio."
            return 0

        fi
        logger "Failed to update mkinitcpio."
    }

    if if_not_installed_then_install_yay nvidia-beta-dkms nvidia-utils-beta nvidia-settings-beta opencl-nvidia-beta; then
        if if_not_installed_then_install libva-nvidia-driver linux-headers vulkan-icd-loader nvidia-prime nvtop; then
            if update_grub; then
                if update_mkinitcpio; then
                    sudo systemctl enable nvidia-suspend.service
                    sudo systemctl enable nvidia-hibernate.service
                    sudo systemctl enable nvidia-resume.service
                    logger "✅ NVIDIA DRIVERS SETUP DONE"
                    return 0
                fi
            fi

        fi
    fi

    logger "🔴 NVIDIA DRIVERS SETUP FAILED"
    return 0
}

main() {
    logger "⏳⏳ BASE SETUP STARTED"

    bash "$SCRIPT_SETUP_DIR/get-from-source.sh" yay || return 1
    bash "$SCRIPT_SETUP_DIR/get-from-source.sh" nvim || return 1

    install_and_setup_wayland || return 1
    install_intel_drivers || return 1
    install_nvidia_drivers || return 1

    yay -S --needed --noconfirm clipman satty
    yay -S --needed spotify
    yay -S --needed microsoft-edge-stable-bin

    logger "✅✅ BASE SETUP DONE"
    return 0
}

main
