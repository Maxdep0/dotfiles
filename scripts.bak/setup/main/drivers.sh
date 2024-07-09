#!/usr/bin/bash

# Tools to find compatible driver packages
install_debug_packages() {

    pac libva-utils
    pac vulkan-tools vdpauinfo clinfo
    yayi vulkan-caps-viewer-wayland
}

install_intel() {
    pac mesa mesa-utils
    pac intel-media-driver intel-gpu-tools intel-compute-runtime
    pac vulkan-intel vulkan-mesa-layers
    yayi auto-cpufreq # Interactive install



    sudo auto-cpufreq --install
}

# Beta 555+ nvidia drivers
intall_nvidia() {
    pac linux-headers
    yayi nvidia-beta-dkms nvidia-utils-beta nvidia-settings-beta opencl-nvidia-beta
    pac vulkan-icd-loader
    pac nvtop nvidia-prime 

    # wlroots-nvidia is not needed for 1 monitor
    # it reduces screen glitches for multi monitor setup
    paru -S wlroots-nvidia # Interactive install
}

setup_grup() {
    # nvidia-drm.fbdev=1 is experimental feature for 545+ drivers
    # It provides its own framebuffer console and replace efifb, vesafb
    sudo sed -i 's/^GRUB_CMDLINE_LINUX_DEFAULT="[^"]*"/GRUB_CMDLINE_LINUX_DEFAULT="loglevel=3 quiet rd.driver.blacklist=nouveau nvidia-drm.modeset=1 nvidia-drm.fbdev=1"/' "/etc/default/grub" || log "sudo sed grub_cmdline_linux_default | $LINENO"

    sudo grub-mkconfig -o /boot/grub/grub.cfg
}

setup_mkinitcpio() {
    sudo sed -i  \
        -e 's/^HOOKS=(.*)$/HOOKS=(base udev autodetect microcode modconf keyboard keymap consolefont block filesystems fsck)/' \
        -e 's/^MODULES=(.*)/MODULES=(i915 nvidia nvidia_modeset nvidia_uvm nvidia_drm)/' \
        "/etc/mkinitcpio.conf"

    sudo mkinitcpio -P 
}


main() {
    # install_debug_packages
    install_intel
    install_nvidia
    setup_grup
    setup_mkinitcpio
}

