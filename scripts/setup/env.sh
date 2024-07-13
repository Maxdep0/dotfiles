#!/usr/bin/bash

mkdir -pv "$HOME/logs"

export PATH="$HOME/.local/bin:/usr/local/bin:/usr/bin:$PATH"
export LOGS_DIR="$HOME/logs"
export SHELL=/usr/bin/zsh
export DOTFILES="$HOME/dotfiles"
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
export XDG_VIDEOS_DIR="$HOME/Videos"
export XDG_MUSIC_DIR="$HOME/Videos"
export ZDOTDIR="$XDG_CONFIG_HOME/zsh"
export ZSH_PLUGINS_DIR="$XDG_DATA_HOME/zsh/plugins"
export HISTFILE="$ZDOTDIR/.zhistory"
export NVM_DIR="$HOME/.nvm"

# Script

export SCRIPT_ROOT="$DOTFILES/scripts"
export SCRIPT_SETUP_DIR="$SCRIPT_ROOT/setup"
export SCRIPT_SRC_DIR="$SCRIPT_SETUP_DIR/src"

# System

export PACMAN_CONF="/etc/pacman.conf"
export PACCACHE_TIMER="/etc/systemd/system/paccache.timer"

export SSHD_CONFIG="/etc/ssh/sshd_config"

export REFLECTOR_DIR="/etc/xdg/reflector"
export REFLECTOR_CONF="/etc/xdg/reflector/reflector.conf"
export REFLECTOR_TIMER="/etc/systemd/system/reflector.timer"

export JOURNALD_CONF="/etc/systemd/journald.conf"

export NFTABLES_CONF="/etc/nftables.conf"

export NM_DISPATCHER_DIR="/etc/NetworkManager/dispatcher.d"


