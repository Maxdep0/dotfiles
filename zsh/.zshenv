typeset -U path PATH

path=( ~/.local/bin /usr/local/bin /usr/bin $path)

export PATH

# Custom
export DOTFILES="$HOME/dotfiles"
export LOGS_DIR="$HOME/logs"

# Editor/Shell
export SHELL=/usr/bin/zsh
export EDITOR="nvim"
export TERM="xterm-256color"
export CLICOLOR=1
export VISUAL="$EDITOR"
export MANPAGER="$EDITOR +Man!"

# XDG
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_STATE_HOME="$HOME/.local/state"
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_BIN_HOME="$HOME/.local/bin"

export XDG_DATA_DIRS="/usr/local/share:/usr/share"
export XDG_CONFIG_DIRS="/etc/xdg"
export XDG_RUNTIME_DIR="/run/user/$UID"

export XDG_DOCUMENTS_DIR="$HOME/Documents"
export XDG_DOWNLOAD_DIR="$HOME/Downloads"
export XDG_PICTURES_DIR="$HOME/Pictures"
export XDG_VIDEOS_DIR="$HOME/Downloads" # NOTE I dont download videos, so dir is Downloads
export XDG_MUSIC_DIR="$HOME/Downloads" # NOTE  ^^^

# ZSH
export ZDOTDIR="$XDG_CONFIG_HOME/zsh"
export ZSH_PLUGINS_DIR="$XDG_DATA_HOME/zsh/plugins"
export HISTFILE="$XDG_CACHE_HOME/zsh/.zhistory"
export HISTSIZE=10000
export SAVEHIST=10000
export KEYTIMEOUT=1

# NPM
export NVM_DIR="$HOME/.nvm"

# FZF
export FZF_DEFAULT_COMMAND="fd --type f --hidden"
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
FZF_COLORS="bg+:-1,fg:gray,fg+:white,border:black,spinner:0,hl:yellow,header:blue,info:green,pointer:red,marker:blue,prompt:gray,hl+:red"
export FZF_DEFAULT_OPTS="-m --border sharp --color $FZF_COLORS --prompt '∷ ' --pointer ▶ --marker ⇒"
export FZF_ALT_C_OPTS="--preview 'tree -C {} | head -n 10'"
export FZF_COMPLETION_DIR_COMMANDS="cd pushd rmdir tree ls"

export PKG_CONFIG_PATH="/usr/local/lib/pkgconfig:/usr/local/lib64/pkgconfig:/usr/local/share/pkgconfig:$PKG_CONFIG_PATH"
export LD_LIBRARY_PATH="/usr/lib:/usr/local/lib:/usr/local/lib64:$LD_LIBRARY_PATH"

