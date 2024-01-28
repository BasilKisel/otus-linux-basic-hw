#!/bin/bash

# This script dumps a response from 192.168.1.8:80 into a file.

host=192.168.1.8
port=80
outfile='./192.168.1.8_80.pcap' 

# Sudo permissions are needed to capture on network card.
if [ `id -u` != 0 ]
then
    echo "$0: One must be root to launch this script. Bye!"
    exit 2
fi

tcpdump "port $port and host $host" -n -vvv -w "$outfile" &
sleep 1 # Wait for tcpdump to start
curl -s "$host:$port" >/dev/null 2>&1
sleep 2 # Gracious period for tcpdump to print out captured packages.
kill %1

