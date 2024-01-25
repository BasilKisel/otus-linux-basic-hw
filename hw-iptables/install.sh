#!/bin/bash

if [ `id -u` != 0 ]
then
    echo "$0: Start this script as root. Bye!"
    exit 1
fi

if `dpkg-query --status iptables-persistent | grep -s -e "Status:" | grep -q -v -e "\binstalled\b"`
then
    echo "$0: Preparing to install iptables-save, iptables-restore utilities"
    echo "$0: Please, leave default filepaths to rules intact to use 'fortify.sh' script."
    read

    apt-get -y install iptables-persistent
fi
