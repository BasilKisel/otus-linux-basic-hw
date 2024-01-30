#!/bin/bash

# This script installs nginx exporter for Prometheus in Ubuntu 22.04.
# It shell be started as root.
# No parameters required.


# Check prerequisites.

if [ `id -u` != 0 ]
then
    echo "$0: One should be root to start this script. Bye!"
    exit 1
fi


site_avail_dir='/etc/nginx/sites-available/'
site_enabl_dir='/etc/nginx/sites-enabled/'
stub_conf_path='nginx-stub-status.conf'
ng_exp_sysd_path='/lib/systemd/system/'
ng_exp_sysd_srv='prometheus-nginx-exporter.service'


if ! [ -d "$site_avail_dir" ]
then
    echo "$: Cannot find '$site_avail_dir'."
    exit 2
fi

if ! [ -d "$site_enabl_dir" ]
then
    echo "$: Cannot find '$site_enabl_dir'."
    exit 3
fi

if ! [ -d "$ng_exp_sysd_path" ]
then
    echo "$: Cannot find '$ng_exp_sysd_path'."
    exit 4
fi


# Prometheus-nginx-exporter scrabs metrics from stub page.
# Code below activate the page in nginx.

if [ -f "$site_avail_dir$stub_conf_path" ]
then
    for new_name in "$stub_conf_path.bac."{1..999}
    do
        if ! [ -f "$site_avail_dir$new_name" ]
        then
            mv "$site_avail_dir$stub_conf_path" "$site_avail_dir$new_name"
            break
        fi
    done
fi
cp "$stub_conf_path" "$site_avail_dir"
chmod ugo+r "$site_avail_dir$stub_conf_path"

if ! [ -L "$site_enabl_dir$stub_conf_path" ]
then
    ln -s -t "$site_enabl_dir" "$site_avail_dir$stub_conf_path"
fi

if ! `nginx -t`
then
    echo "$0: nginx configuration broken. Please, fix the issue and restart the script."
    exit 5
fi

systemctl reload nginx.service


# Do actually install exporters.

apt-get -y install prometheus-node-exporter prometheus-nginx-exporter


# Point exporter to the nginx's metric page.

if [ -f "$ng_exp_sysd_path$ng_exp_sysd_srv" ]
then
    for new_name in "$ng_exp_sysd_srv.bac."{1..999}
    do
        if ! [ -f "$ng_exp_sysd_path$new_name" ]
        then
            mv "$ng_exp_sysd_path$ng_exp_sysd_srv" "$ng_exp_sysd_path$new_name"
            break
        fi
    done
fi
cp "$ng_exp_sysd_srv" "$ng_exp_sysd_path"

systemctl daemon-reload
systemctl enable prometheus-nginx-exporter
systemctl restart prometheus-nginx-exporter
