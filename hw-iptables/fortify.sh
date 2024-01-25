#!/bin/bash

# This script rewrites IP4 rules to block all unwanted net traffic.
# It leaves open all output routes, block all input packages but for ports 80, 22, 443, 3306, 8081.
# All changes are persistent. Backup copy of the previous rules can be found with postfix ".bac.N".

ip4rules="/etc/iptables/rules.v4"

# Check for ROOT
if [ `id -u` != 0 ]
then
    echo "$: You should be root to rewrite IP4 rules. Bye!"
    exit 1
fi

# Backup current rules
for bacN in '.bac.'{1..999}
do
    if [ ! -f "$ip4rules$bacN" ]
    then
        iptables-save -f "$ip4rules$bacN"
        echo "$0: backuped current rules into '$ip4rules$bacN'."
        echo -n "$0: please, hit ENTER to continue..."
        read
        break
    fi
done

# Rewrite rules. Makes them persistent if user confirms.
iptables-apply -t 30 -w "$ip4rules" -c "./fortify.rules.sh"
