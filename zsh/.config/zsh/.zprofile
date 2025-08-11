# Load it only for tty1, so i can debug it in tty2
if [ "$(tty)" = "/dev/tty1" ]; then
    exec Hyprland
fi

