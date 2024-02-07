#!/bin/bash -e

# This script creates database for Wordpress CMS.

usr_name='wordpress_user'
usr_pass='7F8VUBpXdLaSgvkO'
db_name='wordpress_db'


# Create wordpress database

mysql <<EOF
CREATE DATABASE IF NOT EXISTS $db_name
    CHARACTER SET = utf8mb4
    COLLATE = utf8mb4_general_ci
;
EOF


# Create wordpress user

mysql <<EOF
CREATE USER IF NOT EXISTS $usr_name@'%' IDENTIFIED WITH 'caching_sha2_password' BY '$usr_pass'
;
GRANT ALL PRIVILEGES ON $db_name.* TO $usr_name@'%'
;
EOF


