#!/bin/bash

set -ouex pipefail

### Install packages

# Packages can be installed from any enabled yum repo on the image.
# RPMfusion repos are available by default in ublue main images
# List of rpmfusion packages can be found here:
# https://mirrors.rpmfusion.org/mirrorlist?path=free/fedora/updates/43/x86_64/repoview/index.html&protocol=https&redirect=1

# this installs a package from fedora repos
dnf5 install -y tmux

# Install Realtek r8125 2.5GbE driver (replaces slow r8169 in-kernel driver)
dnf5 -y install dkms kernel-devel git make gcc

# Get the kernel version from the installed kernel-devel, not the running host kernel
KERNEL_VERSION=$(rpm -q kernel-devel --queryformat '%{VERSION}-%{RELEASE}.%{ARCH}')

git clone https://github.com/awesometic/realtek-r8125-dkms.git /tmp/r8125
cd /tmp/r8125

# Install DKMS module source
dkms add .
# Build and install for the image's kernel, not the runner's kernel
dkms build r8125/9.016.01 -k "$KERNEL_VERSION"
dkms install r8125/9.016.01 -k "$KERNEL_VERSION"

cd / && rm -rf /tmp/r8125

# Blacklist r8169 so the r8125 driver is used for RTL8125 NICs
echo "blacklist r8169" > /usr/lib/modprobe.d/blacklist-r8169.conf

#### Example for enabling a System Unit File

systemctl enable podman.socket
