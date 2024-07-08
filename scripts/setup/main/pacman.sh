#!/usr/bin/bash


setup_reflector() {
    REFLECTOR='/etc/xdg/reflector'

    sudo stow --dir="$SCRIPT_CONFIG_FILES" --target="$REFLECTOR" -D reflector
    [[ -f "$REFLECTOR/reflector.conf" ]] && sudo mv "$REFLECTOR/reflector.conf" "$REFLECTOR/reflector.conf.bak"
    sudo rm -rf "$REFLECTOR/reflector.conf"
    sudo stow --dir="$SCRIPT_CONFIG_FILES" --target="$REFLECTOR" reflector
}

setup_pacman() {
        sudo sed -i \
            -e 's/^#*\s*Color\.*/Color/' \
            -e 's/^#*\s*VerbosePkgLists\.*/VerbosePkgLists/' \
            -e 's/^#*\s*ParallelDownloads = 5\.*/ParallelDownloads = 5/' \
            -e 's/^#*\s*Color\.*/Color/' \
            "/etc/pacman.conf" 
}

## paccache.timer config
setup_paccache_timer(){
    sudo mkdir -p /etc/systemd/system/paccache.timer.d
    sudo nano /etc/systemd/system/paccache.timer.d/override.conf

}

setup_pacman_hook(){

}

main() {
    setup_reflector
    setup_pacman


    sudo systemctl enable paccache.timer
    sudo systemctl start paccache.timer

}


