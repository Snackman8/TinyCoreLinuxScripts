#!/bin/sh

# **************************************************
#
# tc_install_wifi.sh
#
# Simple automated script to install openssh server on a fresh Tiny Core Linux 10.1 or 11.1
# installation.
#
# Usage: tc_install_wifi.sh SSID PASSWORD
#
#     SSID - SSID of wifi network to connect to
#     PASSWORD - WEP/WPA/WPA2 password for the wifi network
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
	echo "This script installs wifi for Tiny Core Linux 10.1 or 11.1"
	echo ""
	echo "Usage: tc_install_openwifi.sh SSID PASSWORD"
	echo ""
    echo "    Args: SSID should be the SSID of the wifi network"
	echo "    Args: PASSWORD should be the password for the wifi network"
	echo ""    
	exit 1
fi
echo ""
echo "STARTING INSTALLATION OF WIFI"
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

# install usbutils
echo "Installing usbutils extension"
echo "----------------------------"
tce-load -wi usbutils
echo ""

# install wifi
echo "Installing wifi extension"
echo "----------------------------"
tce-load -wi wifi
tce-load -wi firmware-rtlwifi
echo ""

# update Tiny Core configuration files
echo "Updating Tiny Core Configuration Files"
echo "--------------------------------------"
echo -e "$1\t$2\tWPA" | sudo tee ~/wifi.db
if grep -xq "/usr/local/bin/wifi.sh -a &" /opt/bootlocal.sh; then
        echo "wifi startup already exists in /opt/bootlocal.sh (skipping)"
else
    echo "/usr/local/bin/wifi.sh -a &" | sudo tee -a /opt/bootlocal.sh
        echo "wrote wifi startup into /opt/bootlocal.sh"
fi
filetool.sh -b
echo ""

# starting wifi
echo "Starting wifi"
echo "--------------------------------------"
sudo wifi.sh -a
echo ""

# show the IP address
echo "IP Addresses SSH server is listening on"
echo "---------------------------------------"
/sbin/ifconfig wlan0 | grep 'inet addr' | cut -d: -f2 | awk '{print $1}' | grep -v 127.0.0.1
echo ""

# Installation complete
echo ""
echo ""
echo ""
echo "INSTALLATION COMPLETE!"
echo "======================"
echo "Wifi installation is complete"
echo ""
echo ""
