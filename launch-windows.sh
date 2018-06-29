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
    echo "--------------------------------------------------------------------"
    echo "Stopping running containers"
    echo "--------------------------------------------------------------------"
    docker kill ${running}
  fi

  available=$(docker images -q vnijs/rsm-msba)
  if [ "${available}" == "" ]; then
    echo "--------------------------------------------------------------------"
    echo "Downloading the rsm-msba computing container"
    echo "--------------------------------------------------------------------"
    docker pull vnijs/rsm-msba
  fi

  echo "--------------------------------------------------------------------"
  echo "Starting rsm-msba computing container"
  echo "--------------------------------------------------------------------"

  docker run -d -p 80:80 -p 8787:8787 -p 8888:8888 -v c:/Users/$USERNAME:/home/rstudio vnijs/rsm-msba

  echo "--------------------------------------------------------------------"
  echo "Press (1) to show radiant, followed by [ENTER]:"
  echo "Press (2) to show Rstudio, followed by [ENTER]:"
  echo "Press (3) to show Jupyter Lab, followed by [ENTER]:"
  echo "--------------------------------------------------------------------"
  read startup

  echo "--------------------------------------------------------------------"
  if [ "${startup}" == "1" ]; then
    echo "Starting Radiant in the default browser"
    start http://localhost
  elif [ "${startup}" == "2" ]; then
    echo "Starting Rstudio in the default browser"
    start http://localhost:8787
  elif [ "${startup}" == "3" ]; then
    echo "Starting Jupyter Lab in the default browser"
    start http://localhost:8888/lab
  fi
  echo "--------------------------------------------------------------------"

  echo "--------------------------------------------------------------------"
  echo "Press q to stop the docker process, followed by [ENTER]:"
  echo "--------------------------------------------------------------------"
  read quit

  if [ "${quit}" == "q" ]; then
    running=$(docker ps -q)
    docker kill ${running}
  else
    echo "--------------------------------------------------------------------"
    echo "The rsm-msba computing container is still running"
    echo "Use the command below to stop the service"
    echo "docker kill $(docker ps -q)"
    echo "--------------------------------------------------------------------"
    read
  fi
fi
