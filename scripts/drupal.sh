#!/bin/bash

URL=$($DDL url)

docker-compose exec php drupal --root="/var/www/html/docroot" --uri="$URL" "$@"
