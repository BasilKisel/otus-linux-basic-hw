#!/bin/bash

# This script installs prometheous, and graphana.
# It changes prometheus's config to point on nginx node at 192.168.1.8


prom_examples='/usr/share/doc/prometheus/examples/'
prom_conf_dir='/etc/prometheus/'
prom_conf_file='prometheus.yml'


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
cp -n "${prom_examples}console_libraries/"* "${prom_conf_dir}console_libraries/"
cp -n "${prom_examples}consoles/"* "${prom_conf_dir}consoles/"
mv "${prom_conf_dir}consoles/index.html.example" "${prom_conf_dir}consoles/index.html"

# Copy prometheus' config with node 192.168.1.8
if [ -f "$prom_conf_dir$prom_conf_file" ]
then
    for new_bac in "$prom_conf_file.bac."{1..999}
    do
        if ! [ -f "$prom_conf_dir$new_bac" ]
        then
            mv "$prom_conf_dir$prom_conf_file" "$prom_conf_dir$new_bac"
            echo "$0: Backed up '$prom_conf_dir$prom_conf_file' to '$prom_conf_dir$new_bac'"
            break
        fi
    done
fi

cp "./$prom_conf_file" "$prom_conf_dir"


# Start up services
systemctl daemon-reload
systemctl enable prometheus
systemctl start prometheus
systemctl reload prometheus
systemctl enable prometheus-node-exporter
systemctl start prometheus-node-exporter
systemctl enable grafana-server
systemctl start grafana-server
