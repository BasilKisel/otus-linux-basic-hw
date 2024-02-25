#!/bin/bash -e

# This script installs, configure and runs up a replica of MySQL at 192.168.1.14.


if [ `id -u` != 0 ]
then
    echo "$0: One must be root to start this script. Bye!"
    exit 1
fi


# mysql-replica
mysql_src_ip='192.168.1.13'
repl_usr_name='replica'
repl_usr_pass='secret'
bcp_usr_name='backup'
bcp_usr_pass='secret'
mysqld_cnf_path='/etc/mysql/mysql.conf.d/mysqld.cnf'
mysqld_source_cfg='./mysql-cfg/mysqld_source.cnf'
mysqld_replica_cfg='./mysql-cfg/mysqld_replica.cnf'
mysqld_err_log_path='/var/log/mysql/error.log'
# iptables
new_ip4rules='./network-cfg/_ip4.mysql.rules.sh'
etc_ip4_rules='/etc/iptables/rules.v4'


# Do install mysql
apt-get install -yq mysql-server-8.0


# Change config files and restart this replica as a source
systemctl stop mysql.service
for cnf_bcp in "$mysqld_cnf_path".bcp.{1..999}
do
    if [ ! -e $cnf_bcp ]
    then
        mv "$mysqld_cnf_path" "$cnf_bcp"
        break
    fi
done
cp "$mysqld_source_cfg" "$mysqld_cnf_path"
chmod ugo+r "$mysqld_cnf_path"
systemctl restart mysql.service
grep -s -e "err" -e "warn" "$mysqld_err_log_path" || true
mysql -e "STOP REPLICA"


# Create replica user
mysql <<EOF
DROP USER IF EXISTS $repl_usr_name@'%';
CREATE USER $repl_usr_name@'%' IDENTIFIED WITH 'caching_sha2_password' BY '$repl_usr_pass';
GRANT REPLICATION SLAVE ON *.* TO $repl_usr_name@'%';
FLUSH PRIVILEGES;
EOF


# Create backup user
mysql <<EOF
DROP USER IF EXISTS $bcp_usr_name@'%';
CREATE USER $bcp_usr_name@'%' IDENTIFIED WITH 'caching_sha2_password' BY '$bcp_usr_pass';
GRANT ALL ON *.* TO $bcp_usr_name@'%'; -- I just don't want to deal with MySQL priviledge system.
FLUSH PRIVILEGES;
EOF


# Restore source's database in this replica

mysql <<EOF
CHANGE MASTER TO MASTER_USER = '$repl_usr_name', MASTER_PASSWORD = '$repl_usr_pass', GET_MASTER_PUBLIC_KEY = 1, MASTER_HOST='$mysql_src_ip';
EOF

# For unknown reasons there is no way to exclude system databases from dumping.
# These DBs cannot be restored at replica:
# 'mysql','information_schema','performance_schema','sys'

# Many tnx to https://mysqldba.blogspot.com/2023/02/error-3546-hy000-at-line-24.html
mysql <<EOF
RESET MASTER;
EOF

# https://dev.mysql.com/doc/refman/8.0/en/mysqldump.html#mysqldump-replication-options
mysql --user="$bcp_usr_name" \
      --password="$bcp_usr_pass" \
      --host="$mysql_src_ip" \
      --batch --skip-column-names -e "SELECT db.schema_name AS db FROM information_schema.schemata AS db WHERE db.schema_name NOT IN ('mysql','information_schema','performance_schema','sys')" \
  | xargs mysqldump \
      --user="$bcp_usr_name" \
      --password="$bcp_usr_pass" \
      --host="$mysql_src_ip" \
      --source-data=1 \
      --set-gtid-purged=ON \
      --triggers \
      --routines \
      --events \
      --add-drop-database \
      --databases \
  | mysql


# Convert this mysql instance into a replica
for cnf_bcp in "$mysqld_cnf_path"{1..999}
do
    if [ ! -e $cnf_bcp ]
    then
        mv "$mysqld_cnf_path" "$cnf_bcp"
        break
    fi
done
cp "$mysqld_replica_cfg" "$mysqld_cnf_path"
chmod ugo+r "$mysqld_cnf_path"
systemctl restart mysql.service
cat "$mysqld_err_log_path" | grep -s -e "err" -e "warn"
mysql << EOF
START REPLICA;
SHOW REPLICA STATUS\G
EOF


# Install and run prometheus node exporter
apt-get -yq install prometheus-node-exporter
systemctl enable prometheus-node-exporter
systemctl start prometheus-node-exporter


# Fortify iptables
# silent install, tnx to https://gist.github.com/alonisser/a2c19f5362c2091ac1e7?permalink_comment_id=2264059#gistcomment-2264059
echo iptables-persistent iptables-persistent/autosave_v4 boolean true | sudo debconf-set-selections
echo iptables-persistent iptables-persistent/autosave_v6 boolean true | sudo debconf-set-selections
apt-get -yq install iptables-persistent
"$new_ip4rules"
iptables-save > "$etc_ip4_rules" 

