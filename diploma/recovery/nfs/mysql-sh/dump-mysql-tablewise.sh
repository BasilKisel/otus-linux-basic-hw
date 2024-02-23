#!/bin/bash -e

# Makes tablewise backup from MySQL instance.
# If there is foreign keys in a database (for OLTP be sure there are), backup harly will be at any use.
# Written by Basil Kisel for Otus Linux Basix - diploma project.


mysql_backup_usr_name='backup'
mysql_backup_usr_pass='secret'
mysql_replica_host='192.168.1.14'
mysql_do="mysql -h $mysql_replica_host -u $mysql_backup_usr_name -p$mysql_backup_usr_pass --batch --skip-column-names -e "
mysqldump_do="mysqldump -h $mysql_replica_host -u $mysql_backup_usr_name -p$mysql_backup_usr_pass "
tbl_base_bcp_dir='/mnt/prod-data-drive/dbms-bcp/tablewise'


# Create target directory
trg_bcp_dir="$tbl_base_bcp_dir/$(date -u +%Y%m%d_%H%M%S)_UTC"
while [ -d "$trg_bcp_dir" ]
do
    echo "$0: '$trg_bcp_dir' is in use. Sleep for 1 second."
    sleep 1
    trg_bcp_dir="$tbl_base_bcp_dir/$(date -u +%Y%m%d_%H%M%S)_UTC"
done
mkdir -p "$trg_bcp_dir"


# Produce tablewise backup
$mysql_do "STOP REPLICA"
for db in `$mysql_do "SELECT db.schema_name FROM information_schema.schemata AS db"`
do
    [ -d "$db" ] || mkdir -p "$trg_bcp_dir/$db"

    for tbl in `$mysql_do "SELECT tbl.table_name FROM information_schema.tables AS tbl WHERE tbl.table_schema = '$db' and tbl.table_type = 'BASE TABLE'"`
    do
        $mysqldump_do \
            --add-drop-table \
            --add-locks \
            --create-options \
            --single-transaction \
            --triggers \
            --source-data \
            --set-gtid-purged=OFF \
            --databases "$db" \
            --tables "$tbl" \
          | gzip -1 > "$trg_bcp_dir/$db/$tbl".sql.gz
    done
done
$mysql_do "START REPLICA"


# Tar directory
tar -c -f "$trg_bcp_dir.tar" "$trg_bcp_dir"
rm -rf "$trg_bcp_dir"
chmod 660 "$trg_bcp_dir.tar"

echo "$0: produced tablewise backup '$trg_bcp_dir.tar'."
