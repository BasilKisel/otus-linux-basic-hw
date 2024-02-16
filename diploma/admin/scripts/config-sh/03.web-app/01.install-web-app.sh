#!/bin/bash -e

# This script installs, configure and runs up a web-app container over NFS automount, Docker at 192.168.1.[15-16].


if [ `id -u` != 0 ]
then
    echo "$0: One must be root to start this script."
    exit 1
fi


# nfs share
share_local_dir='/var/web-app'
share_remote_dir='/mnt/prod-data-drive/web-app'
share_ip='192.168.1.12'
mount_cmd="$share_ip:$share_remote_dir $share_local_dir nfs auto,nofail,noatime,tcp,actimeo=0,_netdev 0 0" 
# docker
cont_name='wp-php-apache'
image_name='wp-php-apache:0.01'
dockerfile_dir='php-apache'
host_www_dir="$share_local_dir/wordpress"
cont_www_dir='/var/www/html'
host_apache_log_dir='/var/log/apache2'
cont_apache_log_dir='/var/log/apache2'
php_image_tar='./docker-images/php-7.2-apache.tar'
# iptables
new_ip4rules='./network-cfg/_ip4.web.app.rules.sh'
etc_ip4_rules='/etc/iptables/rules.v4'


# Install nfs client tools
apt-get -yq install nfs-common


# Attach a share
[ -d "$share_local_dir" ] || mkdir -p "$share_local_dir"
grep -s -e "$share_local_dir" /etc/fstab > /dev/null || echo "$mount_cmd" >> /etc/fstab
mount "$share_local_dir"
# auto - mount at a boot time
# nofail - do not fail a boot if mount fails
# noatime - do not update access time of files in a share
# nolock - do not lock files in a share
# tcp - use TCP net protocol
# actimeo - sets attributes cache time in seconds
# _netdev - mount after networks has been initialized
# 0 0 - do not dump anything from nfsk


# Docker
apt-get -yq install docker.io
[ -e "$php_image_tar" ] && docker image load -i "$php_image_tar"
set +e
docker stop "$cont_name"
docker rm "$cont_name"
set -e
[ -d "$host_apache_log_dir" ] || mkdir -p "$host_apache_log_dir"
docker build -t "$image_name" "$dockerfile_dir/."
docker run \
  --name "$cont_name" \
  -v "$host_www_dir":"$cont_www_dir" \
  -v "$host_apache_log_dir":"$cont_apache_log_dir" \
  -p 80:80 \
  -d --restart unless-stopped \
  "$image_name"


# Fortify iptables
# silent install, tnx to https://gist.github.com/alonisser/a2c19f5362c2091ac1e7?permalink_comment_id=2264059#gistcomment-2264059
echo iptables-persistent iptables-persistent/autosave_v4 boolean true | sudo debconf-set-selections
echo iptables-persistent iptables-persistent/autosave_v6 boolean true | sudo debconf-set-selections
apt-get -yq install iptables-persistent
"$new_ip4rules"
iptables-save > "$etc_ip4_rules" 

