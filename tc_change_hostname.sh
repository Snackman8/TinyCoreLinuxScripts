#!/bin/sh

# **************************************************
#
# tc_change_hostname.sh
#
# Simple automated script to change the hostname on a fresh Tiny Core Linux 10.1 or 11.1
# installation.
#
# Usage: tc_change_hostname.sh HOSTNAME
#
#     HOSTNAME - new hostname
#
#
# Copyright (c) 2020 Lawrence Yu
# Distributed under the MIT software license
# see http://www.opensource.org/licenses/mit-license.php.
#
# **************************************************

# Check to make sure password was passed in
if [ $# -eq 0 ]; then
    echo ""
    echo "This script changes the hostname for Tiny Core Linux 10.1 or 11.1"
    echo ""
    echo "Usage: tc_change_hostname.sh HOSTNAME"
    echo ""
    echo "    Args: HOSTNAME should be the the new hostname"
    echo ""    
    exit 1
fi
echo ""
echo "STARTING INSTALLATION OF SAMBA SERVER"
echo "======================================="

# verify this is running on Tiny Core Linux
if grep -xq "Core Linux" /etc/issue; then
        echo "Tiny Core Linux detected, proceeding"
else
    echo "Error!  This script should only be run on Tiny Core Linux.  Aborting!"
        echo ""
    exit 1
fi
echo ""

# install samba extension
echo "Changing hostname"
echo "----------------------------"
sed -i "s/host=`hostname`//g" /mnt/sda1/tce/boot/extlinux/extlinux.conf
sed -i "s/APPEND quiet/APPEND quiet host=$1/g" /mnt/sda1/tce/boot/extlinux/extlinux.conf
sudo hostname $1
echo "changed hostname in /mnt/sda1/tce/boot/extlinux/extlinux.conf"

# Installation complete
echo ""
echo ""
echo ""
echo "HOSTNAME changed!"
echo "======================"
echo "Please reboot to confirm hostname change is permanent"
echo ""
echo ""
