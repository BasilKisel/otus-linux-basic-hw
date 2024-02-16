#!/bin/bash -e

# This script installs and configure nginx reverse proxy for web-app.
# It sits on 192.168.1.17


if [ `id -u` != 0 ]
then
    echo "$0: One must be root to start this script."
    exit 1
fi


# nginx
etc_sites_avail='/etc/nginx/sites-available'
etc_sites_enabl='/etc/nginx/sites-enabled'
nginx_src_proxy_conf='./nginx-cfg/nginx-web-app-upstreamed.conf'
nginx_trg_proxy_conf="$etc_sites_avail/nginx-web-app-upstreamed.conf"
nginx_default_conf="$etc_sites_enabl/default"
# iptables
new_ip4rules='./network-cfg/_ip4.nginx.reverse.proxy.rules.sh'
etc_ip4_rules='/etc/iptables/rules.v4'


# Install nginx
apt-get -yq install nginx


# Configure nginx
cp "$nginx_src_proxy_conf" "$nginx_trg_proxy_conf"
chmod ugo+r "$nginx_trg_proxy_conf"
ln -s -f "$nginx_trg_proxy_conf" "$etc_sites_enabl/"
[ ! -L "$nginx_default_conf" ] || rm -f "$nginx_default_conf"
systemctl enable nginx
systemctl restart nginx


# Fortify iptables
# silent install, tnx to https://gist.github.com/alonisser/a2c19f5362c2091ac1e7?permalink_comment_id=2264059#gistcomment-2264059
echo iptables-persistent iptables-persistent/autosave_v4 boolean true | sudo debconf-set-selections
echo iptables-persistent iptables-persistent/autosave_v6 boolean true | sudo debconf-set-selections
apt-get -yq install iptables-persistent
"$new_ip4rules"
iptables-save > "$etc_ip4_rules" 

