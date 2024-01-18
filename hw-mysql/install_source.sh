#!/bin/bash

# This script installs, configure and runs up a source of MySQL.
# Created by Basil Kisel.

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


# CHANGE CONFIG FILES AND RESTART THE SOURCE

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

# CREATE replica USER

mysql <<EOF
DROP USER IF EXISTS $REPL_USR_NAME@'%';
CREATE USER $REPL_USR_NAME@'%' IDENTIFIED WITH 'caching_sha2_password' BY '$REPL_USR_PASS';
GRANT REPLICATION SLAVE ON *.* TO $REPL_USR_NAME@'%';
EOF

# CREATE backup USER

mysql <<EOF
DROP USER IF EXISTS $BCP_USR_NAME@'%';
CREATE USER $BCP_USR_NAME@'%' IDENTIFIED WITH 'caching_sha2_password' BY '$BCP_USR_NAME';
GRANT ALL ON *.* TO $BCP_USR_NAME@'%'; -- I just don't want to deal with MySQL priviledge system.
EOF

# CREATE TEST DB TO BACKUP BEFORE REPLICATION

mysql <<EOF
DROP DATABASE IF EXISTS test_db;
CREATE DATABASE test_db;
CREATE TABLE test_db.mytbl (foo VARCHAR(100) NOT NULL);
INSERT INTO test_db.mytbl (foo) VALUES ('1'), ('2'), ('3');
EOF
