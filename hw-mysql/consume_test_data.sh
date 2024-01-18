#!/bin/bash

# Prints the biggest value in the test table every 1 sec.

for i in {1..999}
do
    mysql --batch --skip-column-names -e "select foo from test_db.mytbl order by foo desc limit 1"
    sleep 1
done
