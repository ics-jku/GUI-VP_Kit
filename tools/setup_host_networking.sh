#!/bin/bash

TUN_IF="tun10"
TUN_IP="10.0.0.1/24"

set -e
if [[ $(id -u) != 0 ]] ; then
	echo "WARNING: $0 started as non-root user! -> This script requires sufficient privileges to set up network and Iptable rules"
fi

echo "Cleanup"
ip link delete $TUN_IF >/dev/null 2>&1 || :

echo "Setup interface"
ip tuntap add $TUN_IF mode tun
ip addr add $TUN_IP dev $TUN_IF
ip link set $TUN_IF up

echo "Setup routing & nat"
echo 1 > /proc/sys/net/ipv4/ip_forward
/sbin/iptables -t nat -A POSTROUTING -j MASQUERADE
/sbin/iptables -A FORWARD -o $TUN_IF -m state --state RELATED,ESTABLISHED -j ACCEPT
/sbin/iptables -A FORWARD -i $TUN_IF -j ACCEPT
echo "done."
