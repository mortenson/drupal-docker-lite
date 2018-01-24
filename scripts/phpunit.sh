#!/bin/bash

# We don't use ""$DDL exec" because we need to run in detached mode.
docker exec -d -i $(docker-compose ps -q php) phantomjs --ssl-protocol=any --ignore-ssl-errors=true ./docroot/vendor/jcalderonzumba/gastonjs/src/Client/main.js 8510 1024 768

sleep 3

TEST_DIR=$(cd $ORIGINAL_PWD && cd `dirname $1` && pwd)
TEST=${TEST_DIR/$PWD\/code/.}/$(basename $1)

$DDL exec ./docroot/vendor/bin/phpunit -c ./docroot/core $TEST

$DDL exec pkill phantomjs
