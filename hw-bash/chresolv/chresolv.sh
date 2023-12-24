#!/bin/bash

# The script changes /etc/resolv.conf according to args.
# Args are IPv4 nameservers.

if [ "$1" == '-h' -o "$1" == '--help' -o $# -eq 0 ]
then
    echo "This script takes exactly 2 args - DNS server IPv4 addresses."
    echo -e "It makes shure these addresses are the only nameservers in /etc/resolv.conf\n"
    echo "Usage: $0 DNS_IPv4 DNS_IPv4"
    exit 1
elif [ $# -eq 1 -o $# -gt 2 ]
then
    echo "Incorrect number of arguments. Expected 2, got $#"
    exit 2
elif [ ! -r /etc/resolv.conf -a -f /etc/resolv.conf ]
then
    echo "You have no permission to read /etc/resolv.conf"
    exit 3
else
    # got exactly 2 args here

    ns_count=$(grep -c -s -E "^nameserver" /etc/resolv.conf)
    if [ $ns_count -eq 2 ]
    then
        ns_matched_count=$(grep -E "^nameserver" /etc/resolv.conf | grep -E "($1|$2)" -c)
        if [ $ns_matched_count -eq 2 ]
        then
            echo "/etc/resolv.conf has entries for '$1' and '$2'. No more nameservers found. Nothing to do. Bye!"
            exit 0
        fi
    fi
    
    if [ $ns_count -gt 0 ]
    then
        echo "Next entries will be removed from /etc/resolv.conf:"
        grep -s -E "^nameserver" /etc/resolv.conf
    fi

    if [ ! -f /etc/resolv.conf ]
    then
        touch /etc/resolv.conf
        chmod 744 /etc/resolv.conf
        chown root:root /etc/resolv.conf
    fi

    # file exists and nameservers update is needed

    if [ ! -w "/etc/resolv.conf" ]
    then
        echo "You have no permission to change /etc/resolv.conf"
        exit 5
    fi

    # TODO:: replace nameservers with the passed args
    exit 0
fi



