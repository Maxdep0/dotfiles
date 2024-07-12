#!/bin/bash

IFACE=$1
ACTION=$2

if [ "$ACTION" = "up" ]; then
    IP=$(ip addr show $IFACE | grep inet | grep -v inet6 | grep -v 127.0.0.1 | awk '{print $2}' | cut -d/ -f1)
    if [ -n "$IP" ]; then
        sudo sed -i '/archlinux$/d' /etc/hosts
        echo "$IP archlinux.localdomain archlinux" | sudo tee -a /etc/hosts > /dev/null
    fi
fi

