#!/bin/sh

# **************************************************
#
# tc_install_openvpn_proxy.sh
#
# Simple automated script to install openvpn proxy server on a fresh Tiny Core Linux 10.1 or 11.1
# installation.
#
# Usage: tc_install_openvpn.sh OVPN_FILE PORT
#
#     OVPN_FILE - ovpn configuration file, i.e. test.ovpn
#     PORT - port to run the proxy server on
#
# Copyright (c) 2020 Lawrence Yu
# Distributed under the MIT software license
# see http://www.opensource.org/licenses/mit-license.php.
#
# **************************************************

# Check to make sure config file and port were passed in
if [ $# -ne 2 ]; then
	echo ""
	echo "This script installs an openvpn proxy server for Tiny Core Linux 10.1 or 11.1"
	echo ""
	echo "Usage: tc_install_openvpn_proxy.sh OVPN_FILE PORT"
	echo ""
	echo "    Args:"
	echo "        OVPN_FILE - ovpn configuration file, i.e. test.ovpn"
	echo "        PORT - port to run the proxy server on"
	echo ""
	exit 1
fi
echo ""
echo "STARTING INSTALLATION OF OPENVPN PROXY SERVER"
echo "======================================="
echo ""

# verify this is running on Tiny Core Linux
if grep -xq "Core Linux" /etc/issue; then
        echo "Tiny Core Linux detected, proceeding"
else
	echo "Error!  This script should only be run on Tiny Core Linux.  Aborting!"
	exit 1
fi


# install openvpn extension
echo "Installing openvpn extension"
echo "----------------------------"
tce-load -wi openvpn
echo ""

# generate RSA key
echo "Generating the RSA key for OpenVPN scripts"
echo "------------------------------------"
yes n | ssh-keygen -t rsa -N '' -f ~/.ssh/id_rsa_openvpn
echo ""

# copy key to authorized keys
echo "Copying RSA key to authorized keys"
echo "-----------------------"
KEY=`cat ~/.ssh/id_rsa_openvpn.pub`
if grep -xq "$KEY" ~/.ssh/authorized_keys; then
	echo "Key already present in authorized_keys"
else
	cat ~/.ssh/id_rsa_openvpn.pub >> ~/.ssh/authorized_keys
	echo "Copied RSA key to authorized_keys"
fi;
ssh -i /home/tc/.ssh/id_rsa_openvpn -o StrictHostKeyChecking=no tc@localhost "echo known hosts updated"
echo ""

# show the IP address
echo "IP Addresses SSH server is listening on"
echo "---------------------------------------"
/sbin/ifconfig | grep 'inet addr' | cut -d: -f2 | awk '{print $1}' | grep -v 127.0.0.1
echo ""

echo "Updating Tiny Core Configuration Files"
echo "--------------------------------------"
mkdir -p ~/.vpn
ovpn_file=~/.vpn/`basename $1`
cp $1 $ovpn_file
if grep -xq "openvpn --config $ovpn_file &" /opt/bootlocal.sh; then
        echo "openvpn startup already exists in /opt/bootlocal.sh (skipping)"
else
	echo "openvpn --config $ovpn_file &" | sudo tee -a /opt/bootlocal.sh
        echo "wrote openvpn startup into /opt/bootlocal.sh"
fi

if grep -xq "ssh -f -N -D 0.0.0.0:$2 -i /home/tc/.ssh/id_rsa_openvpn tc@localhost" /opt/bootlocal.sh; then
        echo "proxy startup already exists in /opt/bootlocal.sh (skipping)"
else
        echo "ssh -f -N -D 0.0.0.0:$2 -i /home/tc/.ssh/id_rsa_openvpn tc@localhost" | sudo tee -a /opt/bootlocal.sh
        echo "wrote proxy startup into /opt/bootlocal.sh"
fi
filetool.sh -b
echo ""

# Installation complete
echo ""
echo ""
echo ""
echo "INSTALLATION COMPLETE!"
echo "======================"
echo "Please reboot and then try to connect to the proxy server"
echo ""
echo "The proxy is at the location below"
echo ""
ip=`/sbin/ifconfig | grep 'inet addr' | cut -d: -f2 | awk '{print $1}' | grep -v 127.0.0.1`
echo "    http://$ip:$2"
echo ""
echo ""
