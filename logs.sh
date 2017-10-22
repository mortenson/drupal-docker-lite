#!/bin/bash
cd "${0%/*}"

if ! type "docker-compose" &> /dev/null; then
  echo "Please install Docker and try running the script again"
  exit 1
fi

docker-compose logs $@ php
