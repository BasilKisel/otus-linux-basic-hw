#!/bin/bash

# This script produce tcpdumpt out for server and port.
# Sudo permissions are needed to capture on network card.
# Params:
# 1. server IP address;
# 2. port number.

if [ -z $1 -o -z $2 ]
then
    echo "$0: usage $0 'host_ip' 'port_number'"
    exit 1
fi

if [ `id -u` != 0 ]
then
    echo "$0: One must be root to launch this script. Bye!"
    exit 2
fi

host=$1
port=$2
# FD manupulations, see https://tldp.org/LDP/Bash-Beginners-Guide/html/Bash-Beginners-Guide.html#sect_08_02_04
exec 6>&1
tcpdump "port $port and host $host" -n -vvv >&6 2>&1 & 
exec 6>&-
sleep 1 # Wait for tcpdump to start
curl -s "$host:$port" >/dev/null 2>&1
sleep 2 # Gracious period for tcpdump to print out captured packages.
kill %1
