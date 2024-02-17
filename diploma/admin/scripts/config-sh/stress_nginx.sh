#!/bin/bash

# This script shoots at 192.168.1.17:80/hello.php as many times as the users asked.
# The first argument should be a number between 0 and 100000.

declare -i count=$(($1))
if echo "$1" | grep -s -v -e '[0-9]\+' || [ $count -lt 0 -o $count -gt 100000 ]
then
    count=1000
    echo "$0: Usage ./$0 NUMBER_OF_QUERIES. Use $count by default."
fi

while [ $count -gt 0 ]
do
    curl -s 192.168.1.17:80/hello.php >/dev/null 2>&1 &
    let count-=1
done

