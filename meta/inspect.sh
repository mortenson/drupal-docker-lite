#!/bin/bash
cd "${0%/*}"

NAME=$1

if [[ ! "$NAME" ]]; then
  echo "An instance name is required"
  exit 1
fi

docker ps -a --filter name="$NAME"_ --filter "label=drupaldockerlite"
