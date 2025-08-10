#!/usr/bin/env bash
set -euo pipefail

# shellcheck disable=SC2155
export SCRIPT_DIR=$(dirname "$(readlink -m "${BASH_SOURCE[0]}")")
export SCRIPT_MODULES_DIR="$SCRIPT_DIR"/modules
export SCRIPT_SRC_DIR="$SCRIPT_DIR"/src
export LOG_DIR="$HOME"/logs/arch-setup

[ ! -d "$LOG_DIR" ] && mkdir -p "$LOG_DIR"

# shellcheck disable=SC2155
export TIMESTAMP=$(date +'%Y%m%d-%H%M%S')
exec 3>>"$LOG_DIR/logger-$TIMESTAMP.log"
exec > >(tee -a "$LOG_DIR/output-$TIMESTAMP.log")
exec 2>&1

source "$SCRIPT_DIR"/env.sh
source "$SCRIPT_DIR"/utils.sh

trap 'logger "ERROR" "Script failed at line $LINENO"' ERR

# https://www.gnu.org/software/bash/manual/html_node/Bash-Conditional-Expressions.html
# https://www.gnu.org/software/bash/manual/bash.html#Conditional-Constructs
# https://www.gnu.org/software/coreutils/manual/coreutils.pdf

main() {
    logger progress "Starting Arch setup script..."

    source "$SCRIPT_MODULES_DIR"/001-pre-setup.sh || return 1
    source "$SCRIPT_MODULES_DIR"/800-idk-name-yet.sh || return 1
    source "$SCRIPT_MODULES_DIR"/999-post-setup.sh || return 1

    logger OK "Arch setup script completed"
    return 0
}

main "$@"
