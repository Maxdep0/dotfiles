#!/bin/bash

#https://www.dnsleaktest.com/

set_dns() {
    local conn_name=$1
    local ipv4_dns_servers="8.8.8.8, 8.8.4.4"
    local ipv6_dns_servers="2001:4860:4860::8888, 2001:4860:4860::8844"

    # IPv4
    nmcli connection modify "$conn_name" ipv4.dns "$ipv4_dns_servers" ipv4.ignore-auto-dns yes

    # IPv6
    nmcli connection modify "$conn_name" ipv6.dns "$ipv6_dns_servers" ipv6.ignore-auto-dns yes

    nmcli connection up "$conn_name"
}

ACTION=$2

if [ "$ACTION" = "up" ]; then
    active_connect=$(nmcli -t -f NAME,TYPE connection show --active | grep -v '^lo:' | awk -F':' '{print $1}')

    if [ -z "$active_connect" ]; then
        echo "No active connection"
        exit 1
    else
        set_dns "$active_connect"
    fi

    sudo ln -sf /run/NetworkManager/resolv.conf /etc/resolv.conf
fi

