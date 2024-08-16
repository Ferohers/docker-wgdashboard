#!/bin/bash
# wg-post-up.sh
# Description: This script sets up iptables rules for a WireGuard interface without peer isolation 

# Define the WireGuard interface (you can easily change this)
WG_INTERFACE="wg0"

# 1. Allow traffic within the $WG_INTERFACE interface (peer-to-peer communication inside the interface)
iptables -A FORWARD -i $WG_INTERFACE -o $WG_INTERFACE -j ACCEPT

# 2. Block traffic from $WG_INTERFACE to other WireGuard interfaces (isolate $WG_INTERFACE)
iptables -A FORWARD -i $WG_INTERFACE -o wg+ -j DROP

# 3. Block traffic from other WireGuard interfaces to $WG_INTERFACE (isolate $WG_INTERFACE)
iptables -A FORWARD -i wg+ -o $WG_INTERFACE -j DROP

# 4. Allow traffic from $WG_INTERFACE to external networks (Ethernet interfaces like eth0, eth1, etc.)
iptables -A FORWARD -i $WG_INTERFACE -o eth+ -j ACCEPT

# 5. Allow return traffic from external networks to $WG_INTERFACE (only established/related connections)
iptables -A FORWARD -i eth+ -o $WG_INTERFACE -m state --state ESTABLISHED,RELATED -j ACCEPT

# 6. Set up NAT (Masquerading) for traffic leaving $WG_INTERFACE (WireGuard VPN interface)
iptables -t nat -A POSTROUTING -o $WG_INTERFACE -j MASQUERADE

# 7. Set up NAT (Masquerading) for traffic leaving external networks (Ethernet interfaces)
iptables -t nat -A POSTROUTING -o eth+ -j MASQUERADE

# 8. Allow all incoming traffic on the $WG_INTERFACE interface (WireGuard traffic)
iptables -I INPUT 1 -i $WG_INTERFACE -j ACCEPT

echo "WireGuard $WG_INTERFACE iptables rules applied."
