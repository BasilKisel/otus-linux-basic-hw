#!/bin/bash -e

# This script installs and configures nginx filebeat.

filebeat_deb_file='filebeat_8.9.1_amd64-224190-656d53.deb'
filebeat_etc_dir='/etc/filebeat'
filebeat_yml_file='filebeat.yml'


# Check prerequisites.

if [ `id -u` != 0 ]
then
    echo "$0: One should be root to start this script. Bye!"
    exit 1
fi

if [ ! -f "./$filebeat_deb_file" ]
then
    echo "$0: Cannot locate './$filebeat_deb_file'. Please, provide a package and restart this script."
    exit 2
fi


# Install filebeat

dpkg -i "./$filebeat_deb_file"
apt-get --fix-broken -y install

systemctl daemon-reload
systemctl disable --now filebeat.service

# Configure filebeat

if [ -f "$filebeat_etc_dir/$filebeat_yml_file" ]
then
    for new_bac in "$filebeat_yml_file.bac."{1..999}
    do
        if ! [ -f "$filebeat_etc_dir/$new_bac" ]
        then
            mv "$filebeat_etc_dir/$filebeat_yml_file" "$filebeat_etc_dir/$new_bac"
            echo "$0: Backed up '$filebeat_etc_dir/$filebeat_yml_file' to '$filebeat_etc_dir/$new_bac'"
            cp "./$filebeat_yml_file" "$filebeat_etc_dir/"
            break
        fi
    done
fi

systemctl enable --now filebeat.service
