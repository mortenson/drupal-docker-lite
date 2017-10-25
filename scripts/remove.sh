#!/bin/bash

cd "${0%/*}"

NAME=$1

if [[ ! "$NAME" ]]; then
  echo "An instance name is required"
  exit 1
fi

CONTAINERS=$(docker ps -q -a --filter "label=com.docker.compose.project=$NAME" --filter "label=drupaldockerlite")

if [[ ! "$CONTAINERS" ]]; then
  echo "No containers found named $NAME"
  exit 0
fi

read -p "This will permanently remove $NAME containers and volumes, which could have negative consequences. Are you sure? [y/n] "
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
  exit 1
fi

for CONTAINER in $CONTAINERS; do
  docker stop $CONTAINER &> /dev/null
  docker rm $CONTAINER &> /dev/null
  if [ $? -eq 0 ]; then
    echo "Removed $CONTAINER"
  else
    echo "Error when removing $CONTAINER"
  fi
done

docker volume prune --force
