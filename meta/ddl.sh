#!/bin/bash

FILEPATH=$(readlink $0 || echo $0)
cd "${FILEPATH%/*}"

COMMAND=$1

if [[ ! "$COMMAND" || $COMMAND = "help" ]]; then
  echo "Commands available:"
  echo " list                     List all running drupal-docker-lite instances."
  echo " inspect [NAME]           List all containers for a given instance."
  echo " drush [NAME] [COMMAND]   Run drush for a given instance."
  echo " stop [NAME]              Stop a given instance's containers."
  echo " start [NAME]             Start a given instance's containers."
  echo " remove [NAME]            Stop and remove a given instance's containers."
  echo " prune                    Remove unused Docker volumes and images."
  echo " url [NAME]               Print the URL for a given instance."
  echo " logs [NAME] [OPTIONS]    Print logs for a given instance. Run \"docker help logs\" for options."
  exit 1
fi

shift

if [ -f "$COMMAND.sh" ]; then
  ./"$COMMAND.sh" "$@"
fi
