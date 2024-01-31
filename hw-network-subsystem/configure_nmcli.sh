#!/bin/bash -e

echo
echo This script sets static IPs and NDS with nmcli for ETH0.
echo Then reverts to the defaults.
echo


if [ `id -u` != 0 ]
then
    echo "$0: One should be root to start this script. Bye!"
    exit 1
fi


echo
echo Current IP, DNS config:
echo

nmcli -f ip4.address,ipv4.addresses,ip4.dns,ipv4.dns,ipv4.method connection show eth0


echo Changing configuration...

nmcli con modify eth0 ipv4.addresses '192.168.1.11/24' +ipv4.addresses '192.168.1.12/24'
nmcli con modify eth0 ipv4.dns '77.88.8.8, 77.88.8.1' # Yandex DNS
nmcli con modify eth0 ipv4.method 'manual'
nmcli device reapply eth0
sleep 1 # Prev operation needs some time


echo
echo Check changes:
echo

nmcli -f ip4.address,ipv4.addresses,ip4.dns,ipv4.dns,ipv4.method connection show eth0
ip addr show eth0


echo Reverting changes:

nmcli con modify eth0 ipv4.method 'auto'
nmcli con modify eth0 ipv4.addresses '' # Static address binded to a router's DHPC
nmcli con modify eth0 ipv4.dns '' # Router proxies DNS
nmcli device reapply eth0
sleep 1 # Prev operation needs some time

echo
echo Check defaults:
echo

nmcli -f ip4.address,ipv4.addresses,ip4.dns,ipv4.dns,ipv4.method connection show eth0
ip addr show eth0


echo All done.
