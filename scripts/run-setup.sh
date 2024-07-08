#!/usr/bin/env bash

rm -f "$HOME/logs/setup/o.log" "$HOME/logs/setup/e.log"

[ ! -d "$HOME/logs/setup" ] && mkdir -pv "$HOME/logs/setup"
[ ! -d "$HOME/.config" ] && mkdir -pv "$HOME/.config"
[ ! -d "$HOME/Downloads" ] && mkdir -pv "$HOME/Downloads"
[ ! -d "$HOME/Documents" ] && mkdir -pv "$HOME/Documents"
[ ! -d "$HOME/Pictures" ] && mkdir -pv "$HOME/Pictures/Background"
[ ! -d "$HOME/Projects" ] && mkdir -pv "$HOME/Projects"
[ ! -d "$HOME/Videos" ] && mkdir -pv "$HOME/Videos"

source "$HOME/dotfiles/scripts/setup/env.sh"
source "$HOME/dotfiles/scripts/setup/utils.sh"

main() {
    # timestamp=$(date +'%d-%m_%H-%M')
    # exec > >(tee -a "$LOGS_DIR/setup/output$timestamp.log") 2>&1

    exec > >(tee -a "$LOGS_DIR/setup/o.log") 2>&1

    bash "$SCRIPT_SETUP_DIR/system/setup-system.sh"
}

main
