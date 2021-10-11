#!/usr/bin/env bash
apt update
apt install -y wireguard resolvconf

echo
printf "Enter WireGuard server allowed address CIDR: "
read WG_SERVER_PRIVATE_ADDRESS_CIDR

printf "Enter WireGuard client DNS servers: "
read WG_CLIENT_DNS_SERVERS

printf "Enter WireGuard server public key: "
read WG_SERVER_PUBLIC_KEY

printf "Enter WireGuard server endpoint: "
read WG_SERVER_ENDPOINT

printf "Enter WireGuard server port (51820): "
read WG_SERVER_PORT
if [ -z "${WG_SERVER_PORT}" ]; then
    WG_SERVER_PORT=51820
fi

umask 077
wg genkey | tee /etc/wireguard/private.key
cat /etc/wireguard/private.key | wg pubkey | tee /etc/wireguard/public.key

# client config for routing all traffic over vpn for remote system
PUBLIC_INTERFACE=$(ip route list table main default | awk '{print $5}')
PUBLIC_GATEWAY=$(ip route list table main default | awk '{print $3}')
PUBLIC_IP=$(ip -brief address show ${PUBLIC_INTERFACE} | awk '{print $3}' | cut -d '/' -f 1)

# write client WireGuard config file
printf "[Interface]\nPrivateKey = $(cat /etc/wireguard/private.key)\nAddress = ${WG_SERVER_PRIVATE_ADDRESS_CIDR}\nDNS = ${WG_CLIENT_DNS_SERVERS}\nPostUp = ip rule add table 200 from ${PUBLIC_IP}\nPostUp = ip route add table 200 default via ${PUBLIC_GATEWAY}\nPreDown = ip rule delete table 200 from ${PUBLIC_IP}\nPreDown = ip route delete table 200 default via ${PUBLIC_GATEWAY}\n\n[Peer]\nPublicKey = ${WG_SERVER_PUBLIC_KEY}\nAllowedIPs = 0.0.0.0/0\nEndpoint = ${WG_SERVER_ENDPOINT}:${WG_SERVER_PORT}\n" > /etc/wireguard/wg0.conf

WG_SERVER_PRIVATE_ADDRESS=$(printf ${WG_SERVER_PRIVATE_ADDRESS_CIDR} | cut -d '/' -f 1)
printf "Add the client to the server using the following command:\n"
printf "    sudo wg set wg0 peer $(cat /etc/wireguard/public.key) allowed-ips ${WG_SERVER_PRIVATE_ADDRESS}\n"
