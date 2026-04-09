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
dnf5 -y copr enable laurie-reeves/realtek-r8125-dkms
dnf5 -y install dkms kernel-devel realtek-r8125-dkms
dnf5 -y copr disable laurie-reeves/realtek-r8125-dkms

# Blacklist r8169 so the r8125 driver is used for RTL8125 NICs
echo "blacklist r8169" > /usr/lib/modprobe.d/blacklist-r8169.conf

#### Example for enabling a System Unit File

systemctl enable podman.socket
