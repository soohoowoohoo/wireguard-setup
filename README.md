# WireGuard Setup

## Server Setup
1. Download script and make it executable.
    ```shell
    curl 'https://raw.githubusercontent.com/soohoowoohoo/wireguard-setup/master/server-setup.sh' --silent > server-setup.sh
    chmod +x server-setup.sh
    ```
2. Run server setup script with sudo.
    ```shell
    sudo ./server-setup.sh
    ```
3. Add clients to your WireGuard server.
    ```shell
    sudo wg set wg0 peer ${CLIENT_PUBLIC_KEY} allowed-ips ${WG_SERVER_PRIVATE_IPS}
    ```

### Assumptions
1. WireGuard server address space is 256 addresses. (i.e. 10.0.0.0/24)
2. WireGuard server port is 51820.
3. Only IPv4 addresses supported.
4. Linux distro is Ubuntu 20.04LTS.

## Test Client Setup
1. Download script and make it executable.
    ```shell
    curl 'https://raw.githubusercontent.com/soohoowoohoo/wireguard-setup/master/test-peer-setup.sh' --silent > test-peer-setup.sh
    chmod +x test-peer-setup.sh
    ```
2. Run test peer setup script with sudo.
    ```shell
    sudo ./test-peer-setup.sh
    ```
3. Start the VPN tunnel.
    ```shell
    sudo wg-quick up wg0
    ```
4. Verify the tunnel works.
    ```shell
    curl 'https://ifconfig.me'
    ```

### Troubleshooting
- Of the 256 usable addresses (0-255), address 255 does not work. 

## References
- [Digital Ocean WireGuard Setup Tutorial](https://www.digitalocean.com/community/tutorials/how-to-set-up-wireguard-on-ubuntu-20-04)
