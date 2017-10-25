#!/bin/bash
cd "${0%/*}"

NAME=$1

if [[ ! "$NAME" ]]; then
  echo "An instance name is required"
  exit 1
fi

docker ps -a --filter "label=drupaldockerlite" --filter "label=com.docker.compose.project=$NAME"
