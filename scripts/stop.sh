#!/bin/bash

. "${0%/*}/util/init.sh"

docker-compose stop

if [ $? -ne 0 ]; then
  echo "There was an error stopping Docker. Please consult the log and file an issue if appropriate"
  exit 1
fi

echo "Docker has been stopped, sweet dreams..."
