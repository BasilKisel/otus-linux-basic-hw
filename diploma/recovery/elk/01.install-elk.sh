#!/bin/bash

# This script installs ELK stack: elasticsearch, logstash, kibana.
# It changes VM's IP4 to 192.168.1.19


if [ `id -u` != 0 ]
then
    echo "$0: One must be root to start this script. Bye!"
    exit 1
fi


# elasticsearch
es_deb='./elk/elasticsearch_8.9.1_amd64-224190-509cdd.deb'
es_yml_trg='/etc/elasticsearch/elasticsearch.yml'
es_yml_src='./elasticsearch-cfg/elasticsearch.yml'
es_jvm_opt_trg='/etc/elasticsearch/jvm.options.d/jvm.options'
es_jvm_opt_src='./elasticsearch-cfg/jvm.options'
# kibana
ki_deb='./elk/kibana_8.9.1_amd64-224190-c09868.deb'
ki_yml_trg='/etc/kibana/kibana.yml'
ki_yml_src='./kibana-cfg/kibana.yml'
# logstash
ls_deb='./elk/logstash_8.9.1_amd64-224190-e7a1b1.deb'
ls_yml_trg='/etc/logstash/logstash.yml'
ls_yml_src='./logstash-cfg/logstash.yml'
ls_flt_dir='/etc/logstash/conf.d'
ls_nginx_flt_src='./logstash-cfg/logstash-nginx-es.conf'
ls_apache_flt_src='./logstash-cfg/logstash-apache-es.conf'
# iptables
new_ip4rules='./network-cfg/_ip4.elk.rules.sh'
etc_ip4_rules='/etc/iptables/rules.v4'


# Check prerequisites
if [ ! -f "$es_deb" ]
then
    echo "$0: Cannot locate '$es_deb'. Please, provide a package and restart this script."
    exit 2
fi

if [ ! -f "$ki_deb" ]
then
    echo "$0: Cannot locate '$ki_deb'. Please, provide a package and restart this script."
    exit 2
fi

if [ ! -f "$ls_deb" ]
then
    echo "$0: Cannot locate '$ls_deb'. Please, provide a package and restart this script."
    exit 2
fi


# Install elasticsearch
apt-get -yq install default-jdk # Elastic works over JVM
dpkg -i "$es_deb"
apt-get --fix-broken -yq install
systemctl daemon-reload
systemctl disable --now elasticsearch.service


# Configure elasticsearch
if [ -f "$es_jvm_opt_trg" ]
then
    for new_bac in "$es_jvm_opt_trg.bac."{1..999}
    do
        if ! [ -f "$new_bac" ]
        then
            mv "$es_jvm_opt_trg" "$new_bac"
            echo "$0: Backed up '$es_jvm_opt_trg' to '$new_bac'"
            break
        fi
    done
fi
cp "$es_jvm_opt_src" "$es_jvm_opt_trg"
chmod ugo+r "$es_jvm_opt_trg"
if [ -f "$es_yml_trg" ]
then
    for new_bac in "$es_yml_trg.bac."{1..999}
    do
        if ! [ -f "$new_bac" ]
        then
            mv "$es_yml_trg" "$new_bac"
            echo "$0: Backed up '$es_yml_trg' to '$new_bac'"
            break
        fi
    done
fi
cp "$es_yml_src" "$es_yml_trg"
chmod ugo+r "$es_yml_trg"
systemctl enable --now elasticsearch.service


# Install kibana
dpkg -i "$ki_deb"
apt-get --fix-broken -yq install
systemctl daemon-reload
systemctl disable --now kibana.service


# Configure kibana
if [ -f "$ki_yml_trg" ]
then
    for new_bac in "$ki_yml_trg.bac."{1..999}
    do
        if ! [ -f "$ki_yml_trg/$new_bac" ]
        then
            mv "$ki_yml_trg" "$new_bac"
            echo "$0: Backed up '$ki_yml_trg' to '$new_bac'"
            break
        fi
    done
fi
cp "$ki_yml_src" "$ki_yml_trg"
chmod ugo+r "$ki_yml_trg"
systemctl enable --now kibana.service


# Install logstash
dpkg -i "$ls_deb"
apt-get --fix-broken -yq install
systemctl daemon-reload
systemctl disable --now logstash.service


# Configure logstash
if [ -f "$ls_yml_trg" ]
then
    for new_bac in "$ls_yml_trg.bac."{1..999}
    do
        if ! [ -f "$new_bac" ]
        then
            mv "$ls_yml_trg" "$new_bac"
            echo "$0: Backed up '$ls_yml_trg' to '$new_bac'"
            break
        fi
    done
fi
cp "$ls_yml_src" "$ls_yml_trg"
chmod ugo+r "$ls_yml_trg"
cp "$ls_nginx_flt_src" "$ls_flt_dir"
cp "$ls_apache_flt_src" "$ls_flt_dir"
chmod ugo+r "$ls_flt_dir"/*
systemctl enable --now logstash.service


# Install and run prometheus node exporter
apt-get -yq install prometheus-node-exporter
systemctl enable prometheus-node-exporter
systemctl start prometheus-node-exporter


# Fortify iptables
# silent install, tnx to https://gist.github.com/alonisser/a2c19f5362c2091ac1e7?permalink_comment_id=2264059#gistcomment-2264059
echo iptables-persistent iptables-persistent/autosave_v4 boolean true | sudo debconf-set-selections
echo iptables-persistent iptables-persistent/autosave_v6 boolean true | sudo debconf-set-selections
apt-get -yq install iptables-persistent
"$new_ip4rules"
iptables-save > "$etc_ip4_rules" 
