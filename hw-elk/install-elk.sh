#!/bin/bash -e

# This script installs ELK stack.
# It configures logstash to pull nginx logs.
# Parameters are
# -se, --skip-elastic
# -sk, --skip-kibana
# -sl, --skip-logstash


elasticsearch_deb_file='elasticsearch_8.9.1_amd64-224190-509cdd.deb'
elasticsearch_etc_dir='/etc/elasticsearch'
elasticsearch_yml_file='elasticsearch.yml'
elasticsearch_jvm_opt_dir='/etc/elasticsearch/jvm.options.d'
elasticsearch_jvm_opt_file='jvm.options'

kibana_deb_file='kibana_8.9.1_amd64-224190-c09868.deb'
kibana_etc_dir='/etc/kibana'
kibana_yml_file='kibana.yml'

logstash_deb_file='logstash_8.9.1_amd64-224190-e7a1b1.deb'
logstash_etc_dir='/etc/logstash'
logstash_yml_file='logstash.yml'
logstash_nginx_conf_dir='/etc/logstash/conf.d'
logstash_nginx_conf_file='logstash-nginx-es.conf'

false_val=0
true_val=1

# Check prerequisites.

if [ `id -u` != 0 ]
then
    echo "$0: One should be root to start this script. Bye!"
    exit 1
fi

if [ ! -f "./$elasticsearch_deb_file" ]
then
    echo "$0: Cannot locate './$elasticsearch_deb_file'. Please, provide a package and restart this script."
    exit 2
fi

if [ ! -f "./$kibana_deb_file" ]
then
    echo "$0: Cannot locate './$kibana_deb_file'. Please, provide a package and restart this script."
    exit 2
fi

if [ ! -f "./$logstash_deb_file" ]
then
    echo "$0: Cannot locate './$logstash_deb_file'. Please, provide a package and restart this script."
    exit 2
fi

# Check parameters

skip_elastic=$false_val
skip_kibana=$false_val
skip_logstash=$false_val

while
    case $1 in
      '-se') skip_elastic=$true_val
        ;;
      '--skip-elastic') skip_elastic=$true_val
        ;;
      '-sk') skip_kibana=$true_val
        ;;
      '--skip-kibana') skip_kibana=$true_val
        ;;
      '-sl') skip_logstash=$true_val
        ;;
      '--skip-logstash') skip_logstash=$true_val
        ;;
    esac
    shift
do true
done



if [ "$skip_elastic" -ne "$true_val" ]
then
    # Install elasticsearch
    
    apt-get -y install default-jdk # Elastic works over JVM
    dpkg -i "./$elasticsearch_deb_file"
    apt-get --fix-broken -y install
    
    systemctl daemon-reload
    systemctl disable --now elasticsearch.service
    
    # Configure elasticsearch
    
    if [ -f "$elasticsearch_jvm_opt_dir/$elasticsearch_jvm_opt_file" ]
    then
        for new_bac in "$elasticsearch_jvm_opt_file.bac."{1..999}
        do
            if ! [ -f "$elasticsearch_jvm_opt_dir/$new_bac" ]
            then
                mv "$elasticsearch_jvm_opt_dir/$elasticsearch_jvm_opt_file" "$elasticsearch_jvm_opt_dir/$new_bac"
                echo "$0: Backed up '$elasticsearch_jvm_opt_dir/$elasticsearch_jvm_opt_file' to '$elasticsearch_jvm_opt_dir/$new_bac'"
                cp "./$elasticsearch_jvm_opt_file" "$elasticsearch_jvm_opt_dir/"
                break
            fi
        done
    fi
    
    if [ -f "$elasticsearch_etc_dir/$elasticsearch_yml_file" ]
    then
        for new_bac in "$elasticsearch_yml_file.bac."{1..999}
        do
            if ! [ -f "$elasticsearch_etc_dir/$new_bac" ]
            then
                mv "$elasticsearch_etc_dir/$elasticsearch_yml_file" "$elasticsearch_etc_dir/$new_bac"
                echo "$0: Backed up '$elasticsearch_etc_dir/$elasticsearch_yml_file' to '$elasticsearch_etc_dir/$new_bac'"
                cp "./$elasticsearch_yml_file" "$elasticsearch_etc_dir/"
                break
            fi
        done
    fi
    
    systemctl enable --now elasticsearch.service

fi




if [ "$skip_kibana" -ne "$true_val" ]
then
    # Install kibana
    
    dpkg -i "./$kibana_deb_file"
    apt-get --fix-broken -y install
    
    systemctl daemon-reload
    systemctl disable --now kibana.service
    
    # Configure kibana
    
    if [ -f "$kibana_etc_dir/$kibana_yml_file" ]
    then
        for new_bac in "$kibana_yml_file.bac."{1..999}
        do
            if ! [ -f "$kibana_etc_dir/$new_bac" ]
            then
                mv "$kibana_etc_dir/$kibana_yml_file" "$kibana_etc_dir/$new_bac"
                echo "$0: Backed up '$kibana_etc_dir/$kibana_yml_file' to '$kibana_etc_dir/$new_bac'"
                cp "./$kibana_yml_file" "$kibana_etc_dir/"
                break
            fi
        done
    fi
    
    systemctl enable --now kibana.service

fi



if [ "$skip_logstash" -ne "$true_val" ]
then
    # Install logstash
    
    dpkg -i "./$logstash_deb_file"
    apt-get --fix-broken -y install
    
    systemctl daemon-reload
    systemctl disable --now logstash.service
    
    # Configure logstash
    
    if [ -f "$logstash_etc_dir/$logstash_yml_file" ]
    then
        for new_bac in "$logstash_yml_file.bac."{1..999}
        do
            if ! [ -f "$logstash_etc_dir/$new_bac" ]
            then
                mv "$logstash_etc_dir/$logstash_yml_file" "$logstash_etc_dir/$new_bac"
                echo "$0: Backed up '$logstash_etc_dir/$logstash_yml_file' to '$logstash_etc_dir/$new_bac'"
                cp "./$logstash_yml_file" "$logstash_etc_dir/"
                break
            fi
        done
    fi
    
    if [ -f "$logstash_nginx_conf_dir/$logstash_nginx_conf_file" ]
    then
        rm "$logstash_nginx_conf_dir/$logstash_nginx_conf_file"
    fi
    cp "./$logstash_nginx_conf_file" "$logstash_nginx_conf_dir/"

    systemctl enable --now logstash.service

fi
