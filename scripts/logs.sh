#!/bin/bash

HAS_ARGS=true
. "${0%/*}/util/init.sh"

docker-compose logs $@ php
