#!/bin/bash

# This script installs prometheous, and graphana.
# It changes VM's IP4 to 192.168.1.18


if [ `id -u` != 0 ]
then
    echo "$0: One must be root to start this script. Bye!"
    exit 1
fi


# grafana
grafana_deb='./grafana/grafana_10.2.2_amd64_224190_2cad86-224190-460adc.deb'
# prometheus
prom_examples='/usr/share/doc/prometheus/examples'
prom_conf_dir='/etc/prometheus'
prom_conf_file='./prometheus-cfg/prometheus.yml'
# iptables
new_ip4rules='./network-cfg/_ip4.prometheus.grafana.rules.sh'
etc_ip4_rules='/etc/iptables/rules.v4'


if [ ! -e "$grafana_deb" ]
then
    echo "$0: cannot locate grafana package '$grafana_deb'. Exit."
    exit 2
fi


# Install packages
apt-get -yq install prometheus
dpkg -i "$grafana_deb"
apt-get -fyq install


# Prepare prothemeus consoles
cp -n "$prom_examples/console_libraries/"* "$prom_conf_dir/console_libraries/"
cp -n "$prom_examples/consoles/"* "$prom_conf_dir/consoles/"
mv "$prom_conf_dir/consoles/index.html.example" "$prom_conf_dir/consoles/index.html"


# Replace prometheus's configuration
for cfg_file in `ls -1 -N "$prom_conf_dir"/*.{json,yml,yaml}`
do
    for new_bac in "$cfg_file.bac."{1..999}
    do
        if ! [ -f "$new_bac" ]
        then
            mv "$cfg_file" "$new_bac"
            echo "$0: Backed up '$cfg_file' to '$new_bac'"
            break
        fi
    done
done

cp "./$prom_conf_file" "$prom_conf_dir/"
chmod +r "$prom_conf_dir"/*


# Start up services
systemctl daemon-reload
systemctl enable prometheus
systemctl start prometheus
systemctl reload prometheus
systemctl enable prometheus-node-exporter
systemctl start prometheus-node-exporter
systemctl enable grafana-server
systemctl start grafana-server


# Fortify iptables
# silent install, tnx to https://gist.github.com/alonisser/a2c19f5362c2091ac1e7?permalink_comment_id=2264059#gistcomment-2264059
echo iptables-persistent iptables-persistent/autosave_v4 boolean true | sudo debconf-set-selections
echo iptables-persistent iptables-persistent/autosave_v6 boolean true | sudo debconf-set-selections
apt-get -yq install iptables-persistent
"$new_ip4rules"
iptables-save > "$etc_ip4_rules" 
