#!/bin/bash

INSTANCES=$(docker ps -a -q --filter "label=drupaldockerlite" | xargs docker inspect -f '{{index .Config.Labels "com.docker.compose.project"}}'| uniq)

if [[ ! "$INSTANCES" ]]; then
  echo "No drupal-docker-lite instances are running"
  exit 0
fi

OUTPUT="NAME RUNNING URL CODEBASE"

for INSTANCE in $INSTANCES; do
  NAME=$INSTANCE
  CONTAINER=$(docker ps -a -q --filter "label=drupaldockerlite" --filter "label=com.docker.compose.project=$NAME" --filter "name=php")
  if [[ "$CONTAINER" ]]; then
    RUNNING=$(docker inspect -f {{.State.Running}} $CONTAINER)
    if [[ $RUNNING = "true" ]]; then
      URL=$($DDL url "$NAME")
      if [ $? -ne 0 ]; then
        URL="n/a"
      fi
    else
      URL="n/a"
    fi
    CODEBASE=$(docker container inspect --format '{{ range .Mounts }}{{ if eq .Destination "/var/www/html" }}{{ .Source }}{{ end }}{{ end }}' "$CONTAINER")
    if [[ ! -d "$CODEBASE" ]]; then
      CODEBASE="removed"
    fi
  else
    URL="n/a"
    RUNNING="n/a"
    CODEBASE="n/a"
  fi
  OUTPUT="${OUTPUT}"$'\n'"$NAME $RUNNING $URL $CODEBASE"
done

echo "$OUTPUT" | column -t -s ' '
