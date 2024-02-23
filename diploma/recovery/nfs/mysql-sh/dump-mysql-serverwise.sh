#!/bin/bash -e

# Makes a backup from MySQL instance.
# This SQL script can restore all user databases of a mysql server.
# Written by Basil Kisel for Otus Linux Basix - diploma project.


mysql_backup_usr_name='backup'
mysql_backup_usr_pass='secret'
mysql_replica_host='192.168.1.14'
mysql_do="mysql -h $mysql_replica_host -u $mysql_backup_usr_name -p$mysql_backup_usr_pass --batch --skip-column-names -e "
mysqldump_do="mysqldump -h $mysql_replica_host -u $mysql_backup_usr_name -p$mysql_backup_usr_pass "
db_bcp_dir='/mnt/prod-data-drive/dbms-bcp/serverwise'


# Choose a target sql file name
trg_sql_file="$db_bcp_dir/$(date -u +%Y%m%d_%H%M%S)_UTC.sql"
while [ -e "$trg_sql_file" ]
do
    echo "$0: '$trg_sql_file' is in use. Sleep for 1 second."
    sleep 1
    trg_sql_file="$db_bcp_dir/all_db_on_$(date -u +%Y%m%d_%H%M%S)_UTC.sql"
done
[ -d  "$db_bcp_dir" ] || mkdir -p "$db_bcp_dir"


# Produce all-user-databases backup
$mysql_do "STOP REPLICA"
$mysql_do  "SELECT db.schema_name AS db FROM information_schema.schemata AS db WHERE db.schema_name NOT IN ('mysql','information_schema','performance_schema','sys')" \
  | xargs $mysqldump_do \
      --source-data=1 \
      --set-gtid-purged=ON \
      --triggers \
      --routines \
      --events \
      --add-drop-database \
      --databases \
      > "$trg_sql_file"
$mysql_do "START REPLICA"


# gzip the sql file
gzip --best "$trg_sql_file"
rm -rf "$trg_sql_file"
chmod 660 "$trg_sql_file.gz"

echo "$0: produced logical backup '$trg_sql_file.gz'."
