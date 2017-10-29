#!/bin/bash

URL=http://$(docker-compose port mailhog 8025 | sed 's/0.0.0.0/localhost/')

if [[ ! "$NO_OPEN" ]]; then
  if type "open" &> /dev/null; then
    open $URL
  elif type "xdg-open" &> /dev/null; then
    xdg-open $URL
  else
    echo "Mail visible at $URL"
  fi
else
  echo "Mail visible at $URL"
fi
