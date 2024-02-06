#!/bin/bash -e

# This scripts installs and configure nfs.
# It opens /var/nfs_data/www-data for read-write access to 192.168.1.8
# Thanx to https://www.youtube.com/watch?v=-6UIi-LIABk

wwwdir=/var/nfs_data/www-data
export_path=/etc/exports
new_exports=./exports


# Checks

if [ `id -u` != 0 ]
then
    echo "$0: One must be root to start this script."
    exit 1
fi

if ! [ -e "$new_exports" ]
then
    echo "$0: '$new_exports' is missing."
    exit 2
fi


# Install nfs server

apt-get -y install nfs-kernel-server


# Prepare shared dir

if ! [ -d "$wwwdir" ]
then
    mkdir -p "$wwwdir"
fi

chown nobody:nogroup "$wwwdir/"


# Configure nfs server

if [ -e "$export_path" ]
then
    for bac_file in "$export_path.bac."{1..999}
    do
        if ! [ -e "$bac_file" ]
        then
            cp "$export_path" "$bac_file"
            break
        fi
    done
fi

cp "$new_exports" "$export_path"
exportfs -ar

systemctl restart nfs-server
