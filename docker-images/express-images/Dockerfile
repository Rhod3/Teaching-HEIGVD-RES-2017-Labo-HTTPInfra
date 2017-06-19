FROM node:4.4

LABEL "traefik.backend"="express-image"
LABEL "traefik.port"="3000"
LABEL "traefik.frontend.rule"="PathPrefixStrip: /api/students/"
LABEL "traefik.backend.loadbalancer.sticky"="false"

RUN apt-get update && \
  apt-get install -y vim

COPY src /opt/app

EXPOSE 3000

CMD ["node", "/opt/app/index.js"]