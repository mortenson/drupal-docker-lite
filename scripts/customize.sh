#!/bin/bash

if ! type "git" &> /dev/null; then
  echo "Please install Git and try running the script again"
  exit 1
fi

if [[ ! -f docker-compose.yml || ! -f ddl.sh ]]; then
  echo "Please run this command from the root of a drupal-docker-lite instance"
  exit 1
fi

if [[ -d db || -d web ]]; then
  echo "This instance already appears to be customized"
  exit 1
fi

read -p "Are you sure you want to customize this instance and use locally built images? [y/n] "
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
  exit 1
fi

BRANCH=$(git name-rev --name-only HEAD)
REMOTE=$(git config "branch.$BRANCH.remote")
if [[ "$REMOTE" ]]; then
  URL=$(git remote get-url "$REMOTE")
  if [[ "$URL" == "git@github.com:mortenson/drupal-docker-lite.git" || "$URL" == "https://github.com/mortenson/drupal-docker-lite.git" ]]; then
    echo "Removing mortenson/drupal-docker-lite as a remote"
    git remote remove $REMOTE
  fi
fi

echo "Downloading images locally..."
git clone https://github.com/mortenson/ddl-db.git db &> /dev/null
git clone https://github.com/mortenson/ddl-web.git web &> /dev/null

if [[ ! -d db || ! -d web ]]; then
  echo "Failed to download images"
  exit 1
fi

rm -rf db/.git web/.git

sed -e 's|image: mortenson/ddl-web|build: ./web|' -e 's|image: mortenson/ddl-db|build: ./db|' docker-compose.yml > tmp
mv tmp docker-compose.yml

echo "Rebuilding containers..."

NO_OPEN=true ./ddl.sh rebuild &> /dev/null

if [[ $? -ne 0 ]]; then
  echo "Failed to rebuild containers"
  exit 1
fi

echo "Local instance has been customized! You can now add custom configuration to ./db or ./web"
