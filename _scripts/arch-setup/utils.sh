#!/usr/bin/env bash

# warn: if the error is not critical
# error: if the error is critical
# info: if it is just information
# progress: if the progress is logged
# start: new section in progress
# ok: if the operation is successful

declare -Ar LOG=(
    [START]="🚀" [PROGRESS]="⏳" [INFO]="ℹ️"
    [WARN]="⚠️" [ERROR]="❌" [OK]="✅"
)

logger() {
    local status="${1^^}"
    shift
    local msg="$*"
    local line="${BASH_LINENO[0]}"
    local file="${BASH_SOURCE[1]##*/}"
    local icon="${LOG[$status]}"

    printf '%(%H:%M:%S)T [%s:%s] - %s %s\n' -1 "$file" "$line" "$icon" "$msg" >&3
}
export -f logger

paci_install() {
    for package in "$@"; do
        if pacman -Qi -- "$package" &>/dev/null; then
            logger info "pacman: $package is already installed"
            continue
        fi

        if pacman -Si -- "$package" &>/dev/null; then
            logger progress "pacman: Installing $package..."
            if sudo pacman -S --noconfirm --needed -- "$package"; then
                logger ok "pacman: $package is successfully installed"
            else
                logger warn "pacman: $package failed to install"
            fi
        else
            logger warn "pacman: $package is not in the sync database"
        fi
    done
    return 0
}
export -f paci_install

fs_mkdir() {
    local dir="$1"
    [[ -z "$dir" ]] && {
        logger error "mkdir: dir path required"
        return 1
    }

    if [[ -d "$dir" ]]; then
        logger info "mkdir: dir already exists: $dir"
        return 0
    fi

    if command mkdir -p -- "$dir"; then
        logger ok "mkdir: Created dir: $dir"
    else
        logger error "mkdir: failed to create dir: $dir"
        return 1
    fi
}
export -f fs_mkdir

fs_move() {
    local src="$1" target="$2"
    [[ -z "$src" || -z "$target" ]] && {
        logger error "move: source and target required"
        return 1
    }
    [[ ! -e "$src" ]] && {
        logger error "move: source not found: $src"
        return 1
    }

    if command mv -T -- "$src" "$target"; then
        logger ok "move: Moved $src → $target"
    else
        logger error "move: Failed to move: $src → $target"
        return 1
    fi
}
export -f fs_move

fs_copy() {
    local src="$1" target="$2"
    [[ -z "$src" || -z "$target" ]] && {
        logger error "copy: source and target required"
        return 1
    }
    [[ ! -e "$src" ]] && {
        logger error "copy: source not found: $src"
        return 1
    }

    if command cp -a -- "$src" "$target"; then
        logger ok "cope: Copied: $src → $target"
    else
        logger error "cope: Failed to copy: $src → $target"
        return 1
    fi
}
export -f fs_copy

fs_remove() {
    local target="$1"
    [[ -z "$target" ]] && {
        logger error "remove: target path required"
        return 1
    }
    [[ ! -e "$target" ]] && {
        logger info "remove: Target not found: $target"
        return 0
    }

    if command rm -rf -- "$target"; then
        logger ok "remove: Removed: $target"
    else
        logger error "remove: Failed to remove: $target"
        return 1
    fi
}
export -f fs_remove

backup_if_original() {
    local method="$1" target="$2"
    logger info "backup: Backup check ($method) ($target)"

    [[ ! -e "$target" ]] && {
        logger info "backup: Nothing to back up."
        return 0
    }
    [[ -L "$target" ]] && {
        logger info "backup: Target is symlink, skipping..."
        return 0
    }

    local bak="${target}.bak"
    [[ -e "$bak" ]] && {
        logger info "backup: Backup exists ($bak)."
        fs_remove "$target" || return 1
        return 0
    }

    case "$method" in
    copy) fs_copy "$target" "$bak" || return 1 ;;
    move) fs_move "$target" "$bak" || return 1 ;;
    *)
        logger error "backup: Invalid backup method: $method"
        return 1
        ;;
    esac

    logger ok "backup: Backup created ($method): $bak"
}
export -f backup_if_original

create_or_relink_symlink() {
    local src="$1"
    local target="$2"

    [[ -z "$src" || -z "$target" ]] && {
        logger error "symlink: source and target required"
        return 1
    }

    logger info "symlink: $src → $target"
    [[ ! -e "$src" ]] && {
        logger error "symlink: Source not found: $src"
        return 1
    }

    fs_mkdir "$(dirname -- "$target")" || return 1

    if [[ -e "$target" && ! -L "$target" ]]; then
        backup_if_original move "$target" || return 1
    fi

    if [[ -L "$target" ]]; then
        local target_check src_check
        target_check="$(readlink -f -- "$target" 2>/dev/null || true)"
        src_check="$(readlink -f -- "$src" 2>/dev/null || true)"
        if [[ -n "$target_check" && "$target_check" == "$src_check" ]]; then
            logger info "symlink: Symlink already exists: $target"
            return 0
        fi
        if command rm -f -- "$target" && ln -s -- "$src" "$target"; then
            logger ok "symlink: Relinked: $src → $target"
            return 0
        else
            logger error "symlink: Failed to relink: $src → $target"
            return 1
        fi
    else
        if command ln -s -- "$src" "$target"; then
            logger ok "symlink: Created symlink: $src → $target"
            return 0
        else
            logger error "symlink :Failed to create symlink: $src → $target"
            return 1
        fi
    fi
}
export -f create_or_relink_symlink
