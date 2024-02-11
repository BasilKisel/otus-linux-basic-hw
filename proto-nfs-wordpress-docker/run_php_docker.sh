#/bin/bash -e

set +e
docker stop wp-php-apache-node
docker rm wp-php-apache-node
set -e
docker build -t wp-php-apache:0.01 .
docker run --restart unless-stopped -d --name wp-php-apache-node -v /var/www-data/wordpress:/var/www/html -p 80:80 wp-php-apache:0.01

