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

docker-compose up -d

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
  URL=http://$(docker-compose port php 80 | sed 's/0.0.0.0/localhost/')
fi

if type "open" &> /dev/null; then
  open $URL
elif type "xdg-open" &> /dev/null; then
  xdg-open $URL
else
  echo "Docker has been started"
fi
