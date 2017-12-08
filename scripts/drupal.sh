#!/bin/bash

URL=$($DDL url)

$DDL exec drupal --root="/var/www/html/docroot" --uri="$URL" "$@"
