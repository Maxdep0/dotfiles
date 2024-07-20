#!/usr/bin/env bash

[ ! -d "$HOME/logs/setup" ] && mkdir -p "$HOME/logs/setup"

source "$HOME/dotfiles/scripts/setup/env.sh"
source "$HOME/dotfiles/scripts/setup/utils.sh"

timestamp=$(date +'%d-%m_%H-%M')
exec > >(tee -a "$LOGS_DIR/setup/output-$timestamp.log") 2>&1

# TODO: Replace all system symlings with copy
# TODO: Store .bak or nfdefault.conf in script src dir
# TODO: .txt package sets
# FIX: Multiple logger output files
# REFACTOR: setup-base.sh
# REFACTOR: env.sh

main() {
    logger "⏳⏳⏳ INSTALLATION STARTED"

    bash "$SCRIPT_SETUP_DIR/pre-setup.sh" || return 1
    bash "$SCRIPT_SETUP_DIR/setup-system.sh" || return 1
    bash "$SCRIPT_SETUP_DIR/setup-base.sh" || return 1
    bash "$SCRIPT_SETUP_DIR/post-setup.sh" || return 1

    logger "✅✅✅ INSTALLATION DONE"
    return 0
}

main
