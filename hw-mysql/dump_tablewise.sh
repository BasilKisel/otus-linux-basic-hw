#!/bin/bash

# Makes tablewise backup from local MySQL instance.
# Demands access to database for a local user.
# If there is foreign keys in a database (for OLTP be sure there are), backup harly will be at any use.
# Written by Basil Kisel.

BCP_DIR=backup
if [ ! -d $BCP_DIR ]
then
    mkdir $BCP_DIR
fi

MYSQL_DO="mysql --batch --skip-column-names -e "

$MYSQL_DO "STOP REPLICA"

for db in `$MYSQL_DO "SELECT db.schema_name FROM information_schema.schemata AS db"`
do
    if [ ! -d $db ]
    then
        mkdir ./"$BCP_DIR"/"$db"
    fi

    for tbl in `$MYSQL_DO "SELECT tbl.table_name FROM information_schema.tables AS tbl WHERE tbl.table_schema = '$db' and tbl.table_type = 'BASE TABLE'"`
    do
        mysqldump \
            --add-drop-table \
            --add-locks \
            --create-options \
            --single-transaction \
            --triggers \
            --source-data \
            --set-gtid-purged=OFF \
            --databases "$db" \
            --tables "$tbl" \
          | gzip -1 > ./"$BCP_DIR"/"$db"/"$tbl".sql.gz
    done
done

$MYSQL_DO "START REPLICA"
