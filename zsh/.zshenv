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

export SHELL=/usr/bin/zsh

export PKG_CONFIG_PATH=/usr/local/lib/pkgconfig:$PKG_CONFIG_PATH
export PKG_CONFIG_PATH=/usr/local/lib64/pkgconfig:$PKG_CONFIG_PATH
export PKG_CONFIG_PATH=/usr/local/share/pkgconfig:$PKG_CONFIG_PATH


export LD_LIBRARY_PATH=/usr/lib:$LD_LIBRARY_PATH
export LD_LIBRARY_PATH=/usr/lib/:$LD_LIBRARY_PATH
export LD_LIBRARY_PATH=/usr/local/lib/:$LD_LIBRARY_PATH
export LD_LIBRARY_PATH=/usr/local/lib64/:$LD_LIBRARY_PATH

export XDG_DOWNLOAD_DIR="$HOME/Downloads"

if [ "$(tty)" = "/dev/tty1" ]; then

    # export GBM_BACKEND=nvidia-drm
    # export __GLX_VENDOR_LIBRARY_NAME=nvidia sway glmark2-wayland

    ##
    # export __NV_PRIME_RENDER_OFFLOAD=1
    export __GLX_VENDOR_LIBRARY_NAME=nvidia
   # export __VK_LAYER_NV_optimus=NVIDIA_only
    export GBM_BACKEND=nvidia-drm


    # export __NV_PRIME_RENDER_OFFLOAD=1 __GLX_VENDOR_LIBRARY_NAME=nvidia
    # export __NV_PRIME_RENDER_OFFLOAD=1 __GLX_VENDOR_LIBRARY_NAME=nvidia glmark2-wayland

    #
    # export __EGL_VENDOR_LIBRARY_FILENAMES=/usr/share/glvnd/egl_vendor.d/50_mesa.json
    # export __GLX_VENDOR_LIBRARY_NAME=mesa



    export WLR_NO_HARDWARE_CURSORS=1

    export MOZ_ENABLE_WAYLAND=1

    exec sway --unsupported-gpu
fi
