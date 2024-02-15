#!/bin/bash -e

# This script prepares bootstrap VM.
 

if [ `id -u` != 0 ]
then
    echo "$0: One must be root to start this script."
    exit 1
fi

downloader='./cfg/_download_packages.sh'
netplan_etc_dir='/etc/netplan'
netplan_yaml='./cfg/00-bootstrap-config.yaml'
hostname='bootstrap'

"$downloader"
[ ! -e "$netplan_etc_dir/*" ] || rm "$netplan_etc_dir/*"
cp "$netplan_yaml" "$netplan_etc_dir/"
netplan apply
echo "$hostname" > /etc/hostname
