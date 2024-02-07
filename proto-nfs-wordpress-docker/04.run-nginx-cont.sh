#!/bin/bash -e


# This script builds, and runs nginx:1.25.3 container with Wordpress on nfs share.


image_file='./nginx:1.25.3.tar'


# Prepare docker images

docker image load -q -i "$image_file"
docker ...
