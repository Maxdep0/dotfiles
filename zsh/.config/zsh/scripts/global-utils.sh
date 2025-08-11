#!/usr/bin/env bash

get_clipboard_name() {
    for cmd in wl-copy xclip xsel copyq; do
        if command -v "$cmd" >/dev/null 2>&1; then
            printf '%s' "$cmd"
            return 0
        fi
    done
    printf 'Clipboard manager not found.\n' >&2
}

copycat() {
    local clipboard_cmd
    clipboard_cmd="$(get_clipboard_name)" || return 1

    case "$clipboard_cmd" in
    wl-copy) awk 'FNR==1{printf "\n\n========= %s =========\n\n", FILENAME} {print}' "$@" | wl-copy ;;
    xclip) awk 'FNR==1{printf "\n\n========= %s =========\n\n", FILENAME} {print}' "$@" | xclip -selection clipboard ;;
    xsel) awk 'FNR==1{printf "\n\n========= %s =========\n\n", FILENAME} {print}' "$@" | xsel --clipboard --input ;;
    copyq) awk 'FNR==1{printf "\n\n========= %s =========\n\n", FILENAME} {print}' "$@" | copyq copy - ;;
    esac
}

paci() {
    case "$1" in
    install | i) sudo pacman -S --needed "${@:2}" ;;
    remove | r) sudo pacman -Rns "${@:2}" ;;
    update | u) sudo pacman -Syu ;;
    find | f) pacman -Ss "${@:2}" ;;
    info) pacman -Si "${@:2}" ;;
    list | l) pacman -Qe ;;
    listAll | la) pacman -Qn ;;
    tree | t) pactree "${2}" ;;
    clean | c) sudo pacman -Sc && sudo paccache -rvk2 ;;
    orphans | o) pacman -Qtdq ;;
    purgeOrphans | po)
        orphans=$(pacman -Qtdq)
        [ -n "$orphans" ] && sudo pacman -Rns "$orphans" || echo "No orphans."
        ;;
    unlock) sudo rm -f /var/lib/pacman/db.lck ;;
    help | *) cat <<'EOF' ;;
Usage: paci <sub-cmd> [args]
  i|install        install packages
  r|remove         remove packages
  u|update         full upgrade
  f|find           repo search
  info             show package info
  l|list           explicitly installed
  la|listAll       all repo/native packages
  t|tree           dependency tree
  c|clean          clean cache
  o|orphans        list orphaned deps
  po|purgeOrphans  remove orphaned deps
  unlock           delete pacman lock
EOF
    esac
}

yayi() {
    case "$1" in
    install | i) yay -S --needed "${@:2}" ;;
    remove | r) yay -Rns "${@:2}" ;;
    update | u) yay -Syu ;;
    find | f) yay -Ss "${@:2}" ;;
    info) yay -Si "${@:2}" ;;
    list | l) yay -Qm ;;
    listAll | la) yay -Qm ;;
    clean | c) yay -Yc ;;
    orphans | o) yay -Qtdq ;;
    purgeOrphans | po)
        orphans=$(yay -Qtdq)
        [[ -n "$orphans" ]] && yay -Rns "$orphans" || echo "No orphans."
        ;;
    help | *) cat <<'EOF' ;;
Usage: yayi <sub-cmd> [args]
  i|install        install (AUR)
  r|remove         remove
  u|update         full upgrade
  f|find           search
  info             show package info
  l|list           installed AUR pkgs
  la|listAll       all AUR pkgs
  c|clean          clean yay cache
  o|orphans        list orphaned deps
  po|purgeOrphans  remove orphaned deps
EOF
    esac
}

check() {
    ps -eo cmd --no-headers | sort | uniq -c | awk "\$1 > 1"
    ps -eo pid,comm,args,%mem,%cpu --sort=-%mem | head -n 20
    ps -eo pid,comm,%cpu --sort=-%cpu | head

}

pro() {
    if [[ -n $1 && -d ~/Projects/$1 ]]; then
        cd ~/Projects/"$1" || return
    else
        cd ~/Projects && fd -H -d 1
    fi
}
