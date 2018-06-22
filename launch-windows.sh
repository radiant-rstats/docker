#!/bin/bash

## start Radiant, Rstudio, and JupyterLab
## use CTRL + C to stop the container
clear
has_docker=$(which docker)
if [ "${has_docker}" == "" ]; then
  echo "--------------------------------------------------------------------"
  echo "Docker is not installed. Download and install Docker from"
  echo "https://store.docker.com/editions/community/docker-ce-desktop-windows"
  echo "--------------------------------------------------------------------"
  read
else

  ## kill running containers
  running=$(docker ps -q)
  if [ "${running}" != "" ]; then
    docker kill ${running}
  fi

  echo "--------------------------------------------------------------------"
  echo "Starting rsm-msba computing container"
  echo "--------------------------------------------------------------------"

  ## (un)comment lines below to open services in a browser
  # start http://localhost
  # start http://localhost:8787
  start http://localhost:8888/lab

  ## open only rsm-msba
  docker run --rm -p 80:80 -p 8787:8787 -p 8888:8888 -v //~:/home/rstudio vnijs/rsm-msba

  ## open rsm-msba and postgres
  # docker-compose -f ~/Desktop/GitLab/docker/rsm-msba/docker-rsm-msba-pg.yml up
fi
