#!/bin/bash -e

# This script prepares bootstrap to become ELK server.
 

if [ `id -u` != 0 ]
then
    echo "$0: One must be root to start this script. Bye!"
    exit 1
fi


# netplan
netplan_etc_dir='/etc/netplan'
netplan_src_path='./network-cfg/00-elk-netplan-config.yaml'
netplan_cfg_name='00-elk-netplan-config.yaml'
hostname='elk'


# Update network settings
echo "$hostname" > /etc/hostname
hostname "$hostname"
rm "$netplan_etc_dir"/* || true
cp "$netplan_src_path" "$netplan_etc_dir/$netplan_cfg_name"
echo -e "\n\nCHANGING IP\nRECONNECT TO NFS-SERVER'S IP\n\n"
netplan apply

