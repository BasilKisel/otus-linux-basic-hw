#!/bin/bash -e


# This script downloads, installs and configures Wordpress 6.4.3.


wp_tgz_url='https://wordpress.org/wordpress-6.4.3.tar.gz'
wp_file_tgz='./wordpress-6.4.3.tar.gz'
target_dir='/var/nfs-data/www-data/wordpress-6.4.3'
wp_config_path="$target_dir/wordpress-6.4.3/wordpress/wp-config.php"
wp_sample_config_path="$target_dir/wordpress-6.4.3/wordpress/wp-config-sample.php"
wp_def_config='./wp.conf/wp-config.php'
qc_page_src='./wp.conf/hello.php'
qc_page_trg="$target_dir/wordpress-6.4.3/wordpress/hello.php"



# Get Wordpress into NFS share

[ -e "$wp_file_tgz" ] || curl -s -o "$wp_file_tgz" "$wp_tgz_url" 
tar xzf "$wp_file_tgz" -C "$target_dir/" --skip-old-files


# Configure DBMS connection and secret keys

[ -e "$wp_config_path" ] || cp "$wp_def_config" "$wp_config_path"
[ ! -e "$wp_sample_config_path" ] || rm "$wp_sample_config_path"


# Create quick check page
mv "$qc_page_src" "$qc_page_trg"
