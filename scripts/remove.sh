#!/bin/bash

. "${0%/*}/util/init.sh"

read -p "This will permanently remove $NAME containers and volumes, which could have negative consequences. Are you sure? [y/n] "
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
  exit 1
fi

docker-compose rm -s -f

docker volume prune --force
