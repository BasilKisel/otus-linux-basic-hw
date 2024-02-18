#!/bin/bash +e

while true
do
    curl http://192.168.1.17/hello.php
    sleep "0.$RANDOM"s
done
