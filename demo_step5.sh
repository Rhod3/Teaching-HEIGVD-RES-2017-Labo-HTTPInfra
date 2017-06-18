#!/bin/bash

docker kill $(docker ps -a -q)
docker rm $(docker ps -a -q)

docker rmi res/apache_static
docker rmi res/express_dynamic
docker rmi res/apache_rp

docker build -t res/apache_static docker-images/apache-php-images/.
docker build -t res/express_dynamic docker-images/express-images/.
docker build -t res/apache_rp docker-images/apache-reverse-proxy/.

#static containers
for i in {1..5}
do
   docker run -d res/apache_static;
done

docker run --name apache_static -d res/apache_static;

#dynamic containers
for i in {1..5}
do
   docker run -d res/express_dynamic;
done

docker run --name express_dynamic -d res/express_dynamic;

docker inspect apache_static | grep -i ipaddr

docker inspect express_dynamic | grep -i ipaddr

# docker run -e STATIC_APP=172.17.0.x:80 -e DYNAMIC_APP=172.17.0.y:3000 --name apache_rp -p 8080:80 res/apache_rp