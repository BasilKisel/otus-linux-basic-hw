#!/bin/bash -e

# This script unpacks wordpress onto dedicated location in NFS share.
 

if [ `id -u` != 0 ]
then
    echo "$0: One must be root to start this script."
    exit 1
fi


# wordpress
wp_tgz_url='https://wordpress.org/wordpress-6.4.3.tar.gz'
wp_file_tgz='./wordpress-6.4.3.tar.gz'
wp_target_dir="/mnt/prod-data-drive/web-app"
wp_config_path="$wp_target_dir/wordpress/wp-config.php"
wp_def_config='./wordpress-cfg/wp-config.php'
qc_page_src='./wordpress-cfg/hello.php'
qc_page_trg="$wp_target_dir/wordpress/hello.php"


# Get Wordpress into NFS share
[ -e "$wp_file_tgz" ] || curl -o "$wp_file_tgz" "$wp_tgz_url" 
[ -d "$wp_target_dir" ] || mkdir -p "$wp_target_dir"
tar xzf "$wp_file_tgz" -C "$wp_target_dir/" --skip-old-files
chmod -R 777 "$wp_target_dir/"


# Configure DBMS connection and secret keys
[ -e "$wp_config_path" ] || cp "$wp_def_config" "$wp_config_path"


# Create quick check page
cp "$qc_page_src" "$qc_page_trg"
