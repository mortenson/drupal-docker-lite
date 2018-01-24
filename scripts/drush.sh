#!/bin/bash

URL=$($DDL url)

$DDL exec drush --root="/var/www/html/docroot" -l $URL "$@"
