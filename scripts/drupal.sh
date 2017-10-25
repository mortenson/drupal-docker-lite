#!/bin/bash

HAS_ARGS=true
. "${0%/*}/util/init.sh"

URL=$(${0%/*}/url.sh)

docker-compose exec php drupal --root="/var/www/html/docroot" --uri="$URL" "$@"
