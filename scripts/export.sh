#!/bin/bash

DESTINATION=$1

if [ ! "$DESTINATION" ]; then
  echo "Export destination missing"
  exit 1
fi

if [ -e "$DESTINATION" ]; then
  echo "$DESTINATION already exists"
  exit 1
fi

docker exec -i $(docker-compose ps -q php) mysqldump --databases drupal --user=drupal --password=password --host=mysql --port=3306 > $DESTINATION

message_on_error "Exporting database dump failed"

echo "A database dump has been exported"
