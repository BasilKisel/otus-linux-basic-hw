#!/bin/bash

# This script makes shure the homework will be run at all costs.

# Redefine Apache2's ports.config for homework
if [ ! -e /etc/apache2/ports.conf.bac ]
then
    mv /etc/apache2/ports.conf /etc/apache2/ports.conf.bac
    ln ./apache2-ports.conf /etc/apache2/ports.conf
fi

# Since security is really concert with HTTPD, I'll map my index.html to Apache2's data dir
mkdir /var/www/html8081
ln -f ./html8081/index.html /var/www/html8081/index.html
mkdir /var/www/html8082
ln -f ./html8082/index.html /var/www/html8082/index.html
mkdir /var/www/html8083
ln -f ./html8083/index.html /var/www/html8083/index.html

# Activates HW's "my-sites" config
ln -f ./apache2-my-sites.conf /etc/apache2/sites-available/my-sites.conf
a2ensite my-sites
systemctl enable apache2
systemctl start apache2
systemctl reload apache2

# Add my config to NGINX
ln -f ./nginx-my-sites-upstreamed.conf /etc/nginx/sites-enabled/nginx-my-sites-upstreamed.conf
if [ -e /etc/nginx/sites-enabled/default ]
then
    rm /etc/nginx/sites-enabled/default
fi
systemctl enable nginx
systemctl start nginx
systemctl reload nginx

