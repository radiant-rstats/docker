#!/bin/bash

## set ARG_HOME to directory of your choosing if you do NOT
## want to to map the docker home directory to your local
## home directory
## Use something like the command below on macOS or Linux to setup a 'launch'
## command. You can then use that command, e.g., launch ., to launch the
## container from a specific directory
## ln -s ~/git/docker/launch-rsm-msba.sh /usr/local/bin/launchm
if [ "$1" != "" ]; then
  ARG_HOME="$(cd $1; pwd)"
else
  ARG_HOME=""
  ## change to some other path to use as default
  # ARG_HOME="~/rady"
fi
ID="vnijs"
LABEL="rsm-jupyterhub"
if [ "$2" != "" ]; then
  IMAGE_VERSION="$2"
else
  IMAGE_VERSION="latest"
fi
IMAGE=${ID}/${LABEL}
NB_USER="jovyan"

## what os is being used
ostype=`uname`

## script to start Radiant, Rstudio, and JupyterLab
clear
has_docker=$(which docker)
if [ "${has_docker}" == "" ]; then
  echo "-----------------------------------------------------------------------"
  echo "Docker is not installed. Download and install Docker from"
  if [[ "$ostype" == "Linux" ]]; then
    echo "https://www.digitalocean.com/community/tutorials/how-to-install-and-use-docker-on-ubuntu-18-04"
  elif [[ "$ostype" == "Darwin" ]]; then
    echo "https://download.docker.com/mac/stable/Docker.dmg"
  else
    echo "https://store.docker.com/editions/community/docker-ce-desktop-windows"
  fi
  echo "-----------------------------------------------------------------------"
  read
else

  ## check docker is running at all
  ## based on https://stackoverflow.com/questions/22009364/is-there-a-try-catch-command-in-bash
  {
    docker ps -q
  } || {
    echo "-----------------------------------------------------------------------"
    echo "Docker is not running. Please start docker on your computer"
    echo "When docker has finished starting up press [ENTER] to continue"
    echo "-----------------------------------------------------------------------"
    read
  }

  ## kill running containers
  running=$(docker ps -q)
  if [ "${running}" != "" ]; then
    echo "-----------------------------------------------------------------------"
    echo "Stopping running containers"
    echo "-----------------------------------------------------------------------"
    docker stop ${running}
  fi

  available=$(docker images -q ${IMAGE}:${IMAGE_VERSION})
  if [ "${available}" == "" ]; then
    echo "-----------------------------------------------------------------------"
    echo "Downloading the ${LABEL} computing container"
    echo "-----------------------------------------------------------------------"
    docker logout
    docker pull ${IMAGE}:${IMAGE_VERSION}
  fi

  ## function is not efficient by alias has scopping issues
  if [[ "$ostype" == "Linux" ]]; then
    HOMEDIR=~
    open_browser () {
      xdg-open $1
    }

  elif [[ "$ostype" == "Darwin" ]]; then
    ostype="macOS"
    HOMEDIR=~
    open_browser () {
      open $1
    }
  else
    ostype="Windows"
    HOMEDIR="C:/Users/$USERNAME"
    open_browser () {
      start $1
    }
  fi

  ## change mapping of docker home directory to local directory if specified
  if [ "${ARG_HOME}" != "" ]; then
    if [ -d "${ARG_HOME}" ]; then
      HOMEDIR=${ARG_HOME}
    else
      echo "The directory ${ARG_HOME} does not yet exist."
      echo "Please create the directory and start the launch script again"
      sleep 5s
      exit 1
    fi
  fi

  ## legacy - moving R/ directory with local installed packages
  if [ -d "${HOMEDIR}/R" ] && [ ! -d "${HOMEDIR}/.rsm-msba/R" ]; then
    echo "-----------------------------------------------------------------------"
    if [ "$ostype" != "Linux" ]; then
      echo "Moving user installed libraries to .rsm-msba/R"
      echo "To install additional libraries use:"
      echo "install.packages('a-package', lib = Sys.getenv('R_LIBS_USER'))"

      cp -r ${HOMEDIR}/R ${HOMEDIR}/.rsm-msba
      rm -rf ${HOMEDIR}/R
    else
      echo "User installed libraries should be added to .rsm-msba/R"
      echo "To install additional libraries use:"
      echo "install.packages('a-package', lib = Sys.getenv('R_LIBS_USER'))"
    fi
    echo "-----------------------------------------------------------------------"
  fi

  BUILD_DATE=$(docker inspect -f '{{.Created}}' ${IMAGE}:${IMAGE_VERSION})

  echo "-----------------------------------------------------------------------"
  echo "Starting the ${LABEL} computing container on ${ostype}"
  echo "Build date: ${BUILD_DATE//T*/}"
  echo "-----------------------------------------------------------------------"

  docker run --rm -p 8888:8888 -v ${HOMEDIR}:/home/${NB_USER} ${IMAGE}:${IMAGE_VERSION}

  ## make sure abend is set correctly
  ## https://community.rstudio.com/t/restarting-rstudio-server-in-docker-avoid-error-message/10349/2
  rstudio_abend () {
    if [ -d ${HOMEDIR}/.rstudio/sessions/active ]; then
      if [[ "$ostype" == "macOS" ]]; then
        find ${HOMEDIR}/.rstudio/sessions/active/*/session-persistent-state -type f -exec sed -i '' -e 's/abend="1"/abend="0"/' {} \; 2>/dev/null
      else
        find ${HOMEDIR}/.rstudio/sessions/active/*/session-persistent-state -type f -exec sed -i 's/abend="1"/abend="0"/' {} \; 2>/dev/null
      fi
    fi
  }
  rstudio_abend
fi


