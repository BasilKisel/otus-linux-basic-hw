#!/bin/bash

# This script build and starts a docker container Nginx at port 80
# with configuration file "./nginx-my-sites-upstreamed.conf".


# CONFIG
TARGET_PORT=8085

if [ ! `id -u` = 0 ]
then
    echo "$0: Launch this script as root."
    exit 1
fi

# Build image
pushd ./nginx-fe
docker build -t my-nginx-fe .
popd

# Start a container
docker run -d --name my-nginx-balancer -p $TARGET_PORT:80 my-nginx-fe

