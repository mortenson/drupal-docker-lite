#!/bin/bash

if ! type "composer" &> /dev/null; then
  echo "Please install composer and try running the script again"
  echo "Installation instructions can be found at https://getcomposer.org/download"
  exit 1
fi

if ! type "docker-compose" &> /dev/null; then
  echo "Please install Docker and try running the script again"
  echo "Installation instructions can be found at https://www.docker.com/community-edition"
  exit 1
fi

NAME=$1

if [[ "$PWD" =~ "/code" || -f "docker-compose.yml" ]]; then
  COMPOSE_PATH=${PWD%%/code*}
fi

cd "${0%/*}"

CONTAINER=$(docker ps -a -q --filter "label=drupaldockerlite" --filter "label=com.docker.compose.project=$NAME" --filter "name=php")

if [[ "$CONTAINER" ]]; then
  shift

  MOUNT=$(docker container inspect --format '{{ range .Mounts }}{{ if eq .Destination "/var/www/html" }}{{ .Source }}{{ end }}{{ end }}' "$CONTAINER")

  if [[ -f "${MOUNT%/*}/docker-compose.yml" ]]; then
    COMPOSE_PATH="${MOUNT%/*}"
  fi
fi

if [[ ! "$COMPOSE_PATH" ]] || [[ ! "$HAS_ARGS" && $# -gt 0 ]]; then
  if [[ "$NAME" ]]; then
    echo "Cannot find docker-compose.yml path for $NAME."
  else
    echo "Cannot find nearest docker-compose.yml path."
  fi
  exit 1
fi

cd $COMPOSE_PATH
