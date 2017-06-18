#!/bin/bash

docker kill $(docker ps -a -q)
docker rm $(docker ps -a -q)

docker rmi res/apache_static

docker build -t res/apache_static docker-images/apache-php-images/.

docker run -d -p 8080:80 res/apache_static

docker-machine inspect