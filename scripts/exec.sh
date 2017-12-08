#!/bin/bash

docker exec -i $(docker-compose ps -q php) "$@"
