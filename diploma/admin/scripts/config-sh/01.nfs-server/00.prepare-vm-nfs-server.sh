#!/bin/bash -e

# This script prepares bootstrap to become nfs-server
 

if [ `id -u` != 0 ]
then
    echo "$0: One must be root to start this script."
    exit 1
fi


# external data storage
data_mnt_dir='/mnt/prod-data-drive'
# netplan
netplan_etc_dir='/etc/netplan'
netplan_src_path='./cgf/00-nfs-netplan-config.yaml'
netplan_cfg_name='00-nfs-netplan-config.yaml'
hostname='nfs-server'


# Attach prod-data-drive permenantly
[ -d "$data_mnt_dir" ] || mkdir -p "$data_mnt_dir"
grep -s -e '/dev/sdb1' /etc/fstab || echo "/dev/sdb1 $data_mnt_dir ext4 rw,suid,dev,exec,auto,user,async,nofail 0 0" >> /etc/fstab
(mount | grep -s -e '/dev/sdb1') || mount "$data_mnt_dir"


# Update network settings
echo "$hostname" > /etc/hostname
rm "$netplan_etc_dir"/* || true
cp "$netplan_src_path" "$netplan_etc_dir/$netplan_cfg_name"
echo -e "\n\nCHANGING IP\nRECONNECT TO NFS-SERVER'S IP\n\n"
netplan apply

