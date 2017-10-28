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

if [[ $? -ne 0 || ! -d $DIR ]]; then
  echo "Errors encountered when cloning drupal-docker-lite"
  exit 1
fi

cd $DIR

./ddl.sh start
