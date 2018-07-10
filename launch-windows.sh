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

  ## check docker is running at all
  ## based on https://stackoverflow.com/questions/22009364/is-there-a-try-catch-command-in-bash
  {
    docker ps -q
  } || {
    echo "--------------------------------------------------------------------"
    echo "Docker is not running. Please start docker on your computer"
    echo "When docker has finished starting up press [ENTER} to continue"
    echo "--------------------------------------------------------------------"
    read
  }

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
  if [ -d c:/Users/$USERNAME/.rstudio ]; then
    find c:/Users/$USERNAME/.rstudio/sessions/active/*/session-persistent-state -type f | xargs sed -i 's/abend="1"/abend="0"/'
  fi

   show_service () {
    echo "--------------------------------------------------------------------"
    echo "Press (1) to show Radiant, followed by [ENTER]:"
    echo "Press (2) to show Rstudio, followed by [ENTER]:"
    echo "Press (3) to show Jupyter Lab, followed by [ENTER]:"
    echo "Press (4) to update the rsm-msba container, followed by [ENTER]:"
    echo "Press (q) to stop the docker process, followed by [ENTER]:"
    echo "--------------------------------------------------------------------"
    read startup
  
    if [ ${startup} == 4 ]; then
      running=$(docker ps -q)
      echo "--------------------------------------------------------------------"
      echo "Updating the rsm-msba computing container"
      docker kill ${running}
      docker pull vnijs/rsm-msba
      echo "--------------------------------------------------------------------"
      docker run -d -p 80:80 -p 8787:8787 -p 8888:8888 -v c:/Users/$USERNAME:/home/rstudio vnijs/rsm-msba
      echo "--------------------------------------------------------------------"
    elif [ ${startup} == 1 ]; then

      RPROF=c:/Users/$USERNAME/.Rprofile
      touch ${RPROF}
      if ! grep -q 'radiant.report = TRUE' ${RPROF}; then
        echo "Your setup does not allow report generation in Report > Rmd"
        echo "or Report > R. Would you like to add relevant code to .Rprofile?"
        echo "Press y or n, followed by [ENTER]:"
        echo
        read allow_report

        if [ "${allow_report}" == "y" ]; then
          ## Windows does not reliably use newlines with printf
          echo 'options(radiant.maxRequestSize = -1)' >> ${RPROF}
          echo 'options(radiant.report = TRUE)' >> ${RPROF}
        fi
      fi
      if ! grep -qF 'options(radiant.sf_volumes' ${RPROF}; then
        echo 'home <- radiant.data::find_home()' >> ${RPROF}
        echo 'options(radiant.sf_volumes = c(Desktop = file.path(home, "Desktop"), Home = home,  Dropbox = file.path(home, "Dropbox")))' >> ${RPROF}
        echo 'rm(home)' >> ${RPROF}
      fi
      echo "Starting Radiant in the default browser"
      start http://localhost
    elif [ ${startup} == 2 ]; then
      echo "Starting Rstudio in the default browser"
      start http://localhost:8787
    elif [ ${startup} == 3 ]; then
      echo "Starting Jupyter Lab in the default browser"
      start http://localhost:8888/lab
    elif [ "${startup}" == "q" ]; then
      running=$(docker ps -q)
      docker kill ${running}
    fi

    if [ "${startup}" == "q" ]; then
      return 2
    else
      return 1
    fi
  }

  ## keep asking until quit
  show_service
  ret=$?
  while [ $ret -ne 2 ]; do
    sleep 2s
    clear
    show_service
    ret=$?
  done
fi 
