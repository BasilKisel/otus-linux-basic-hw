#!/bin/bash

./dump-host-port.sh 192.168.1.8 80 > './192.168.1.8_80.tcpdump'
chmod 666 './192.168.1.8_80.tcpdump'
