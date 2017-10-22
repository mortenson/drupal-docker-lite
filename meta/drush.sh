#!/bin/bash
cd "${0%/*}"

NAME=$1

if [[ ! "$NAME" ]]; then
  echo "An instance name is required"
  exit 1
fi

shift

CONTAINER=$(docker ps -q -a --filter name="$NAME"_php --filter "label=drupaldockerlite")

if [[ ! "$CONTAINER" ]]; then
  echo "No container found for $NAME"
  exit 0
fi

URL=$(./url.sh "$NAME")

docker container exec "$CONTAINER" drush --root="/var/www/html/docroot" -l $URL "$@"
