#!/bin/bash

## based on https://stackoverflow.com/a/32723285/1974918
running=$(docker ps -q)
if [ "${running}" != "" ]; then
  echo "Stopping running containers ..."
  docker stop ${running}
else
  echo "No running containers"
fi

imgs=$(docker images | awk '/<none>/ { print $3 }')
if [ "${imgs}" != "" ]; then
  echo "Removing unused containers ..."
  docker rmi ${imgs}
else
  echo "No images to remove"
fi

procs=$(docker ps -a -q --no-trunc)
if [ "${procs}" != "" ]; then
  echo "Removing errand docker processes ..."
  docker rm ${procs}
else
  echo "No processes to purge"
fi

