#!/bin/bash

DOCKER_VERSION=$(docker -v | sed 's/Docker version //')
DOCKER_VERSION=(${DOCKER_VERSION//./ })

if [ ${DOCKER_VERSION[0]} -lt 17 ] || ( [ ${DOCKER_VERSION[0]} -eq 17 ] && [ ${DOCKER_VERSION[1]} -lt 5 ] ); then
  echo "Please upgrade Docker to version 17.05 or later and try running the script again"
  exit 1
fi

if [ ! -f ".env" ]; then
  echo "Please enter the domain name you would like to use for this container, i.e. drupal.ddl"
  read -p "Domain name: " DOMAIN
  PREFIX=$(echo $DOMAIN | sed 's/[^a-zA-Z0-9]//g')
  if [[ $(docker ps -q -a --filter name="$PREFIX"_) ]]; then
    echo "A Docker instance using this domain already exists:"
    docker ps -a --filter name="$PREFIX"_
    echo "Please stop/remove the containers above then run ./ddl.sh start again"
    exit 1
  fi
  printf "VIRTUAL_HOST=$DOMAIN\nCOMPOSE_PROJECT_NAME=$DOMAIN" > .env
fi

if [ ! -d "code" ]; then
  echo "Please enter the name of your Composer project. i.e. drupal-composer/drupal-project or acquia/lightning-project"
  read -p "Project: " PROJECT
  composer create-project $PROJECT code -s dev --no-interaction
  if [ $? -ne 0 ]; then
    echo "Creation of $PROJECT project failed. Please consult the log and file an issue if appropriate"
    exit 1
  fi
fi

if [ ! -d "code/docroot" ] && [ -d "code/web" ]; then
  ln -s web code/docroot
fi

if [[ ! -f code/docroot/sites/default/settings.php && -f code/docroot/sites/default/default.settings.php ]]; then
  if [[ ! -w code/docroot/sites/default ]]; then
    echo "Adding settings.php file, I'll need sudo for this"
    sudo chmod u+w code/docroot/sites/default/* code/docroot/sites/default
  fi
  cp code/docroot/sites/default/default.settings.php code/docroot/sites/default/settings.php
fi

if [[ -f code/docroot/sites/default/settings.php ]] && ! grep -q "DRUPAL_DOCKER_LITE" code/docroot/sites/default/settings.php; then
  if [[ ! -w code/docroot/sites/default || ! -w code/docroot/sites/default/settings.php  ]]; then
    echo "Modifying settings.php file, I'll need sudo for this"
    sudo chmod u+w code/docroot/sites/default/* code/docroot/sites/default
  fi
  cat settings.php.txt >> code/docroot/sites/default/settings.php
fi

docker network create ddl_proxy &> /dev/null
docker-compose up -d

docker-compose exec php pwd &> /dev/null
if [ $? -ne 0 ]; then
  echo "The codebase volume appears to be broken. Please run ./ddl.sh rebuild to rebuild your containers."
  exit 1
fi

DOMAIN=$(docker-compose exec php printenv VIRTUAL_HOST | tr -d '\r')

HOSTS_ENTRY="127.0.0.1 $DOMAIN"

if ! grep -q "^$HOSTS_ENTRY$" /etc/hosts; then
  if [ -w /etc/hosts ]; then
    echo "$HOSTS_ENTRY" >> /etc/hosts
  else
    echo "Adding entry to hosts file, I'll need sudo for this"
    echo "$HOSTS_ENTRY" | sudo tee -a /etc/hosts > /dev/null
  fi
fi

if [ $? -ne 0 ]; then
  echo "Startup failed. Please consult the log and file an issue if appropriate"
  exit 1
fi

docker ps -a -q --filter name=ddl_proxy --filter status=exited | xargs docker start &>/dev/null
if [ ! $(docker ps -q --filter name=ddl_proxy) ]; then
  $DDL proxy &>/dev/null
fi

if [[ ! $($DDL drush st --fields=install-profile | tr -d '\r') ]]; then
  echo "Please enter a profile name to install. i.e. standard or lightning"
  read -p "Profile: " PROFILE
  $DDL drush --sites-subdir=default site-install --site-name="$PROFILE" $PROFILE -y
  if [ $? -ne 0 ]; then
    echo "Installation failed. Please consult the log and file an issue if appropriate"
    exit 1
  fi
  URL=$($DDL drush uli | tr -d '\r')
else
  URL=$($DDL url)
fi

if [[ ! "$NO_OPEN" ]]; then
  if type "open" &> /dev/null; then
    open $URL
  elif type "xdg-open" &> /dev/null; then
    xdg-open $URL
  else
    echo "Startup finished. Visit site at $URL"
  fi
else
  echo "Startup finished. Visit site at $URL"
fi
