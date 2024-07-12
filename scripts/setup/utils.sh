#!/usr/bin/env bash

timestamp=$(date +'%d-%m_%H-%M')

logger() {
    local line="${BASH_LINENO[0]}"
    # local file="${BASH_SOURCE[2]}"
    local msg="$1"
    # echo "$(date "+%H:%M:%S") - $file [$line] -  $msg     -  $func" >>"$LOGS_DIR/setup/e.log"
    echo "$(date "+%H:%M:%S") - [$line] -  $msg  " >>"$LOGS_DIR/setup/logger-$timestamp.log"
}

pac_check() {
    pacman -Qi "$1" &>/dev/null 2>&1
}

clone_makepkg() {
    local link=$1
    local dir="$XDG_DOWNLOAD_DIR/${1##*/}"

    if ! git clone "$link" "$dir"; then
        logger "Failed to clone. ($link >> $dir)"
        return 1
    fi

    if ! (cd "$dir" && makepkg -si --needed --noconfirm); then
        logger "Failed to makepkg $dir"
        return 1
    fi

    sudo rm -rf "$dir"

    logger "Successfully makepkg $dir"
    return 0
}

if_not_installed_then_install() {
    for package in "$@"; do
        if pac_check "$package"; then
            logger "$package is already installed"
        else
            logger "Installing $package..."
            if sudo pacman -S --noconfirm --needed "$package"; then
                logger "Successfully installed $package"
            else
                logger "Failed to install $package"
                # return 1
            fi
        fi
    done
    return 0
}

if_not_installed_then_install_yay() {
    for package in "$@"; do
        if pac_check "$package"; then
            logger "$package is already installed"
        else
            logger "Installing $package..."
            if yay -S --noconfirm --needed "$package"; then
                logger "Successfully installed $package"
            else
                logger "Failed to install $package"
                # return 1
            fi
        fi
    done
    return 0
}

copy_file_directly_from_src() {
    local target=$1
    local source=$2

    logger "Copying file... ($SCRIPT_SRC_DIR/$source >> $target)"

    if [ -f "$target" ]; then
        logger "Failed to copy file because target is file. ($target)"
        return 1
    elif [ ! -f "$SCRIPT_SRC_DIR/$source" ]; then
        logger "Failed to copy file because $source is not in $SCRIPT_SRC_DIR"
        return 1
    fi

    if sudo cp "$SCRIPT_SRC_DIR/$source" "$target"; then
        logger "Successfully copied file. ($SCRIPT_SRC_DIR/$source >> $target)"
        return 0

    else
        logger "Failed to copy file."
        return 1
    fi

}

if_no_backup_then_create() {
    local method=$1
    local target=$2

    logger "Creating backup...($method)($target)"

    if [ -d "$target" ]; then
        logger "Failed to create backup because target is directory. ($target)"
        return 1
    elif [ -f "$target.bak" ]; then
        logger "Backup already exists.  ($target.bak)"
        return 0
    elif [ -L "$target" ]; then
        logger "Failed to create backup because target file is symlink"
        return 1
    fi

    if [ "$method" = "copy" ]; then
        if sudo cp "$target" "$target.bak"; then
            logger "Successfully created backup. ($target)"
            return 0
        fi
    elif [ "$method" = "move" ]; then
        if sudo mv "$target" "$target.bak"; then
            logger "Successfully created backup. ($target)"
            return 0
        fi
    else
        logger "Incorrect backup method. ($method)"
        return 1
    fi

    logger "Failed to create backup. ($target)"
    return 1
}

create_or_relink_symlink() {
    local target=$1
    local source="${SCRIPT_SRC_DIR}/${target##*/}"

    logger "Creating symlink...  ($source >> $target)"

    if [ ! -f "$source" ]; then
        logger "Failed to find source. ($source)"
        return 1
    elif [ -L "$target" ]; then
        sudo rm -r "$target"
        sudo ln -s "$source" "$target"
        logger "Successfully re-link symlink. ($source >> $target)"
        return 0
    elif [ -e "$target" ]; then
        logger "Target exists and is not symlink. ($target)"
        return 1
    else
        if sudo ln -s "$source" "$target"; then
            logger "Successfully created symlink. ($source >> $target)"
            return 0
        else
            logger "Failed to create symlink. ($source >> $target)"
            return 1
        fi
    fi
}

enable_and_restart() {
    logger "Enabling $1..."
    if sudo systemctl enable --now "$1"; then
        logger "Successfully enabled $1"
        logger "Restarting $1..."
        if sudo systemctl restart "$1"; then
            logger "Successfully restarted $1"
            return 0
        else
            logger "Failed to restart $1"
            return 1
        fi
    else
        logger "Failed to enable $1"
        return 1
    fi

}
