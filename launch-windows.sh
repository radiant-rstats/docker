#!/bin/bash

## script to start Radiant, Rstudio, and JupyterLab
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

  ## make sure abend is set correctly
  ## https://community.rstudio.com/t/restarting-rstudio-server-in-docker-avoid-error-message/10349/2
  find c:/Users/$USERNAME/.rstudio/sessions/active/*/session-persistent-state -type f | xargs sed -i 's/abend="1"/abend="0"/'

  echo "--------------------------------------------------------------------"
  echo "Press (1) to show Radiant, followed by [ENTER]:"
  echo "Press (2) to show Rstudio, followed by [ENTER]:"
  echo "Press (3) to show Jupyter Lab, followed by [ENTER]:"
  echo "Press (4) to update the rsm-msba container, followed by [ENTER]:"
  echo "--------------------------------------------------------------------"
  read startup

  if [ "${startup}" == "4" ]; then
    running=$(docker ps -q)
    echo "--------------------------------------------------------------------"
    echo "Updating the rsm-msba computing container"
    docker kill ${running}
    docker pull vnijs/rsm-msba
    echo "--------------------------------------------------------------------"
    docker run -d -p 80:80 -p 8787:8787 -p 8888:8888 -v c:/Users/$USERNAME:/home/rstudio vnijs/rsm-msba
    echo "--------------------------------------------------------------------"
    echo "Press (1) to show Radiant, followed by [ENTER]:"
    echo "Press (2) to show Rstudio, followed by [ENTER]:"
    echo "Press (3) to show Jupyter Lab, followed by [ENTER]:"
    echo "--------------------------------------------------------------------"
    read startup
  fi

  echo "--------------------------------------------------------------------"
  if [ "${startup}" == "1" ]; then
    RPROF=c:/Users/$USERNAME/.Rprofile
    touch ${RPROF}
    if ! grep -q 'radiant.report = TRUE' ${RPROF}; then
      echo "Your setup does not allow report generation in Report > Rmd"
      echo "or Report > R. Would you like to add relevant code to .Rprofile?"
      echo "Press y or n, followed by [ENTER]:"
      echo
      read allow_report

      if [ "${allow_report}" == "y" ]; then
        ## Windows does not repliably profile newlines with printf
        echo 'options(radiant.maxRequestSize = -1)' >> ${RPROF}
        echo 'options(radiant.report = TRUE)' >> ${RPROF}
      fi
    fi
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

  running=$(docker ps -q)
  if [ "${quit}" == "q" ]; then
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
