#!/bin/bash -e


# This script downloads, installs and configures Wordpress 6.4.3.


wordpress_tgz_url='https://wordpress.org/wordpress-6.4.3.tar.gz'
wordpress_file_tgz='./wordpress-6.4.3.tar.gz'
target_dir='/var/nfs_data/www-data'


# Get Wordpress into NFS share

if [ ! -e "$wordpress_file_tgz" ]
then
    curl -s -o "$wordpress_file_tgz" "$wordpress_tgz_url" 
fi
tar xzf "$wordpress_file_tgz" --one-top-level="$target_dir" --skip-old-files --no-overwrite-dir


# Configure DBMS connection

