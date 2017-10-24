#!/bin/bash

NAME=$1

if [[ "$PWD" =~ "/code" || -f "docker-compose.yml" ]]; then
  COMPOSE_PATH=${PWD%%/code*}
fi

cd "${0%/*}"

CONTAINER=$(docker ps -q -a --filter name="$NAME"_php --filter "label=drupaldockerlite")

if [[ "$CONTAINER" ]]; then
  shift
elif [[ "$COMPOSE_PATH" ]]; then
  NAME=$(cd "$COMPOSE_PATH" && docker-compose ps -q php | xargs docker inspect -f '{{index .Config.Labels "com.docker.compose.project"}}')
  if [[ "$NAME" ]]; then
    CONTAINER=$(docker ps -q -a --filter name="$NAME"_php --filter "label=drupaldockerlite")
  fi
fi

if [[ ! "$CONTAINER" ]]; then
  echo "No container found for $NAME"
  exit 0
fi

URL=$(./url.sh "$NAME")

docker container exec "$CONTAINER" drush --root="/var/www/html/docroot" -l $URL "$@"
