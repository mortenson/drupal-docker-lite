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
    echo "Please stop/remove the containers above then run this command again"
    exit 1
  fi
  printf "VIRTUAL_HOST=$DOMAIN\nCOMPOSE_PROJECT_NAME=$DOMAIN" > .env
fi

if [ ! -d "code" ]; then
  echo "Please enter the name of a Composer project, a Git URL of an existing repository, or \"contrib\" if you're working on a Drupal project."
  read -p "Project: " PROJECT
  if [[ "$PROJECT" =~ "git" ]]; then
    if ! type "git" &> /dev/null; then
      echo "Please install Git and try running the update script again"
      exit 1
    fi
    git clone "$PROJECT" code
    message_on_error "Failed to clone git repository $PROJECT"
    if [ -f code/composer.json ] && [ ! -d code/vendor ]; then
      composer install --working-dir=code
      message_on_error "Failed to install Composer dependencies for your Git project"
    fi
  elif [ "$PROJECT" == "contrib" ]; then
    mkdir code
    git clone "https://git.drupal.org/project/drupal.git" code/docroot
    message_on_error "Failed to clone Drupal core"
    composer install --working-dir=code/docroot
    message_on_error "Failed to install Composer dependencies for Drupal core"
    # @todo This is silly, we should fallback to a global Drush 9.
    composer require drush/drush --working-dir=code/docroot
    message_on_error "Failed to install Drush locally for Drupal core"
    echo "Drupal core has been checked out in code/docroot."
  else
    composer create-project $PROJECT code -s dev --no-interaction
    message_on_error "Creation of Composer project $INPUT project failed. Please consult the log and file an issue if appropriate"
  fi
fi

if [ ! -d "code/docroot" ] && [ -d "code/web" ]; then
  ln -s web code/docroot
fi

if [ ! -d "code/docroot" ] || [ ! -f "code/docroot/index.php" ]; then
  echo "The codebase in code/docroot does not appear to be valid. Please check the directory and re-run this command"
  exit 1
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
  sed -i '' -e "s/settings\['hash_salt'\] = '';/settings\['hash_salt'\] = 'CHANGE_ME';/g" code/docroot/sites/default/settings.php
fi

docker network create ddl_proxy &> /dev/null
docker-compose up -d

docker-compose exec php pwd &> /dev/null
message_on_error "The codebase volume appears to be broken. Please run the rebuild command and try starting again."

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

message_on_error "Startup failed. Please consult the log and file an issue if appropriate"

docker ps -a -q --filter name=ddl_proxy --filter status=exited | xargs docker start &>/dev/null
if [ ! $(docker ps -q --filter name=ddl_proxy) ]; then
  $DDL proxy &>/dev/null
fi

if [[ ! "$NO_PROFILE" && ! $($DDL drush st --fields=install-profile | tr -d '\r') ]]; then
  echo "Drupal does not appear to be installed yet"
  if [[ "$PROJECT" =~ "git" ]]; then
    read -p "Do you have an existing database dump to import? [y/n] "
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
      exit 0
    fi
    read -e -p "Dump file: " DUMP
    eval "$DDL import $DUMP"
    message_on_error "Failed to import your database dump. To retry this process, run the \"import\" command"
  else
    read -p "Do you want to install a site profile? [y/n] "
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
      exit 0
    fi
    echo "Please enter a profile name to install."
    read -p "Profile: " PROFILE
    $DDL drush --sites-subdir=default site-install --site-name="$PROFILE" $PROFILE -y
    message_on_error "Installation failed. Please consult the log and file an issue if appropriate"
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
