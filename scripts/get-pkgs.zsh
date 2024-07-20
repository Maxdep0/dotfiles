#!/usr/bin/env zsh

echo "heloo"

[ ! -d "$LOGS_DIR/pkgs" ] && mkdir -p "$LOGS_DIR/pkgs"

pacman -Qe | while read -r pkg _; do
    if pacman -Si "$pkg" >/dev/null 2>&1; then
        echo "$pkg" >>"$LOGS_DIR/pkgs/pacman-pkgs.log"
    fi
done

pacman -Qm | while read -r pkg _; do
    if yay -Qi "$pkg" >/dev/null 2>&1 || paru -Qi "$pkg" >/dev/null 2>&1; then
        echo "$pkg" >>"$LOGS_DIR/pkgs/yay-pkgs.log"
    fi
done
