# TinyCoreLinuxScripts
Scripts for Tiny Core Linux

http://www.tinycorelinux.net/

A collection of scripts to automate some of the common tasks when setting up a new Tiny Core Linux box.

tc_install_openssh.sh - Automatically install and start the openssh server

In order to download these scripts to a fresh install of Tiny Core Linux 10.1 or 11.1, the wget must first be upgraded because the stock wget command does not support https

```
# update wget extension on Tiny Core Linux 10.1 or 11.1
tce-load -wi wget

# download the scripts
wget https://raw.githubusercontent.com/Snackman8/TinyCoreLinuxScripts/master/tc_install_openssh.sh
chmod +x ./tc_install_openssh.sh
wget https://raw.githubusercontent.com/Snackman8/TinyCoreLinuxScripts/master/tc_install_openvpn_proxy.sh
chmod +x ./tc_install_openvpn_proxy.sh

# run the script, change PASSWD to whatever password you want the tc user to have
./tc_install_openssh.sh PASSWD

# run the openvpn_proxy script, change OVPN_FILE to your openvpn configuration file, i.e. test.ovpn and change PORT to the proxy port
./tc_install_openvpn_proxy.sh OVPN_FILE PORT
```
