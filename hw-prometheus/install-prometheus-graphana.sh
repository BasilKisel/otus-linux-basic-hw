#!/bin/bash

# This script installs prometheous, and graphana.
# It changes prometheus's config to point on nginx node at 192.168.1.8

if [ `id -u` != 0 ]
then
    echo "$0: One must be root to start this script. Bye!"
    exit 1
fi

# Install packages
apt -y install prometheus
dpkg -i grafana_10.2.2_amd64_224190_2cad86-224190-460adc.deb
apt -fy install

# Prepare prothemeus consoles
cp -n /usr/share/doc/prometheus/examples/console_libraries/* /etc/prometheus/console_libraries/
cp -n /usr/share/doc/prometheus/examples/consoles/* /etc/prometheus/consoles/
mv /etc/prometheus/consoles/index.html.example /etc/prometheus/consoles/index.html

# Start up services
systemctl daemon-reload
systemctl enable prometheus
systemctl start prometheus
systemctl enable prometheus-node-exporter
systemctl start prometheus-node-exporter
systemctl enable grafana-server
systemctl start grafana-server
