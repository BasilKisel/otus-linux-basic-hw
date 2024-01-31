#!/bin/bash

# This script shoots at 192.168.1.8:80 as many times as the users asked.
# The first argument should be a number between 0 and 100000.

declare -i count=$(($1))
if echo "$1" | grep -s -v -e '[0-9]\+' || [ $count -lt 0 -o $count -gt 100000 ]
then
    echo "$0: Usage ./$0 NUMBER_OF_QUERIES"
    exit 1
fi

while [ $count -gt 0 ]
do
    curl -s 192.168.1.8:80 >/dev/null 2>&1 &
    let count-=1
done

