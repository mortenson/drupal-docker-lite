#!/bin/bash

docker-compose stop

message_on_error "Error encountered when stopping containers"

echo "Docker has been stopped, sweet dreams..."
