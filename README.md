# WireGuard Server Setup

1. Run server setup script with sudo.
    ```shell
    sudo server-setup.sh
    ```

### Assumptions
1. WireGuard server address space is 256 addresses. (i.e. 10.0.0.0/24)
2. WireGuard server port is 51820.
3. Only IPv4 addresses supported.
4. Linux distro is Ubuntu 20.04LTS.

### References
- [Digital Ocean WireGuard Setup Tutorial](https://www.digitalocean.com/community/tutorials/how-to-set-up-wireguard-on-ubuntu-20-04)
