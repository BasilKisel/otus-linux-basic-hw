#!/bin/bash

# This script instals clickhouse from raw packages.
# It installs postgresql from PGDG's repository.
# Many thanks to https://www.redhat.com/sysadmin/add-yum-repository


ch_cli_pack_name='clickhouse-client-23.9.6.20.x86_64.rpm'
ch_common_pack_name='clickhouse-common-static-23.9.6.20.x86_64.rpm'
ch_server_pack_name='clickhouse-server-23.9.6.20.x86_64.rpm'
ch_rpm_rep_htts='https://packages.clickhouse.com/rpm/stable/'

postgres_yum_conf='./postgres-pgdg-repo.conf'
postgres_gpgkey='./PGDG-RPM-GPG-KEY-RHEL'
yum_repo_d='/etc/yum.repo.d/'
pki_rpm_gpg='/etc/pki/rpm-gpg/'

if [ `id -u` != 0 ]
then
    echo "$0: One should be root to start this script. Bye!"
    exit 1
fi


#########################################
# Clickhouse - check packages

if ! [ -f "$ch_cli_pack_name" ]
then
    echo "$0: Downloading "  "$ch_cli_pack_name"
    curl "$ch_rpm_rep_htts$ch_cli_pack_name" -o "$ch_cli_pack_name"
fi


if ! [ -f "$ch_common_pack_name" ]
then
    echo "$0: Downloading "  "$ch_common_pack_name"
    curl "$ch_rpm_rep_htts$ch_common_pack_name" -o "$ch_common_pack_name"
fi

if ! [ -f "$ch_server_pack_name" ]
then
    echo "$0: Downloading "  "$ch_server_pack_name"
    curl "$ch_rpm_rep_htts$ch_server_pack_name" -o "$ch_server_pack_name"
fi

# Clickhouse - install

rpm -i --test "$ch_cli_pack_name" "$ch_common_pack_name" "$ch_server_pack_name"
if [ $0 != 0 ]
then
    echo "$0: Cannon resolve dependencies to install ClickHouse properly. Abort."
    exit 2
fi

echo "$0: Installing Clickhouse"
rpm -i "$ch_cli_pack_name" "$ch_common_pack_name" "$ch_server_pack_name"

# Clickhouse - remove

echo "$0: Removing ClickHouse"
rpm -e "$ch_cli_pack_name" "$ch_common_pack_name" "$ch_server_pack_name"


#########################################
# PostgreSQL - add repository

if [ -f "$yum_repo_d$postgres_yum_conf" ]
then
    for bac_name in "$postgres_yum_conf.bac."{1..999}
    do
        if ! [ -f "$yum_repo_d$bac_name" ]
        then
            mv "$yum_repo_d$postgres_yum_conf" "$yum_repo_d$bac_name" 
            break
        fi
    done
fi

cp "$postgres_yum_conf" "$yum_repo_d"


if [ -f "$pki_rpm_gpg$postgres_gpgkey" ]
then
    for bac_name in "$postgres_gpgkey.bac."{1..999}
    do
        if ! [ -f "$pki_rpm_gpg$bac_name" ]
        then
            mv "$pki_rpm_gpg$postgres_gpgkey" "$pki_rpm_gpg$bac_name" 
            break
        fi
    done
fi

cp "$postgres_gpgkey" "$pki_rpm_gpg"


echo "$0: Checking a new PostgreSQL PGDG repository"
yum-config-manager postgresql-pgdg | head -n 10


# PostgreSQL - install from a new repo

echo "$0: Installing PostgreSQL 16"
yum -y -i postgresql16-16.1-2PGDG


#########################################

echo "$0: all done"
