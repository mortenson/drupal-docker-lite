#!/bin/bash

INSTANCES=$(docker ps -a --filter "label=drupaldockerlite" -q | xargs docker inspect -f '{{index .Config.Labels "com.docker.compose.project"}}'| uniq)

if [[ ! "$INSTANCES" ]]; then
  echo "No drupal-docker-lite instances are running"
  exit 0
fi

OUTPUT="NAME RUNNING URL PROFILE"

for INSTANCE in $INSTANCES; do
  NAME=$INSTANCE
  CONTAINER=$(docker ps -q -a --filter name="$NAME"_php)
  RUNNING=$(docker inspect -f {{.State.Running}} $CONTAINER)
  if [[ $RUNNING = "true" ]]; then
    URL=$(docker container exec $CONTAINER printenv VIRTUAL_HOST | tr -d '\r')
    PROFILE=$(docker container exec $CONTAINER drush --root="/var/www/html/docroot" ev 'echo drupal_get_profile()')
    if [ $? -ne 0 ]; then
      PROFILE="n/a";
    fi
  else
    URL="n/a"
    PROFILE="n/a"
  fi
  OUTPUT="${OUTPUT}"$'\n'"$NAME $RUNNING $URL $WORKING $PROFILE"
done

echo "$OUTPUT" | column -t -s ' '
