#!/bin/bash

## script to start Radiant and Rstudio
## script requires correct permissions to execute
## if you put the script on your Desktop, running the
## command below from a terminal should work
## then double-click to start the container

## chmod 755 ~/Desktop/launch-mac.command

clear
has_docker=$(which docker)
if [ "${has_docker}" == "" ]; then
  echo "--------------------------------------------------------------------"
  echo "Docker is not installed. Download and install Docker from"
  echo "https://download.docker.com/mac/stable/Docker.dmg"
  echo "--------------------------------------------------------------------"
  read
else

  ## check docker is running at all
  ## based on https://stackoverflow.com/questions/22009364/is-there-a-try-catch-command-in-bash
  {
    docker ps -q
  } || {
    open /Applications/Docker.app
    echo "--------------------------------------------------------------------"
    echo "Waiting for docker to start ..."
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

  available=$(docker images -q vnijs/radiant)
  if [ "${available}" == "" ]; then
    echo "--------------------------------------------------------------------"
    echo "Downloading the radiant computing container"
    echo "--------------------------------------------------------------------"
    docker pull vnijs/r-bionic
    docker pull vnijs/radiant
  fi

  echo "--------------------------------------------------------------------"
  echo "Starting radiant computing container"
  echo "--------------------------------------------------------------------"

  docker run -d -p 80:80 -p 8787:8787 -v ~:/home/rstudio vnijs/radiant

  ## make sure abend is set correctly
  ## https://community.rstudio.com/t/restarting-rstudio-server-in-docker-avoid-error-message/10349/2
  if [ -d ~/.rstudio ]; then
    find ~/.rstudio/sessions/active/*/session-persistent-state -type f | xargs sed -i '' -e 's/abend="1"/abend="0"/'
  fi

  show_service () {
    echo "--------------------------------------------------------------------"
    echo "Press (1) to show Radiant, followed by [ENTER]:"
    echo "Press (2) to show Rstudio, followed by [ENTER]:"
    echo "Press (3) to update the radiant container, followed by [ENTER]:"
    echo "Press (q) to stop the docker process, followed by [ENTER]:"
    echo "--------------------------------------------------------------------"
    read startup

    if [ ${startup} == 3 ]; then
      running=$(docker ps -q)
      echo "--------------------------------------------------------------------"
      echo "Updating the radiant computing container"
      docker kill ${running}
      docker pull vnijs/radiant
      echo "--------------------------------------------------------------------"
      docker run -d -p 80:80 -p 8787:8787 -v ~:/home/rstudio vnijs/radiant
      echo "--------------------------------------------------------------------"
    elif [ ${startup} == 1 ]; then

      touch ~/.Rprofile
      if ! grep -q 'radiant.report = TRUE' ~/.Rprofile; then
        echo "Your setup does not allow report generation in Report > Rmd"
        echo "or Report > R. Would you like to add relevant code to .Rprofile?"
        echo "Press y or n, followed by [ENTER]:"
        echo
        read allow_report

        if [ "${allow_report}" == "y" ]; then
          printf '\noptions(radiant.maxRequestSize = -1)\noptions(radiant.report = TRUE)' >> ~/.Rprofile
        fi
      fi
      if ! grep -qF 'options(radiant.sf_volumes' ~/.Rprofile; then
        echo 'home <- radiant.data::find_home()' >> ~/.Rprofile
        echo 'options(radiant.sf_volumes = c(Desktop = file.path(home, "Desktop"), Home = home,  Dropbox = file.path(home, "Dropbox")))' >> ~/.Rprofile
        echo 'rm(home)' >> ~/.Rprofile
      fi
      echo "Starting Radiant in the default browser"
      open http://localhost
    elif [ ${startup} == 2 ]; then
      echo "Starting Rstudio in the default browser"
      open http://localhost:8787
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
