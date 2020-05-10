#!/bin/sh

# **************************************************
#
# tc_install_samba.sh
#
# Simple automated script to install samba server on a fresh Tiny Core Linux 10.1 or 11.1
# installation.
#
# Usage: tc_install_samba.sh SAMBA_PASSWD
#
#     PASSWD - samba password to assign to the tc user
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
    echo "This script installs a samba server for Tiny Core Linux 10.1 or 11.1"
    echo ""
    echo "Usage: tc_install_samba.sh SAMBA_PASSWORD"
    echo ""
    echo "    Args: SAMBA_PASSWORD should be the samba password to set for the tc user"
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
echo "Installing samba extension"
echo "----------------------------"
tce-load -wi samba3
# enable SMB2 so works with windows 10
sudo sed -i 's/\[global\]/\[global\]\nprotocol = SMB2\na/g' /usr/local/etc/samba/smb.conf
echo ""

# set the password for the tc user
echo "Setting samba password of '$1' for tc user"
echo "------------------------------------"
sudo mkdir -p /usr/local/etc/samba/private
echo -e "$1\n$1" | sudo smbpasswd -s -a tc
echo ""

# start the samba server
echo "Starting Samba Server"
echo "-----------------------"
sudo smbd -D
sudo nmbd -D
echo "OK"
echo ""

# show the IP address
echo "IP Addresses Samba server is running on"
echo "---------------------------------------"
/sbin/ifconfig | grep 'inet addr' | cut -d: -f2 | awk '{print $1}' | grep -v 127.0.0.1
echo ""

# update Tiny Core configuration files
echo "Updating Tiny Core Configuration Files"
echo "--------------------------------------"
if grep -xq "/usr/local/etc/samba" /opt/.filetool.lst; then
    echo "/usr/local/etc/samba already exists in /opt/.filetool.lst (skipping)"
else
    echo '/usr/local/etc/samba' >> /opt/.filetool.lst
    echo "wrote /usr/local/etc/samba into /opt/.filetool.lst"
fi

if grep -xq "/usr/local/sbin/smbd -D" /opt/bootlocal.sh; then
        echo "smbd startup already exists in /opt/bootlocal.sh (skipping)"
else
    echo "/usr/local/sbin/smbd -D" | sudo tee -a /opt/bootlocal.sh
        echo "wrote smbd startup into /opt/bootlocal.sh"
fi

if grep -xq "/usr/local/sbin/nmbd -D" /opt/bootlocal.sh; then
        echo "nmbd startup already exists in /opt/bootlocal.sh (skipping)"
else
    echo "/usr/local/sbin/nmbd -D" | sudo tee -a /opt/bootlocal.sh
        echo "wrote nmbd startup into /opt/bootlocal.sh"
fi

filetool.sh -b
echo ""

# Installation complete
echo ""
echo ""
echo ""
echo "INSTALLATION COMPLETE!"
echo "======================"
echo "Please reboot and then try to connect to the samba server"
echo ""
ip=`/sbin/ifconfig | grep 'inet addr' | cut -d: -f2 | awk '{print $1}' | grep -v 127.0.0.1`
echo "    \\\\$1"
echo "    \\\\$ip"
echo ""
echo ""
