typeset -U path

add() {
    if [[ -d "$1" ]]; then
        path=("$1" $path)
#    else
#        echo "$1 does not exist"
    fi
}

add "$HOME/bin"
add "$HOME/.local/bin"
add "/usr/local/bin"
add "/opt/nvim-linux64/bin"

export SHELL=/usr/bin/zsh

export PKG_CONFIG_PATH=/usr/local/lib/pkgconfig:$PKG_CONFIG_PATH
export PKG_CONFIG_PATH=/usr/local/lib64/pkgconfig:$PKG_CONFIG_PATH
export PKG_CONFIG_PATH=/usr/local/share/pkgconfig:$PKG_CONFIG_PATH


export LD_LIBRARY_PATH=/usr/local/lib/:$LD_LIBRARY_PATH
export LD_LIBRARY_PATH=/usr/local/lib64/:$LD_LIBRARY_PATH

export XDG_DOWNLOAD_DIR="$HOME/Downloads"

if [ "$(tty)" = "/dev/tty1" ]; then

    export LIBVA_DRIVER_NAME=nvidia
    export XDG_SESSION_TYPE=wayland
    export GBM_BACKEND=nvidia-drm
    export __GLX_VENDOR_LIBRARY_NAME=nvidia
    export WLR_NO_HARDWARE_CURSORS=1
    export MOZ_ENABLE_WAYLAND=1
    export XCURSOR_THEME=default

    exec sway --unsupported-gpu
fi
# If running from tty1 start sway
# [ "$(tty)" = "/dev/tty1" ] && export WLR_BACKENDS=gbm
# [ "$(tty)" = "/dev/tty1" ] && export WLR_DRM_DEVICES=/dev/dri/card0

# [ "$(tty)" = "/dev/tty1" ] && exec sway --unsupported-gpu
