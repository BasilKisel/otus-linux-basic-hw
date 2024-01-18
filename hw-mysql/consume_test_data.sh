#!/bin/bash

# Prints the biggest value in the test table every 1 sec.

for i in {1..999}
do
	mysql --batch --skip-column-names -e "SELECT foo FROM test_db.mytbl ORDER BY LENGTH(foo) DESC, foo DESC LIMIT 1"
    sleep 1
done
