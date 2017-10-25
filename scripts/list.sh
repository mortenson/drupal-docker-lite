#!/bin/bash
cd "${0%/*}"

INSTANCES=$(docker ps -a -q --filter "label=drupaldockerlite" | xargs docker inspect -f '{{index .Config.Labels "com.docker.compose.project"}}'| uniq)

if [[ ! "$INSTANCES" ]]; then
  echo "No drupal-docker-lite instances are running"
  exit 0
fi

OUTPUT="NAME RUNNING URL PROFILE CPU MEMORY CODEBASE"

for INSTANCE in $INSTANCES; do
  NAME=$INSTANCE
  CONTAINER=$(./util/getcontainer.sh $NAME)
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
  CODEBASE=$(docker container inspect --format '{{ range .Mounts }}{{ if eq .Destination "/var/www/html" }}{{ .Source }}{{ end }}{{ end }}' "$CONTAINER")
  STATS=$(docker stats -a --no-stream --format '{{ .CPUPerc }} {{ .MemPerc }}' "$CONTAINER")
  OUTPUT="${OUTPUT}"$'\n'"$NAME $RUNNING $URL $PROFILE $STATS $CODEBASE"
done

echo "$OUTPUT" | column -t -s ' '
