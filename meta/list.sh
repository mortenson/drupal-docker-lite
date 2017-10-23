#!/bin/bash
cd "${0%/*}"

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
    URL=$(./url.sh "$NAME")
    PROFILE=$(./drush.sh "$NAME" ev 'echo drupal_get_profile()')
    if [ $? -ne 0 ]; then
      PROFILE="n/a";
    fi
  else
    URL="n/a"
    PROFILE="n/a"
  fi
  STATS=$(docker ps -q -a --filter name="$NAME"_php --filter "label=drupaldockerlite" | xargs docker stats -a --no-stream --format '{{.CPUPerc}} {{.MemPerc}}')
  OUTPUT="${OUTPUT}"$'\n'"$NAME $RUNNING $URL $PROFILE $STATS"
done

echo "$OUTPUT" | column -t -s ' '
