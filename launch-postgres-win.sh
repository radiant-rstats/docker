#!/bin/bash

## to map the directory where the launch script is located to
## the docker home directory call the script_home function
script_home () {
  echo "$(echo "$( cd "$(dirname "$0")" ; pwd -P )" | sed -E "s|^/([A-z]{1})/|\1:/|")"
}

## change to some other path to use as default
SCRIPT_HOME="$(script_home)"

docker-compose -f ${SCRIPT_HOME}/postgres/docker-postgres-win.yml up -d
