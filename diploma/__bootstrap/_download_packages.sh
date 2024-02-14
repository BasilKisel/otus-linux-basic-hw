#!/bin/bash -e

# This script downloads DEB packages into a bootstrap VM image.


# all nodes
## metrics
apt-get install --download-only -y prometheus-node-exporter
## firewall
apt-get install --download-only -y iptables-persistent
## admin files, web-app files
apt-get install --download-only -y nfs-common

# reverse proxy
apt-get install --download-only -y nginx prometheus-nginx-exporter
# web-app
apt-get install --download-only -y docker.io
# dbms
apt-get install --download-only -y mysql-server-8.0
# file share
apt-get install --download-only -y nfs-kernel-server
# elk
apt-get install --download-only -y default-jdk
