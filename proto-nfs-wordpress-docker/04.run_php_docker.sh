#/bin/bash -e

# This script build and run php-apache docker container with wordpress in it.
# It uses nfs to provide wordpress sources and a storage for log files


cont_name='wp-php-apache-node'
image_name='wp-php-apache:0.01'
dockerfile_dir='php-apache'
local_wp_dir='/var/www-data/wordpress-6.4.3/wordpress'
remote_wp_dir='/var/www/html'


set +e
docker stop "$cont_name"
docker rm "$cont_name"
set -e
docker build -t "$image_name" "$dockerfile_dir/."
docker run --restart unless-stopped -d --name "$cont_name" -v "$local_wp_dir":"$remote_wp_dir" -p 80:80 "$image_name"

