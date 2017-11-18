#!/bin/bash

docker-compose pull
docker-compose build --pull

message_on_error "There was an error re-building. Please consult the log and file an issue if appropriate"

docker-compose down
$DDL start

message_on_error "Failed to start project after rebuilding"

echo "Better, stronger, faster, I have been rebuilt"
