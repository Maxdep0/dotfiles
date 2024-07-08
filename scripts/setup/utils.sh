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
