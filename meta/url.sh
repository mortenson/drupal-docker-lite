#!/bin/bash
cd "${0%/*}"

NAME=$1

if [[ ! "$NAME" ]]; then
  echo "An instance name is required"
  exit 1
fi

CONTAINER=$(docker ps -q -a --filter name="$NAME"_php --filter "label=drupaldockerlite")

if [[ ! "$CONTAINER" ]]; then
  echo "No container found for $NAME"
  exit 0
fi

DOMAIN=$(docker container exec "$CONTAINER" printenv VIRTUAL_HOST | tr -d '\r')

if [ "$(docker ps -q --filter name=ddl_proxy)" ]; then
  echo http://$DOMAIN
else
  echo http://$(docker container port "$CONTAINER" 80 | sed "s/0.0.0.0/$DOMAIN/")
fi
