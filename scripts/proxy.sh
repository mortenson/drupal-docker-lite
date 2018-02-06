#!/bin/bash

cd "${0%/*}"

docker stop $(docker ps -a -q --filter name=ddl_proxy) &> /dev/null
docker rm $(docker ps -a -q --filter name=ddl_proxy) &> /dev/null

docker run -d -p 127.0.0.1:8085:8080 -p 127.0.0.1:80:80 -v $PWD/../traefik.toml:/etc/traefik/traefik.toml\
 -v /var/run/docker.sock:/var/run/docker.sock\
 --network ddl_proxy\
 --name ddl_proxy\
 traefik

message_on_error "Proxy startup failed. Is port 8085 or 80 in use?"

echo "The proxy has been started. An administrative console can be found at http://localhost:8085"
