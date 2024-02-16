#!/bin/bash -e

# This script installs, configure and runs up a source of MySQL at 192.168.1.13.


if [ `id -u` != 0 ]
then
    echo "$0: One must be root to start this script."
    exit 1
fi


# mysql-source
repl_usr_name=replica
repl_usr_pass=secret
bcp_usr_name=backup
bcp_usr_pass=secret
wp_usr_name='wordpress_user'
wp_usr_pass='secret'
wp_db_name='wordpress_db'
mysqld_cnf_path='/etc/mysql/mysql.conf.d/mysqld.cnf'
mysqld_new_cfg='./mysql-cfg/mysqld_source.cnf'
mysqld_err_log_path='/var/log/mysql/error.log'
# iptables
new_ip4rules='./network-cfg/_ip4.mysql.rules.sh'
etc_ip4_rules='/etc/iptables/rules.v4'


# Do install mysql
apt-get install -yq mysql-server-8.0


# Change config files and restart the source
for cnf_bcp in "$mysqld_cnf_path".bcp.{1..999}
do
    if [ ! -e $cnf_bcp ]
    then
        mv "$mysqld_cnf_path" "$cnf_bcp"
        break
    fi
done

cp "$mysqld_new_cfg" "$mysqld_cnf_path"

systemctl restart mysql.service
! grep -s -e "err" -e "warn" "$mysqld_err_log_path"


# Create replica user
mysql <<EOF
DROP USER IF EXISTS $repl_usr_name@'%';
CREATE USER $repl_usr_name@'%' IDENTIFIED WITH 'caching_sha2_password' BY '$repl_usr_pass';
GRANT REPLICATION SLAVE ON *.* TO $repl_usr_name@'%';
EOF


# Create backup user
mysql <<EOF
DROP USER IF EXISTS $bcp_usr_name@'%';
CREATE USER $bcp_usr_name@'%' IDENTIFIED WITH 'caching_sha2_password' BY '$bcp_usr_pass';
GRANT ALL ON *.* TO $bcp_usr_name@'%'; -- I just don't want to deal with MySQL priviledge system.
EOF


# Create wordpress database
mysql <<EOF
CREATE DATABASE IF NOT EXISTS $wp_db_name
    CHARACTER SET = utf8mb4
    COLLATE = utf8mb4_general_ci
;
EOF


# Create wordpress user
mysql <<EOF
CREATE USER IF NOT EXISTS $wp_usr_name@'%' IDENTIFIED WITH 'sha256_password' BY '$wp_usr_pass'
    -- 'caching_sha2_password' BY '$wp_usr_pass' -- wp-php-apache-node doesnot support this method
;
GRANT ALL PRIVILEGES ON $wp_db_name.* TO $wp_usr_name@'%'
;
EOF


# Fortify iptables
# silent install, tnx to https://gist.github.com/alonisser/a2c19f5362c2091ac1e7?permalink_comment_id=2264059#gistcomment-2264059
echo iptables-persistent iptables-persistent/autosave_v4 boolean true | sudo debconf-set-selections
echo iptables-persistent iptables-persistent/autosave_v6 boolean true | sudo debconf-set-selections
apt-get -yq install iptables-persistent
"$new_ip4rules"
iptables-save > "$etc_ip4_rules" 

