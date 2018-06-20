#!/bin/bash

## script requires correct permissions to execute
## if you put the script on your Desktop, running the 
## command below from a terminal should work
## then double-click to start the container

## chmod 755 ~/Desktop/launch-rsm-msba-mac.command

## start Radiant, Rstudio, and JupyterLab
## use CTRL + C to stop the container
clear
has_docker=$(which docker)
if ["${has_docker}" == ""]; then
  echo "--------------------------------------------------------------------"
  echo "Docker is not installed. Download and install Docker from"
  echo "https://download.docker.com/mac/stable/Docker.dmg"
  echo "--------------------------------------------------------------------"
  read
else

  ## kill running containers
  running=$(docker ps -q)
  if ["${running}" != ""]; then
    docker kill ${running}
  fi

  echo "--------------------------------------------------------------------"
  echo "Starting rsm-msba computing container"
  echo "--------------------------------------------------------------------"

  open http://localhost 
  open http://localhost:8787
  open http://localhost:8888/lab 

  ## open only rsm-msba
  docker run --rm -p 80:80 -p 8787:8787 -p 8888:8888 -v ~:/home/rstudio vnijs/rsm-msba

  ## open rsm-msba and postgres
  # docker-compose -f ~/Desktop/GitLab/docker/rsm-msba/docker-rsm-msba-pg.yml up
fi
