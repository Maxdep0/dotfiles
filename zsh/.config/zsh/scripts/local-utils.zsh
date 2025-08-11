#!/usr/bin/env zsh

load_plugin() {
    local name=$1 repo=$2 file=${3:-$name.zsh}
    local dir="$ZSH_PLUGINS_DIR/$name"

    if [[ -s "$ZSH_PLUGINS_DIR/$1/$1.zsh" ]]; then
        source "$ZSH_PLUGINS_DIR/$1/$1.zsh"
    else
        [[ -d $ZSH_PLUGINS_DIR/$1 ]] || mkdir -pv "$ZSH_PLUGINS_DIR/$1"
        git clone https://github.com/zsh-users/$1.git "$ZSH_PLUGINS_DIR/$1"
        source "$ZSH_PLUGINS_DIR/$1/$1.zsh"
    fi
}

load() {
    if [ $1 = eval ]; then
        eval "$2"
    elif [ $1 = source ]; then
        if [ -s "$2" ]; then
            source "$2"
        else
            print "$2 not found"
        fi
    fi

}
