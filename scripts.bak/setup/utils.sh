#!/usr/bin/bash

timestamp=$(date +'%d-%m_%H-%M')

logger() {
    # local func="${FUNCNAME[1]}"
    local line="${BASH_LINENO[0]}"
    local file="${BASH_SOURCE[2]}"
    local msg="$1"
    # echo "$(date "+%H:%M:%S") - $file [$line] -  $msg     -  $func" >>"$LOGS_DIR/setup/e.log"
    echo "$(date "+%H:%M:%S") - $file [$line] -  $msg  " >>"$LOGS_DIR/setup/e.log"
}

paci() {
    for pkg in "$@"; do
        sudo pacman -S --needed --noconfirm "$pkg" || logger "Pacman: $pkg"
    done
}

yayi() {
    for pkg in "$@"; do
        yay -S --needed --answerclean no --answerdiff n "$pkg" || logger "Yay: $pkg"
    done
}

cmd_check() {
    command -v "$1" >/dev/null 2>&1
}

pac_check() {
    pacman -Qi "$1" &>/dev/null 2>&1
}

if_not_installed_then_install() {
    if pac_check "$1"; then
        logger "$1 is installed"
        return 0
    else
        logger "installing $1..."
        if sudo pacman -S --noconfirm --needed "$1"; then
            logger "$1 is installed"
            return 0
        else
            logger "$1 installation failed"
            return 1
        fi
    fi
}

if_not_backup_then_create() {
    local location=$1
    local name=$2
    if [ ! -f "$location/$name.bak" ]; then
        logger "creating $name.bak..."
        if sudo mv "$location/$name" "$location/$name.bak"; then
            logger "$name.bak created"
        else
            logger "could not create $name.bak"
            return 1
        fi
    else
        logger "$name backup found"
    fi

}

if_target_file_found_then_destow_remove_stow_or_stow() {
    local location="$1"
    local name="$2"
    local stowdir="$3"
    # local stowtargetpath="$4"
    local stowtarget="$4"

    if [ -f "$location/$name" ]; then

        if sudo stow --dir="$stowdir" --target="$location" -D "$stowtarget"; then
            logger "$name de-stowed."
        else
            logger "de-stow $name failed."
            return 1
        fi

        if sudo rm -rf "$ETC/nftables.conf"; then
            logger "$name removed."
        fi

        if sudo stow --dir="$stowdir" --target="$location" "$stowtarget"; then
            logger "$name stowed."
            return 0
        else
            logger "stow $name failed."
            return 1
        fi

    else

        logger "stowing $name..."

        if sudo stow --dir="$stowdir" --target="$location" "$stowtarget"; then
            logger "$name stowed."
            return 0
        else
            logger "stow $name failed."
            return 1
        fi

    fi
}
