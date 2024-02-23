#!/bin/bash -e

# This script installs and configure nds-server at 192.168.1.12
 

if [ `id -u` != 0 ]
then
    echo "$0: One must be root to start this script. Bye!"
    exit 1
fi


# nfs
data_mnt_dir='/mnt/prod-data-drive'
shr_web_app_dir="$data_mnt_dir/web-app"
etc_exports='/etc/exports'
new_exports='./nfs-cfg/exports'
# mysql scripts
dbms_bcp_dir="$data_mnt_dir/dbms-bcp"
tbl_bcp_src_sh='./mysql-sh/dump-mysql-tablewise.sh'
tbl_bcp_trg_sh='/usr/sbin/dump-mysql-tablewise.sh'
full_bcp_src_sh='./mysql-sh/dump-mysql-serverwise.sh'
full_bcp_trg_sh='/usr/sbin/dump-mysql-serverwise.sh'
full_restore_src_sh='./mysql-sh/restore-mysql-serverwise.sh'
full_restore_trg_sh='/usr/sbin/restore-mysql-serverwise.sh'
# iptables
new_ip4_rules="./network-cfg/_ip4.nfs.rules.sh"
etc_ip4_rules='/etc/iptables/rules.v4'


# Install nfs server
apt-get -yq install nfs-kernel-server


# Prepare shared dirs if they does not exist
[ -d  "$shr_web_app_dir" ] || mkdir -p  "$shr_web_app_dir" 
chown nobody:nogroup  "$shr_web_app_dir"


# Copy mysql scrips
[ -d "$dbms_bcp_dir" ] || mkdir -p "$dbms_bcp_dir" 
cp "$tbl_bcp_src_sh" "$tbl_bcp_trg_sh"
chmod 550 "$tbl_bcp_trg_sh"
cp "$full_bcp_src_sh" "$full_bcp_trg_sh"
chmod 550 "$full_bcp_trg_sh"
cp "$full_restore_src_sh" "$full_restore_trg_sh"
chmod 550 "$full_restore_trg_sh"


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
chmod ugo+r "$etc_exports"
exportfs -ar
systemctl enable nfs-server
systemctl restart nfs-server


# Install mysql client for backups
apt-get -yq install mysql-client-8.0


# Install and run prometheus node exporter
apt-get -yq install prometheus-node-exporter
systemctl enable prometheus-node-exporter
systemctl start prometheus-node-exporter


# Fortify iptables
# silent install, tnx to https://gist.github.com/alonisser/a2c19f5362c2091ac1e7?permalink_comment_id=2264059#gistcomment-2264059
echo iptables-persistent iptables-persistent/autosave_v4 boolean true | sudo debconf-set-selections
echo iptables-persistent iptables-persistent/autosave_v6 boolean true | sudo debconf-set-selections
apt-get -yq install iptables-persistent
"$new_ip4_rules"
iptables-save > "$etc_ip4_rules" 
