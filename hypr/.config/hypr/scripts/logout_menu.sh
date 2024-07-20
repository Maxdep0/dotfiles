#!/bin/bash

# wofi menu for logout, reboot, shutdown
selected=$(echo -e "Lock\nLogout\nReboot\nShutdown" | wofi --dmenu --prompt "Select an option:")

case $selected in
    Shutdown)
        systemctl poweroff
        ;;
    Reboot)
        systemctl reboot
        ;;
    Logout)
        swaymsg exit
        ;;
    Lock)
        swaylock
        ;;
    *)
        ;;
esac

