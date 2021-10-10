#!/usr/bin/env bash
apt update
apt install -y wireguard

printf "Enter server allowed address CIDR: "
read ADDRESS_CIDR

printf "Enter server endpoint: "
read SERVER_ENDPOINT

umask 077
wg genkey | tee /etc/wireguard/private.key
cat /etc/wireguard/private.key | wg pubkey | tee /etc/wireguard/public.key

# write file content
printf "[Interface]\nPrivateKey = $(cat /etc/wireguard/private.key)\nAddress = ${ADDRESS_CIDR}\nListenPort = 51820\nSaveConfig = true\n" | tee /etc/wireguard/wg0.conf
printf "net.ipv4.ip_forward=1\n" | tee -a /etc/sysctl.conf
sysctl -p

PUBLIC_INTERFACE=$(ip route list default | awk '{print $5}')
printf "PostUp = ufw route allow in on wg0 out on ${PUBLIC_INTERFACE}\nPostUp = iptables -t nat -I POSTROUTING -o ${PUBLIC_INTERFACE} -j MASQUERADE\nPreDown = ufw route delete allow in on wg0 out on ${PUBLIC_INTERFACE}\nPreDown = iptables -t nat -D POSTROUTING -o ${PUBLIC_INTERFACE} -j MASQUERADE\n" | tee -a /etc/wireguard/wg0.conf

# adding dns to ufw
# https://www.cyberciti.biz/faq/howto-open-dns-port-53-using-ufw-ubuntu-debian/
ufw allow 51820/udp comment 'Open Wireguard port'
ufw allow 53/tcp comment 'Open port DNS tcp port 53'
ufw allow 53/udp comment 'Open port DNS udp port 53'
ufw allow http
ufw allow https

# make sure firewall rules take effect
ufw disable
yes | ufw enable
ufw status

systemctl enable wg-quick@wg0.service
systemctl start wg-quick@wg0.service
systemctl status wg-quick@wg0.service

# get dns servers for clients
CLIENT_DNS_SERVERS=$(resolvectl dns ${PUBLIC_INTERFACE} | awk '{print $4", "$5}')

# print sample wireguard config
ADDRESS_CIDR_PREFIX=$(printf ${ADDRESS_CIDR} | cut -d '/' -f 1 | cut -d '.' -f 1-3)
SAMPLE_CLIENT_ADDRESS_CIDR="${ADDRESS_CIDR_PREFIX}.X/24"
printf "[Interface]\nPrivateKey = base64_encoded_peer_private_key_goes_here\nAddress = ${ADDRESS_CIDR}\nDNS = ${CLIENT_DNS_SERVERS}\n\n[Peer]\nPublicKey = $(cat /etc/wireguard/public.key)\nAllowedIPs = 0.0.0.0/0\nEndpoint = ${SERVER_ENDPOINT}:51820\n"
