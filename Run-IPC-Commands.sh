#!/bin/bash 
# Usage: sudo ./Run-IPC-Commands.sh

#!/bin/bash

# Check if running as root
if [ "$(id -u)" != "0" ]; then
    echo "This script must be run as root." >&2
    exit 1
fi

# Update and upgrade the system
sudo apt update && sudo apt upgrade -y

# Install and enable SSH
sudo apt -y install ssh
sudo systemctl enable ssh 

# Install and enable xRDP
sudo apt -y install xrdp
sudo systemctl enable xrdp

# Disable GNOME animations (assuming GNOME is your desktop environment)
gsettings set org.gnome.desktop.interface enable-animations false

# Modify xRDP settings for lower bandwidth usage
sudo sed -i 's/max_bpp=32/max_bpp=16/g' /etc/xrdp/xrdp.ini

# Confirm before disabling UFW firewall
read -p "Do you want to disable the firewall? Disabling the firewall will expose your system to potential security risks. (y/n) " response
if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]
then
    sudo ufw disable
else
    echo "Firewall not disabled. Consider adding specific firewall rules to allow connections to virtual machines and other devices."
fi

# Install virtualization packages
sudo apt -y install bridge-utils cpu-checker libvirt-clients libvirt-daemon qemu qemu-kvm

# Install and run Virtual Machine Manager
sudo apt install virt-manager -y
sudo virt-manager &

# Install networking tools
sudo apt install net-tools

# Configure network bridge
sudo nmcli con add type bridge ifname br0 con-name br0
sudo nmcli con modify br0 bridge.stp no
sudo nmcli con add type bridge-slave ifname enp0s29f1 con-name br0-port master br0

# Restart NetworkManager to apply changes
sudo systemctl restart NetworkManager

# Script execution complete
echo "Setup script execution completed successfully."
