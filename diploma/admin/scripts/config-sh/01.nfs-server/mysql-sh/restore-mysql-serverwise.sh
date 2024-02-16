#!/bin/bash -e

# Restores data on MySQL instance from serverwise backups.
# This SQL script can restore all user databases of a mysql server.
# Takes 1 argument - a path to sql.gz file with a logical backup.
# With no arguments choose the newest file by name in the serverwise backup directory.
# Written by Basil Kisel for Otus Linux Basix - diploma project.


mysql_backup_usr_name='backup'
mysql_backup_usr_pass='secret'
mysql_source_host='192.168.1.13'
mysql_conn="mysql -h $mysql_source_host -u $mysql_backup_usr_name -p$mysql_backup_usr_pass"
db_bcp_dir='/mnt/prod-data-drive/dbms-bcp/serverwise'


# Choose a target sql file name
if [ -e "$1" ]
then
    trg_sql_file="$1"
else
    trg_sql_file=`ls -r -1 -N "$db_bcp_dir"/*.sql.gz | head -n 1`
fi


# Restore all databases from backup
gunzip -c "$trg_sql_file" | $mysql_conn


echo "$0: restored databases on '$mysql_source_host' from '$trg_sql_file'."
