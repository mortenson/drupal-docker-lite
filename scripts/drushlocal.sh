#!/bin/bash

ADDRESS=$(docker-compose port mysql 3306)
HOST=$(echo $ADDRESS | sed "s/:.*//")
PORT=$(echo $ADDRESS | sed "s/.*://")
URL=$($DDL url)

message_on_error "Cannot determine MySQL container port."

DRUSH=$(find code -name drush -type f -perm +111 | head -n 1)

if [[ ! "$DRUSH" ]]; then
  echo "Unable to find Drush executable in code/."
  exit 0
fi

unset message_on_error

DRUPAL_DOCKER_LITE=1 DDL_MYSQL_PORT=$PORT DDL_MYSQL_HOST=$HOST $DRUSH --root="$PWD/code/docroot" --db-url=mysql://drupal:password@$ADDRESS/drupal -l $URL "$@"
