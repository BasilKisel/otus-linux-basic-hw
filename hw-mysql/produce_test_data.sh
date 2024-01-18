#!/bin/bash

# Writes current date and time into the test table every 1 sec.

for i in {1..999}
do
    mysql --batch --skip-column-names -e "INSERT INTO test_db.mytbl (foo) VALUES (DATE_FORMAT(NOW(), '%Y-%m-%d %H-%i-%S'))"
    sleep 1
done
