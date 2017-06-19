#!/bin/bash

docker kill $(docker ps -a -q)
docker rm $(docker ps -a -q)

#docker rmi res/apache_static
#docker rmi res/express_dynamic
#docker rmi res/traefik

docker build -t res/apache_static docker-images/apache-php-images/.
docker build -t res/express_dynamic docker-images/express-images/.

#static containers
for i in {1..5}
do
   docker run -d res/apache_static;
done

#dynamic containers
for i in {1..5}
do
   docker run -d res/express_dynamic;
done

#traefik
docker build -t res/traefik docker-images/traefik/.
docker run -d -p 8888:8080 -p 8080:80 -v /var/run/docker.sock:/var/run/docker.sock res/traefik