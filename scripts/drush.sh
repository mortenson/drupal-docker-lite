#!/bin/bash

URL=$($DDL url)

docker-compose exec php drush --root="/var/www/html/docroot" -l $URL "$@"
