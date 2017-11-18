#!/bin/bash

FILE=$1

if [ ! -f "$FILE" ]; then
  echo "Database dump file $FILE not found"
  exit 1
fi

docker exec -i $(docker-compose ps -q php) mysql --user=drupal --password=password --database=drupal --host=mysql --port=3306 < $FILE

message_on_error "Importing database dump $FILE failed"

$DDL rebuild

echo "Your database dump has been imported"
