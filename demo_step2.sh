#!/bin/bash

docker kill $(docker ps -a -q)
docker rm $(docker ps -a -q)

docker rmi res/express_dynamic

docker build -t res/express_dynamic docker-images/express-images/.

docker run --name express_dynamic -d -p 3000:3000 res/express_dynamic
docker-machine inspect