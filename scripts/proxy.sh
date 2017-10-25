#!/bin/bash
cd "${0%/*}"

docker stop $(docker ps -a -q --filter name=ddl_proxy) &> /dev/null
docker rm $(docker ps -a -q --filter name=ddl_proxy) &> /dev/null

docker run -d -p 8085:8080 -p 80:80 -v $PWD/../traefik.toml:/etc/traefik/traefik.toml\
 -v /var/run/docker.sock:/var/run/docker.sock\
 --network ddl_proxy\
 --name ddl_proxy\
 traefik

if [ $? -ne 0 ]; then
  echo "Proxy startup failed. Is port 8085 or 80 in use?"
  exit 1
fi

echo "The proxy has been started. An administrative console can be found at http://localhost:8085"
