#!/bin/bash

INSTANCES=$(docker ps -a --filter "label=drupaldockerlite" -q | xargs docker inspect -f '{{index .Config.Labels "com.docker.compose.project"}}'| uniq)

if [[ ! "$INSTANCES" ]]; then
  echo "No drupal-docker-lite instances are running"
  exit 0
fi

OUTPUT="NAME RUNNING URL PROFILE CPU MEMORY"

for INSTANCE in $INSTANCES; do
  NAME=$INSTANCE
  CONTAINER=$(docker ps -q -a --filter name="$NAME"_php --filter "label=drupaldockerlite")
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
  STATS=$(docker ps -q -a --filter name="$NAME"_ --filter "label=drupaldockerlite" | xargs docker stats -a --no-stream --format '{{.CPUPerc}}\t{{.MemPerc}}')
  CPU=$(echo "$STATS" | awk '{print $1}' | tr -d '%' | awk '{s+=$1} END {print s}')
  MEMORY=$(echo "$STATS" | awk '{print $2}' | tr -d '%' | awk '{s+=$1} END {print s}')
  OUTPUT="${OUTPUT}"$'\n'"$NAME $RUNNING $URL $PROFILE $CPU% $MEMORY%"
done

echo "$OUTPUT" | column -t -s ' '
