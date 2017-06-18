#!/bin/bash

docker kill $(docker ps -a -q)
docker rm $(docker ps -a -q)

docker rmi res/apache_static
docker rmi res/express_dynamic
docker rmi res/apache_rp

docker build -t res/apache_static docker-images/apache-php-images/.
docker build -t res/express_dynamic docker-images/express-images/.
docker build -t res/apache-rp docker-images/apache-reverse-proxy/.

docker run -d res/apache_static
docker run -d res/express_dynamic
docker run -d -p 8080:80 res/apache-rp

# Access demo.res.ch:8080