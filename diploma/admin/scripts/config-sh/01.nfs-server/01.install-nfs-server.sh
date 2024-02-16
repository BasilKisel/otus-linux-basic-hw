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
etc_exports='/etc/exports'
new_exports='./nfs-cfg/exports'
# iptables
new_ip4rules="./network-cfg/_ip4.nfs.rules.sh"
etc_ip4_rules='/etc/iptables/rules.v4'


# Install nfs server

apt-get -yq install nfs-kernel-server


# Prepare shared dirs if they doesnot exist

[ -d "$shr_dbms_bcp_dir" ] || mkdir -p "$shr_dbms_bcp_dir" 
[ -d  "$shr_web_app_dir" ] || mkdir -p  "$shr_web_app_dir" 
chown nobody:nogroup  "$shr_web_app_dir"


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
# silent install, tnx to https://gist.github.com/alonisser/a2c19f5362c2091ac1e7?permalink_comment_id=2264059#gistcomment-2264059
echo iptables-persistent iptables-persistent/autosave_v4 boolean true | sudo debconf-set-selections
echo iptables-persistent iptables-persistent/autosave_v6 boolean true | sudo debconf-set-selections
apt-get -yq install iptables-persistent
"$new_ip4rules"
iptables-save > "$etc_ip4_rules" 
