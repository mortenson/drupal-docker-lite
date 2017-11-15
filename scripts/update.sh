#!/bin/bash

if ! type "git" &> /dev/null; then
  echo "Please install Git and try running the update script again"
  exit 1
fi

update_git() {
  BRANCH=$(git name-rev --name-only HEAD)
  REMOTE=$(git config "branch.$BRANCH.remote")
  URL=$(git remote get-url "$REMOTE")
  if [[ "$URL" != "git@github.com:mortenson/drupal-docker-lite.git" && "$URL" != "https://github.com/mortenson/drupal-docker-lite.git" ]]; then
    echo "Project does not use mortenson/drupal-docker-lite as a remote"
    return
  fi
  git fetch --all &> /dev/null
  DIFF=$(git diff HEAD && git log HEAD --not --remotes)
  if [[ "$DIFF" ]]; then
    echo "There are un-committed or un-pushed changes locally, check $PWD"
    return
  fi
  git pull &> /dev/null
  return
}

echo "Updating the codebase ddl.sh was ran from..."

update_git

echo

INSTANCES=$(docker ps -a -q --filter "label=drupaldockerlite" | xargs docker inspect -f '{{index .Config.Labels "com.docker.compose.project"}}' | sort | uniq)

if [[ ! "$INSTANCES" ]]; then
  echo "No drupal-docker-lite instances are running"
  exit 0
fi

for INSTANCE in $INSTANCES; do
  NAME=$INSTANCE
  CONTAINER=$(docker ps -a -q --filter "label=drupaldockerlite" --filter "label=com.docker.compose.project=$NAME" --filter "name=php")
  if [[ "$CONTAINER" ]]; then
    MOUNT=$(docker container inspect --format '{{ range .Mounts }}{{ if eq .Destination "/var/www/html" }}{{ .Source }}{{ end }}{{ end }}' "$CONTAINER")

    if [[ -f "${MOUNT%/*}/docker-compose.yml" ]]; then
      cd "${MOUNT%/*}"
      echo "Updating $NAME codebase..."
      update_git
      echo "Rebuilding $NAME..."
      NO_OPEN=true $DDL rebuild $NAME &> /dev/null
      echo "Done"
    else
      echo "$NAME is running, but the root directory cannot be determined"
    fi
  else
    echo "$NAME is not running, cannot determine root directory"
  fi
  echo
done

echo "Finished updating local drupal-docker-lite instances"
