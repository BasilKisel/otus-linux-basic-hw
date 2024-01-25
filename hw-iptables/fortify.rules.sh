#!/bin/bash

# Please, do not execute this file if you are not sure what you are doing!

iptables -t filter -F INPUT
iptables -t filter -A INPUT -s 127.0.0.1 -d 127.0.0.1 -j ACCEPT # A test showed 127.0.0.1 didn't work while localhost did.
iptables -t filter -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT # To turn in this homework :)
iptables -t filter -A INPUT -p tcp -m multiport --dports 80,22,443,3306,8081 -j ACCEPT
iptables -t filter -P INPUT DROP
