#!/bin/bash

if [[ ! "$ORIGINAL_PWD" ]]; then
  ORIGINAL_PWD=$PWD
fi

FILEPATH=$(readlink $0 || echo $0)
BASEPATH=$(cd $(dirname $FILEPATH) && pwd)

COMMAND=$1

if [[ ! "$COMMAND" || $COMMAND = "help" ]]; then
  echo "Commands available (omit NAME to use the local instance):"
  echo " create [DIR]                   Creates a new instance in a given directory."
  echo " create-lite [DIR]              Creates a new minimal instance in a given directory."
  echo " customize                      Customizes instance to use local images for PHP and MySQL."
  echo " drupal [NAME] [COMMAND]        Run Drupal Console for a given instance."
  echo " drush [NAME] [COMMAND]         Run Drush for a given instance."
  echo " drushlocal [NAME] [COMMAND]    Run Drush locally for a given instance."
  echo " exec [NAME] [COMMAND]          Executes a single command for a given instance."
  echo " export [NAME] [DESTINATION]    Exports a database dump to a given directory."
  echo " import [NAME] [SOURCE]         Imports a given database dump."
  echo " inspect [NAME]                 List all containers for a given instance."
  echo " list                           List all running drupal-docker-lite instances."
  echo " logs [NAME] [OPTIONS]          Print logs for a given instance. Run \"docker help logs\" for options."
  echo " mail [NAME]                    Open the Mailhog interface for a given instance."
  echo " phpunit [NAME] [FILENAME]      Runs PHPUnit tests contained in the given file."
  echo " proxy                          Restarts the reverse proxy."
  echo " prune                          Remove unused Docker volumes and images."
  echo " rebuild [NAME]                 Rebuilds a given instance."
  echo " remove [NAME]                  Stop and remove a given instance, permanently. NAME is required for safety."
  echo " start [NAME]                   Start a given instance."
  echo " stop [NAME]                    Stop a given instance."
  echo " update                         Makes sure that drupal-docker-lite is up to date for all instances."
  echo " url [NAME]                     Print the URL for a given instance."
  exit 1
fi

shift

message_on_error() {
  if [ $? -ne 0 ]; then
    echo "$1"
    exit 1
  fi
}

export -f message_on_error

if [ -f "$BASEPATH/scripts/$COMMAND.sh" ]; then
  if [[ ! $COMMAND =~ ^list|proxy|prune|update|create|create-lite$ ]]; then
    . "$BASEPATH/scripts/util/init.sh";
  fi
  ORIGINAL_PWD=$ORIGINAL_PWD DDL_PATH=$BASEPATH DDL=$BASEPATH/ddl.sh "$BASEPATH/scripts/$COMMAND.sh" "$@"
else
  echo "Command not recognized"
fi
