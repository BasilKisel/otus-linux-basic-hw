#!/bin/bash -e


# Installs NFS client tools and attaches a share permanently.


share_local_dir='/var/www-data'
share_remote_dir='/var/nfs-data/www-data'
share_ip='192.168.1.9'


# Install nfs client tools

apt-get -yq install nfs-common


# Attach a share

[ -d "$share_local_dir" ] || mkdir -p "$share_local_dir"
mount_cmd="$share_ip:$share_remote_dir $share_local_dir nfs auto,nofail,noatime,tcp,actimeo=0,_netdev 0 0" 
grep -s -e "$share_local_dir" /etc/fstab > /dev/null || echo "$mount_cmd" >> /etc/fstab
# auto - mount at a boot time
# nofail - do not fail a boot if mount fails
# noatime - do not update access time of files in a share
# nolock - do not lock files in a share
# tcp - use TCP net protocol
# actimeo - sets attributes cache time in seconds
# _netdev - mount after networks has been initialized
# 0 0 - do not dump anything from nfsk

mount "$share_local_dir"
