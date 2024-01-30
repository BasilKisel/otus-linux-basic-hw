#!/bin/bash

# This script instals clickhouse from raw packages.
# It installs PostgreSQL 16 from PGDG's repository.
# Many thanks to https://www.redhat.com/sysadmin/add-yum-repository


ch_cli_pack_name='clickhouse-client-23.9.6.20.x86_64'
ch_cli_rpm_name="$ch_cli_pack_name.rpm"
ch_common_pack_name='clickhouse-common-static-23.9.6.20.x86_64'
ch_common_rpm_name="$ch_common_pack_name.rpm"
ch_server_pack_name='clickhouse-server-23.9.6.20.x86_64'
ch_server_rpm_name="$ch_server_pack_name.rpm"
ch_rpm_rep_htts='https://packages.clickhouse.com/rpm/stable/'

postgres_yum_conf='postgres16-pgdg-repo.repo'
postgres_gpgkey='PGDG-RPM-GPG-KEY-RHEL'
yum_repo_d='/etc/yum.repos.d/'
pki_rpm_gpg='/etc/pki/rpm-gpg/'
postgres_pack_name='postgresql16.x86_64'

if [ `id -u` != 0 ]
then
    echo "$0: One should be root to start this script. Bye!"
    exit 1
fi


cat /etc/os-release
echo -e '\n\n\n\n'


########################################
# Clickhouse - check packages

if ! [ -f "$ch_cli_rpm_name" ]
then
    echo "$0: Downloading "  "$ch_cli_rpm_name"
    curl -s "$ch_rpm_rep_htts$ch_cli_rpm_name" -o "$ch_cli_rpm_name"
    echo -e '\n\n\n\n'
fi


if ! [ -f "$ch_common_rpm_name" ]
then
    echo "$0: Downloading "  "$ch_common_rpm_name"
    curl -s "$ch_rpm_rep_htts$ch_common_rpm_name" -o "$ch_common_rpm_name"
    echo -e '\n\n\n\n'
fi

if ! [ -f "$ch_server_rpm_name" ]
then
    echo "$0: Downloading "  "$ch_server_rpm_name"
    curl -s "$ch_rpm_rep_htts$ch_server_rpm_name" -o "$ch_server_rpm_name"
    echo -e '\n\n\n\n'
fi

# Clickhouse - install

rpm -i --test "$ch_cli_rpm_name" "$ch_common_rpm_name" "$ch_server_rpm_name"
if [ $? != 0 ]
then
   echo "$0: Cannon resolve dependencies to install ClickHouse properly. Abort."
   exit 2
fi

echo "$0: Installing Clickhouse"
rpm -i --quiet "./$ch_cli_rpm_name" "./$ch_common_rpm_name" "./$ch_server_rpm_name"
echo -e '\n\n\n\n'

# Clickhouse - remove

echo "$0: Removing ClickHouse"
rpm -e --quiet "$ch_cli_pack_name" "$ch_common_pack_name" "$ch_server_pack_name"
echo -e '\n\n\n\n'


#########################################
# PostgreSQL - add repository

if [ -f "$yum_repo_d$postgres_yum_conf" ]
then
    for bac_name in ".$postgres_yum_conf.bac."{1..999}
    do
        if ! [ -f "$yum_repo_d$bac_name" ]
        then
            mv "$yum_repo_d$postgres_yum_conf" "$yum_repo_d$bac_name" 
            echo "$0: Backed up '$yum_repo_d$postgres_yum_conf' to '$yum_repo_d$bac_name'"
            break
        fi
    done
fi

cp -n "./$postgres_yum_conf" "$yum_repo_d"


if [ -f "$pki_rpm_gpg$postgres_gpgkey" ]
then
    for bac_name in ".$postgres_gpgkey.bac."{1..999}
    do
        if ! [ -f "$pki_rpm_gpg$bac_name" ]
        then
            mv "$pki_rpm_gpg$postgres_gpgkey" "$pki_rpm_gpg$bac_name" 
            echo "$0: Backed up '$pki_rpm_gpg$postgres_gpgkey' to '$pki_rpm_gpg$bac_name'"
            break
        fi
    done
fi

cp -n "./$postgres_gpgkey" "$pki_rpm_gpg"


# PostgreSQL - install from a new repo

echo "$0: Installing PostgreSQL 16"
yum --quiet makecache
yum -y --quiet install "$postgres_pack_name"
echo -e '\n\n\n\n'


# PostgreSQL - remove from the system

echo "$0: Removing PostgreSQL 16"
yum -y --quiet remove "$postgres_pack_name"
echo -e '\n\n\n\n'


#########################################

echo "$0: all done"
