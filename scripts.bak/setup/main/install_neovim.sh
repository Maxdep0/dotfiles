#!/usr/bin/bash

install_neovim() {
    if [ ! -d "$XDG_DOWNLOAD_DIR/neovim" ] && ! cmd_check nvim; then
        git clone https://github.com/neovim/neovim "$XDG_DOWNLOAD_DIR/neovim"
        make --directory="$XDG_DOWNLOAD_DIR/neovim" CMAKE_BUILD_TYPE=Release
        sudo make --directory="$XDG_DOWNLOAD_DIR/neovim" install
        rm -rf "$XDG_DOWNLOAD_DIR/neovim"
    fi

}

install_neovim_config(){
    [ ! -d "$XDG_CONFIG_HOME/nvim" ] && git clone https://github.com/Maxdep0/nvim.git "$XDG_CONFIG_HOME/nvim" 
}

main() {
    install_neovim
    install_neovim_config
}
