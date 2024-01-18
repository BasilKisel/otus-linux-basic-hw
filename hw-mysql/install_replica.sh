#!/bin/bash

# This script installs, configure and runs up a replica of MySQL.
# Created by Basil Kisel.

MYSQL_SRC_IP=192.168.1.8
REPL_USR_NAME=replica
REPL_USR_PASS=secret
BCP_USR_NAME=backup
BCP_USR_PASS=secret

if [ `id -u` -ne 0 ]
then
    echo "One must execute this script as root."
    exit 1
fi


# DO INSTALL MYSQL

apt-get install -y mysql-server-8.0
# ./mysql_secure_installation # Not in use just to speedup the development of this script. I'm late with HW for Otus.


# CHANGE CONFIG FILES AND RESTART THIS REPLICA AS A SOURCE

systemctl stop mysql

MYSQLD_CNF_PATH="/etc/mysql/mysql.conf.d/mysqld.cnf"

for cnf_bcp in "$MYSQLD_CNF_PATH"{1..999}
do
    if [ ! -e $cnf_bcp ]
    then
        mv "$MYSQLD_CNF_PATH" "$cnf_bcp"
        break
    fi
done

cp ./mysqld_source.cnf "$MYSQLD_CNF_PATH"

systemctl restart mysql.service
cat /var/log/mysql/error.log | grep -s -e "err" -e "warn"

mysql -e "STOP REPLICA"


# CREATE replica USER

mysql <<EOF
DROP USER IF EXISTS $REPL_USR_NAME@'%';
CREATE USER $REPL_USR_NAME@'%' IDENTIFIED WITH 'caching_sha2_password' BY '$REPL_USR_PASS';
GRANT REPLICATION SLAVE ON *.* TO $REPL_USR_NAME@'%';
FLUSH PRIVILEGES;
EOF


# CREATE backup USER

mysql <<EOF
DROP USER IF EXISTS $BCP_USR_NAME@'%';
CREATE USER $BCP_USR_NAME@'%' IDENTIFIED WITH 'caching_sha2_password' BY '$BCP_USR_NAME';
GRANT ALL ON *.* TO $BCP_USR_NAME@'%'; -- I just don't want to deal with MySQL priviledge system.
FLUSH PRIVILEGES;
EOF


# RESTORE SOURCE'S DATABASE IN THIS REPLICA

mysql <<EOF
CHANGE MASTER TO MASTER_USER = '$REPL_USR_NAME', MASTER_PASSWORD = '$REPL_USR_PASS', GET_MASTER_PUBLIC_KEY = 1, MASTER_HOST='$MYSQL_SRC_IP';
EOF

# For unknown reasons there is no way to exclude system databases from dumping.
# These DBs cannot be restored at replica:
# 'mysql','information_schema','performance_schema','sys'

# https://dev.mysql.com/doc/refman/8.0/en/mysqldump.html#mysqldump-replication-options
mysql --user="$BCP_USR_NAME" \
      --password="$BCP_USR_PASS" \
      --host="$MYSQL_SRC_IP" \
      --batch --skip-column-names -e "SELECT db.schema_name AS db FROM information_schema.schemata AS db WHERE db.schema_name NOT IN ('mysql','information_schema','performance_schema','sys')" \
  | xargs mysqldump \
      --user="$BCP_USR_NAME" \
      --password="$BCP_USR_PASS" \
      --host="$MYSQL_SRC_IP" \
      --source-data=1 \
      --set-gtid-purged=ON \
      --triggers \
      --routines \
      --events \
      --add-drop-database \
      --databases \
  | mysql


# CONVERT THIS MYSQL INSTANCE INTO A REPLICA

for cnf_bcp in "$MYSQLD_CNF_PATH"{1..999}
do
    if [ ! -e $cnf_bcp ]
    then
        mv "$MYSQLD_CNF_PATH" "$cnf_bcp"
        break
    fi
done

cp ./mysqld_replica.cnf "$MYSQLD_CNF_PATH"

systemctl restart mysql.service
cat /var/log/mysql/error.log | grep -s -e "err" -e "warn"

mysql << EOF
START REPLICA;
SHOW REPLICA STATUS\G
EOF
