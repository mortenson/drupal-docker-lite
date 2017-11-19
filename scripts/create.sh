#!/bin/bash

DIR=$1

if [[ ! "$DIR" ]]; then
  echo "A directory name is required"
  exit 1
fi

if [[ -d "$DIR" ]]; then
  echo "The $DIR directory already exists"
  exit 1
fi

git clone https://github.com/mortenson/drupal-docker-lite.git "$DIR"

message_on_error "Errors encountered when cloning drupal-docker-lite"

cd $DIR

$DDL start

message_on_error "Errors encountered when starting drupal-docker-lite"

echo "New drupal-docker-lite created in \"$DIR\""
