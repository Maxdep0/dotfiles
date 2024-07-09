#!/usr/bin/bash

install_yay() {
    if ! cmd_check yay; then
        git clone https://aur.archlinux.org/yay.git "$XDG_DOWNLOAD_DIR/yay"
        cd "$XDG_DOWNLOAD_DIR/yay" && makepkg -si --needed --noconfirm  && cd "$HOME"
        rm -rf "$XDG_DOWNLOAD_DIR/yay"
    fi
}

install_nvm() {
    if ! [ -d "$NVM_DIR" ]; then
        mkdir "$NVM_DIR"
        sudo curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash || log "sudo curl nvm instal.sh | $LINENO"
        [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" || log "source nvm.sh | $LINENO"
        [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion" || log "source bash_completion | $LINENO"
    fi
}

install_paru() {
    if ! cmd_check paru; then
        git clone https://aur.archlinux.org/paru.git "$XDG_DOWNLOAD_DIR/paru" || log "git clone paru | $LINENO"
        cd "$XDG_DOWNLOAD_DIR/paru" && makepkg -si --needed --noconfirm || log "makepkg paru" && cd "$HOME"                                                          
        rm -rf "$XDG_DOWNLOAD_DIR/paru" || log "rm paru | $LINENO"
    fi
}

install_aux_tools() {
    install_yay
    install_nvm
    install_paru
}


