#!/bin/bash

HAS_ARGS=true
. "${0%/*}/util/init.sh"

URL=$(${0%/*}/url.sh)

docker-compose exec php drush --root="/var/www/html/docroot" -l $URL "$@"
