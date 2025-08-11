#!/usr/bin/env zsh

lazy_load_nvm() {
    nvm() {
        unset -f nvm node npm npx
        
        [ -s "$NVM_DIR/nvm.sh" ] && source "$NVM_DIR/nvm.sh"
        [ -s "$NVM_DIR/bash_completion" ] && source "$NVM_DIR/bash_completion"
        
        path=($HOME/.local/bin $path)
        
        nvm "$@"
    }
    
    node() {
        nvm 
        node "$@"
    }
    
    npm() {
        nvm
        npm "$@"
    }
    
    npx() {
        nvm
        npx "$@"
    }
}

lazy_load_nvm
