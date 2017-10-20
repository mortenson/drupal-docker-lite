#!/bin/bash

NAME=$1

if [[ ! "$NAME" ]]; then
  echo "An instances name is required"
  exit 1
fi

CONTAINERS=$(docker ps -q -a --filter name="$NAME"_ --filter "label=drupaldockerlite")

if [[ ! "$CONTAINERS" ]]; then
  echo "No containers found named $NAME"
  exit 0
fi

for CONTAINER in $CONTAINERS; do
  docker stop $CONTAINER &> /dev/null
  if [ $? -eq 0 ]; then
    echo "Stopped $CONTAINER"
  else
    echo "Error when stopping $CONTAINER"
  fi
done
