#!/bin/bash
cd "${0%/*}"

DOMAIN=$(docker-compose exec php printenv VIRTUAL_HOST | tr -d '\r')

if [ "$(docker ps -q --filter name=ddl_proxy)" ]; then
  echo http://$DOMAIN
else
  echo http://$(docker-compose port php 80 | sed "s/0.0.0.0/$DOMAIN/")
fi
