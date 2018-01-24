#!/bin/bash

URL=$($DDL url)

# Check if a site local Drush exists, and is executable.
DRUSH=$(find code -name drush -type f -perm +111 | head -n 1)
if [[ "$DRUSH" ]]; then
  $DDL exec drush --root="/var/www/html/docroot" -l $URL "$@"
# Otherwise, use Drush 8.1.15 as a fallback.
else
  $DDL exec drush8 --root="/var/www/html/docroot" -l $URL "$@"
fi
