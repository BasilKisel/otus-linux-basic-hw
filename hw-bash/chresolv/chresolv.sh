#!/bin/bash

# The script changes /etc/resolv.conf according to args.
# Args are IPv4 nameservers in amount of 2 precisely.


# Special env path to stub file to test the script
if [ -e "$CHRESOLV_STUB_FILE" ]
then
    resolvconf="$CHRESOLV_STUB_FILE"
    echo "$0: using '$resolvconf' as a target resolv.conf file."
else
    resolvconf="/etc/resolv.conf"
fi
    

if [ "$1" == '-h' -o "$1" == '--help' -o $# -eq 0 ]
then
    echo "$0: This script takes exactly 2 args - DNS server IPv4 addresses."
    echo "$0: It makes shure these addresses are the only nameservers in '$resolvconf'"
    echo "$0: Usage: $0 DNS_IPv4 DNS_IPv4"
    exit 1
elif [ $# -eq 1 -o $# -gt 2 ]
then
    echo "$0: Incorrect number of arguments. Expected 2, got $#"
    exit 2
elif [ $1 == $2 ]
then
    echo "$0: Expected two different nameservers, got two repetitions of '$1'"
    exit 3
elif [ ! -r "$resolvconf" -a -f "$resolvconf" ]
then
    echo "$0: You have no permission to read '$resolvconf'"
    exit 4
else
    # get exactly 2 args here

    ns_count=$(grep -c -s -E "^nameserver" "$resolvconf")
    if [ $ns_count -eq 2 ]
    then
        ns_matched_count=$(grep -E "^nameserver" "$resolvconf" | grep -E "($1|$2)" -c)
        if [ $ns_matched_count -eq 2 ]
        then
            echo "$0: '$resolvconf' has entries for '$1' and '$2'. No more nameservers found. Nothing to do. Bye!"
            exit 0
        fi
    fi
    
    if [ $ns_count -gt 0 ]
    then
        echo "$0: Next entries will be removed from '$resolvconf':"
        grep -s -E "^nameserver" "$resolvconf"
    fi

    if [ ! -f "$resolvconf" ]
    then
        touch "$resolvconf"
        chmod 744 "$resolvconf"
        chown root:root "$resolvconf"
    fi

    # 'resolv.conf' file exists and nameservers update is needed

    if [ ! -w "$resolvconf" ]
    then
        echo "$0: You have no permission to change '$resolvconf'"
        exit 6
    fi

    sed -e '/^nameserver.+/d' "$resolvconf" > "$resolvconf"
    echo -e "\nnameserver $1\nnameserver $2" >> "$resolvconf"
    echo "$0: '$resolvconf' updated."
    exit 0
fi

