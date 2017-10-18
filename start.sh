#!/bin/bash

if ! type "composer" &> /dev/null; then
  echo "Please install composer and try running the script again"
  echo "Installation instructions can be found at https://getcomposer.org/download"
  exit 1
fi

if ! type "docker-compose" &> /dev/null; then
  echo "Please install Docker and try running the script again"
  echo "Installation instructions can be found at https://www.docker.com/community-edition"
  exit 1
fi

if ! type "drush" &> /dev/null; then
  echo "Please install Drush and try running the script again"
  echo "Installation instructions can be found at http://docs.drush.org/en/8.x/install"
  exit 1
fi

DOCKER_VERSION=$(docker -v | sed 's/Docker version //')
DOCKER_VERSION=(${DOCKER_VERSION//./ })

if [ ${DOCKER_VERSION[0]} -lt 17 ] || ( [ ${DOCKER_VERSION[0]} -eq 17 ] && [ ${DOCKER_VERSION[1]} -lt 6 ] ); then
  echo "Please upgrade Docker to version 17.05 or later and try running the script again"
  exit 1
fi

if [ ! -d "code" ]; then
  echo "Please enter the name of your Composer project. i.e. drupal-composer/drupal-project or acquia/lightning-project"
  read -p "Project: " PROJECT
  composer create-project $PROJECT code -s dev --no-interaction
  if [ $? -ne 0 ]; then
    echo "Creation of $PROJECT project failed. Please consult the log and file an issue if appropriate"
    exit 1
  fi
  find code -name default.settings.php -not -path "*vendor*" -execdir cp {} settings.php \;
  cat settings.php.txt >> $(find code -name settings.php -not -path "*vendor*")
  NEW_INSTALL=1
fi

if [ ! -d "code/docroot" ] && [ -d "code/web" ]; then
  ln -s web code/docroot
fi

if [ ! -f ".env" ]; then
  echo "Please enter the domain name you would like to use for this container, i.e. drupal.ddl"
  read -p "Domain name: " DOMAIN
  echo "VIRTUAL_HOST=$DOMAIN" > .env
fi

docker network create ddl_proxy &> /dev/null
docker-compose up -d

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

if [[ $NEW_INSTALL ]]; then
  echo "Please enter a profile name to install. i.e. standard or lightning"
  read -p "Profile: " PROFILE
  ./drush --sites-subdir=default site-install --site-name="$PROFILE" $PROFILE -y
  if [ $? -ne 0 ]; then
    echo "Installation failed. Please consult the log and file an issue if appropriate"
    exit 1
  fi
fi

if [[ $NEW_INSTALL ]]; then
  URL=$(./drush uli | tr -d '\r')
else
  URL=$(./url.sh)
fi

if type "open" &> /dev/null; then
  open $URL
elif type "xdg-open" &> /dev/null; then
  xdg-open $URL
else
  echo "Docker has been started"
fi
