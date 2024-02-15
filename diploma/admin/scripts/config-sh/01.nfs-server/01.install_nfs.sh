#!/bin/bash -e

# This script installs and configure nds-server at 192.168.1.12
 

if [ `id -u` != 0 ]
then
    echo "$0: One must be root to start this script."
    exit 1
fi


# nfs
data_mnt_dir='/mnt/prod-data-drive'
shr_dbms_bcp_dir="$data_mnt_dir/dbms-bcp"
shr_web_app_dir="$data_mnt_dir/web-app"
shr_admin_dir="$data_mnt_dir/admin"
etc_exports='/etc/exports'
new_exports='./cfg/exports'
# iptables
new_ip4rules="./cfg/_ip4.nfs.rules.sh"
etc_ip4_rules='/etc/iptables/rules.v4'


# Install nfs server

apt-get -y install nfs-kernel-server


# Prepare shared dirs if they doesnot exist

for shr_dir in "$shr_dbms_bcp_dir" "$shr_web_app_dir" "$shr_admin_dir"
do
    [ -d "$shr_dir" ] || mkdir -p "$shr_dir"
    chown nobody:nogroup "$shr_dir/"
done


# Configure nfs server
if [ -e "$etc_exports" ]
then
    for bac_file in "$etc_exports.bac."{1..999}
    do
        if ! [ -e "$bac_file" ]
        then
            cp "$etc_exports" "$bac_file"
            break
        fi
    done
fi

cp "$new_exports" "$etc_exports"
exportfs -ar

systemctl enable nfs-server
systemctl restart nfs-server


# Fortify iptables
apt-get -y install iptables-persistent
"$new_ip4rules"
iptables-save > "$etc_ip4_rules" 
