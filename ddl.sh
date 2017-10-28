#!/bin/bash

FILEPATH=$(readlink $0 || echo $0)
BASEPATH=${FILEPATH%/*}/scripts

COMMAND=$1

if [[ ! "$COMMAND" || $COMMAND = "help" ]]; then
  echo "Commands available (omit NAME to use the local instance):"
  echo " inspect [NAME]           List all containers for a given instance."
  echo " drupal [NAME] [COMMAND]  Run Drupal Console for a given instance."
  echo " drush [NAME] [COMMAND]   Run Drush for a given instance."
  echo " list                     List all running drupal-docker-lite instances."
  echo " logs [NAME] [OPTIONS]    Print logs for a given instance. Run \"docker help logs\" for options."
  echo " mail [NAME]              Open the mailhog interface for a given container."
  echo " proxy                    Restarts the reverse proxy."
  echo " prune                    Remove unused Docker volumes and images."
  echo " rebuild [NAME]           Rebuilds a given instance."
  echo " remove [NAME]            Stop and remove a given instance, permanently. NAME is required for safety."
  echo " start [NAME]             Start a given instance."
  echo " stop [NAME]              Stop a given instance."
  echo " update                   Makes sure that drupal-docker-lite is up to date for all instances."
  echo " url [NAME]               Print the URL for a given instance."
  exit 1
fi

shift

if [ -f "$BASEPATH/$COMMAND.sh" ]; then
  "$BASEPATH/$COMMAND.sh" "$@"
else
  echo "Command not recognized"
fi
