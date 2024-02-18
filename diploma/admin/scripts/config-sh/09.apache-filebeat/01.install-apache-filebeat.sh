#!/bin/bash -e

# This script installs and configure filebeat for web-app apache logs.
# It sits on 192.168.1.15-16


if [ `id -u` != 0 ]
then
    echo "$0: One must be root to start this script. Bye!"
    exit 1
fi


# filebeat nginx
fb_deb='./filebeat/filebeat_8.9.1_amd64-224190-656d53.deb'
fb_yml_conf_trg='/etc/filebeat/filebeat.yml'
fb_yml_conf_src='./filebeat-cfg/filebeat.yml'


# Check prerequisites.
if [ `id -u` != 0 ]
then
    echo "$0: One should be root to start this script. Bye!"
    exit 1
fi
if [ ! -f "$fb_deb" ]
then
    echo "$0: Cannot locate '$fb_deb'. Please, provide a package and restart this script."
    exit 2
fi


# Install filebeat
dpkg -i "$fb_deb"
apt-get --fix-broken -yq install
systemctl daemon-reload
systemctl disable --now filebeat.service


# Configure filebeat
if [ -f "$fb_yml_conf_trg" ]
then
    for new_bac in "$fb_yml_conf_trg.bac."{1..999}
    do
        if ! [ -f "$new_bac" ]
        then
            mv "$fb_yml_conf_trg" "$new_bac"
            echo "$0: Backed up '$fb_yml_conf_trg' to '$new_bac'"
            break
        fi
    done
fi
cp "$fb_yml_conf_src" "$fb_yml_conf_trg"
chmod ugo+r "$fb_yml_conf_trg"

systemctl enable filebeat.service
systemctl restart filebeat.service
