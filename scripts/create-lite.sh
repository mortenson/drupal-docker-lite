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

mkdir $DIR
cd $DIR

wget https://raw.githubusercontent.com/mortenson/drupal-docker-lite/master/docker-compose.yml
wget https://raw.githubusercontent.com/mortenson/drupal-docker-lite/master/php.ini

message_on_error "Errors encountered when copying drupal-docker-lite files"

$DDL start

message_on_error "Errors encountered when starting drupal-docker-lite"

echo "New drupal-docker-lite created in \"$DIR\""
