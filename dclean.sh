#!/bin/bash

## from https://stackoverflow.com/a/32723285/1974918

## kill all running containers
running=$(docker ps -q)
if [ "${running}" != "" ]; then
  echo "Stop running containers"
  docker kill ${running}
else
  echo "No running containers"
fi

imgs=$(docker images | awk '/<none>/ { print $3 }')
if [ "${imgs}" != "" ]; then
  echo "Remove unused containers"
  docker rmi ${imgs}
else
  echo "No images to remove"
fi

procs=$(docker ps -a -q --no-trunc)
if [ "${procs}" != "" ]; then
  echo "Nuke errand docker processes"
  docker rm ${procs}
else
  echo "No processes to purge"
fi

