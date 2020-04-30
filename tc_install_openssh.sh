#!/bin/sh

# **************************************************
#
# tc_install_openssh.sh
#
# Simple automated script to install openssh server on a fresh Tiny Core Linux 11.1
# installation.
#
# Usage: tc_install_openssh.sh PASSWD
#
#     PASSWD - password to assign to the tc user
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
	echo "This script installs an openssh server for Tiny Core Linux 11.1"
	echo ""
	echo "Usage: tc_install_openssh.sh PASSWORD"
	echo ""
	echo "    Args: PASSWORD should be the password to set for the tc user"
	echo ""    
	exit 1
fi
echo ""
echo "STARTING INSTALLATION OF OPENSSH SERVER"
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

# install openssh extension
echo "Installing openssh extension"
echo "----------------------------"
tce-load -wi openssh
# copy the default configuration file to the correct place
cd /usr/local/etc/ssh
sudo cp sshd_config.orig sshd_config
echo ""

# set the password for the tc user
echo "Setting password of '$1' for tc user"
echo "------------------------------------"
echo -e "$1\n$1" | sudo passwd tc
echo ""

# start the openssh server
echo "Starting OpenSSH Server"
echo "-----------------------"
sudo /usr/local/etc/init.d/openssh start
echo "OK"
echo ""

# show the IP address
echo "IP Addresses SSH server is listening on"
echo "---------------------------------------"
/sbin/ifconfig | grep 'inet addr' | cut -d: -f2 | awk '{print $1}' | grep -v 127.0.0.1
echo ""

# update Tiny Core configuration files
echo "Updating Tiny Core Configuration Files"
echo "--------------------------------------"
if grep -xq "usr/local/etc/ssh" /opt/.filetool.lst; then
	echo "usr/local/etc/ssh already exists in /opt/.filetool.lst (skipping)"
else
	echo 'usr/local/etc/ssh' >> /opt/.filetool.lst
	echo "wrote /usr/local/etc/ssh into /opt/.filetool.lst"
fi

if grep -xq "etc/shadow" /opt/.filetool.lst; then
        echo "etc/shadow already exists in /opt/.filetool.lst (skipping)"
else
        echo 'etc/shadow' >> /opt/.filetool.lst
        echo "wrote etc/shadow into /opt/.filetool.lst"
fi

if grep -xq "/usr/local/etc/init.d/openssh start &" /opt/bootlocal.sh; then
        echo "openssh startup already exists in /opt/bootlocal.sh (skipping)"
else
	echo "/usr/local/etc/init.d/openssh start &" | sudo tee -a /opt/bootlocal.sh
        echo "wrote openssh startup into /opt/bootlocal.sh"
fi
filetool.sh -b
echo ""

# Installation complete
echo ""
echo ""
echo ""
echo "INSTALLATION COMPLETE!"
echo "======================"
echo "Please reboot and then try to connect to the ssh server"
echo ""
echo "Use the command below from a client machine using password \"$1\""
echo ""
ip=`/sbin/ifconfig | grep 'inet addr' | cut -d: -f2 | awk '{print $1}' | grep -v 127.0.0.1`
echo "    ssh tc@$ip"
echo ""
echo ""
