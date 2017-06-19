FROM php:7.0-apache

LABEL "traefik.backend"="apache-static"
LABEL "traefik.port"="80"
LABEL "traefik.frontend.rule"="PathPrefixStrip: /"
LABEL "traefik.backend.loadbalancer.sticky"="true"

RUN apt-get update && \
  apt-get install -y vim

COPY content/ /var/www/html/