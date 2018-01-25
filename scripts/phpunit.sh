#!/bin/bash

# We don't use "$DDL exec" because we need to run in detached mode.
$DDL exec pkill phantomjs
docker exec -d -i $(docker-compose ps -q php) phantomjs --ssl-protocol=any --ignore-ssl-errors=true ./docroot/vendor/jcalderonzumba/gastonjs/src/Client/main.js 8510 1024 768

# Auto-magically convert test paths relative to the current directory on the
# host to relative paths in the container.
TEST_PATH="${!#}"
TEST_DIR=$(cd $ORIGINAL_PWD && cd `dirname $TEST_PATH` && pwd)
TEST=${TEST_DIR/$PWD\/code/.}/$(basename $TEST_PATH)

$DDL exec ./docroot/vendor/bin/phpunit -c ./docroot/core "${@:0:$#}" $TEST

$DDL exec pkill phantomjs
