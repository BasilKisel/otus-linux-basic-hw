#!/bin/bash

# Please, do not execute this file if you are not sure what you are doing!

iptables -t filter -F INPUT
iptables -t filter -A INPUT -s 127.0.0.1 -d 127.0.0.1 -j ACCEPT # A test showed 127.0.0.1 didn't work while localhost did.
iptables -t filter -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT # To let out connections be carring out.
iptables -t filter -A INPUT -p tcp -m multiport --dports 80,22,443,53,853,3306,8081 -j ACCEPT
iptables -t filter -A INPUT -p udp --dport 53 -j ACCEPT # DNS answers
iptables -t filter -P INPUT DROP
