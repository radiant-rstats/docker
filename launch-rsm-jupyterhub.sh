#!/bin/bash

## set ARG_HOME to a directory of your choosing if you do NOT
## want to to map the docker home directory to your local
## home directory

## use the command below on macOS or Linux to setup a 'launch'
## command. You can then use that command, e.g., launch ., to
## launch the container from any directory
## ln -s ~/git/docker/launch-rsm-jupyterhub.sh /usr/local/bin/launch

## to map the directory where the launch script is located to
## the docker home directory call the script_home function
script_home () {
  echo "$(echo "$( cd "$(dirname "$0")" ; pwd -P )" | sed -E "s|^/([A-z]{1})/|\1:/|")"
}

function launch_usage() {
  echo "Usage: $0 [-t tag (version)] [-d directory]"
  echo "  -t, --tag         Docker image tag (version) to use"
  echo "  -d, --directory   Base directory to use"
  echo "  -h, --help        Print help and exit"
  echo ""
  echo "Example: $0 --tag 1.4.3 --directory ~/project_1"
  echo ""
  exit 1
}

## parse command-line arguments
while [[ "$#" > 0 ]]; do case $1 in
  -t|--tag) ARG_TAG="$2"; shift;shift;;
  -d|--directory) ARG_DIR="$2";shift;shift;;
  -h|--help) launch_usage;shift; shift;;
  *) echo "Unknown parameter passed: $1"; echo ""; launch_usage; shift; shift;;
esac; done

## some cleanup on exit
function finish {
  if [ "$ARG_HOME" != "" ]; then
    echo "Removing empty files and directories ..."
    find "$ARG_HOME" -empty -type d -delete
    find "$ARG_HOME" -empty -type f -delete
  fi
}
trap finish EXIT

## change to some other path to use as default
# ARG_HOME="~/rady"
# ARG_HOME="$(script_home)"
ARG_HOME=""
IMAGE_VERSION="latest"
NB_USER="jovyan"
CODE_WORKINGDIR="/home/${NB_USER}/git"
ID="vnijs"
LABEL="rsm-jupyterhub"
IMAGE=${ID}/${LABEL}
if [ "$ARG_TAG" != "" ]; then
  IMAGE_VERSION="$ARG_TAG"
  DOCKERHUB_VERSION=${IMAGE_VERSION}
else
  ## see https://stackoverflow.com/questions/34051747/get-environment-variable-from-docker-container
  DOCKERHUB_VERSION=$(docker inspect -f '{{range $index, $value := .Config.Env}}{{println $value}} {{end}}' ${IMAGE}:${IMAGE_VERSION} | grep DOCKERHUB_VERSION)
  DOCKERHUB_VERSION="${DOCKERHUB_VERSION#*=}"
fi
POSTGRES_VERSION=10

## what os is being used
ostype=`uname`
if [ "$ostype" == "Darwin" ]; then
  EXT="command"
else
  EXT="sh"
fi

## check if script is already running and using port 8787
CPORT=$(curl -s localhost:8787 2>/dev/null)
if [ "$CPORT" != "" ]; then
  echo "-----------------------------------------------------------------------"
  echo "A launch script may already be running. To close the new session and"
  echo "continue with the previous session press q + enter. To continue with"
  echo "the new session and stop the previous session, press enter"
  echo "-----------------------------------------------------------------------"
  read contd
  if [ "${contd}" == "q" ]; then
    exit 1
  fi
fi

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
    echo "Downloading the ${LABEL}:${IMAGE_VERSION} computing environment"
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
    sed_fun () {
      sed -i $1 "$2"
    }
    MNT="-v /media:/media"
  elif [[ "$ostype" == "Darwin" ]]; then
    ostype="macOS"
    HOMEDIR=~
    open_browser () {
      open $1
    }
    sed_fun () {
      sed -i '' -e $1 "$2"
    }
    MNT="-v /Volumes:/media/Volumes"
  else
    ostype="Windows"
    HOMEDIR="C:/Users/$USERNAME"
    open_browser () {
      start $1
    }
    sed_fun () {
      sed -i $1 "$2"
    }
    MNT=""
  fi

  if [ "$ARG_DIR" != "" ] || [ "$ARG_HOME" != "" ]; then
    ## change mapping of docker home directory to local directory if specified
    if [ "${ARG_HOME}" != "" ] && [ ! -d "${ARG_HOME}" ]; then
      echo "The directory ${ARG_HOME} does not yet exist."
      echo "Please create the directory and restart the launch script"
      sleep 5s
      exit 1
    fi
    if [ "$ARG_DIR" != "" ]; then
      if [ ! -d "${ARG_DIR}" ]; then
        echo "The directory ${ARG_DIR} does not yet exist."
        echo "Please create the directory and restart the launch script"
        sleep 5s
        exit 1
      fi
      ARG_HOME="$(cd "$ARG_DIR"; pwd)"
      ## https://unix.stackexchange.com/questions/295991/sed-error-1-not-defined-in-the-re-under-os-x
      ARG_HOME="$(echo "$ARG_HOME" | sed -E "s|^/([A-z]{1})/|\1:/|")"

      echo "---------------------------------------------------------------------------"
      echo "Do you want to access git, ssh, and R configuration in this directory (y/n)"
      echo "${ARG_HOME}"
      echo "---------------------------------------------------------------------------"
      read copy_config
    else
      copy_config="y"
    fi

    # setup working directory for vscode
    if [ "${HOMEDIR}" != "${ARG_HOME}" ]; then
      CODE_WORKINGDIR="/home/${NB_USER}"
    fi

    if [ "${copy_config}" == "y" ]; then
      if [ -f "${HOMEDIR}/.inputrc" ] && [ ! -s "${ARG_HOME}/.inputrc" ]; then
        MNT="$MNT -v ${HOMEDIR}/.inputrc:/home/$NB_USER/.inputrc"
      fi
      if [ -f "${HOMEDIR}/.Rprofile" ] && [ ! -s "${ARG_HOME}/.Rprofile" ]; then
        MNT="$MNT -v ${HOMEDIR}/.Rprofile:/home/$NB_USER/.Rprofile"
      fi
      if [ -f "${HOMEDIR}/.Renviron" ] && [ ! -s "${ARG_HOME}/.Renviron" ]; then
        MNT="$MNT -v ${HOMEDIR}/.Renviron:/home/$NB_USER/.Renviron"
      fi
      if [ -f "${HOMEDIR}/.gitconfig" ] && [ ! -s "${ARG_HOME}/.gitconfig" ]; then
        MNT="$MNT -v ${HOMEDIR}/.gitconfig:/home/$NB_USER/.gitconfig"
      fi
      if [ -d "${HOMEDIR}/.ssh" ]; then
        if [ ! -d "${ARG_HOME}/.ssh" ] || [ ! "$(ls -A $ARG_HOME/.ssh)" ]; then
          MNT="$MNT -v ${HOMEDIR}/.ssh:/home/$NB_USER/.ssh"
        fi
      fi
    fi

    if [ ! -f "${ARG_HOME}/.gitignore" ]; then
      ## make sure no hidden files go into a git repo
      touch "${ARG_HOME}/.gitignore"
      echo ".*" >> "${ARG_HOME}/.gitignore"
    fi

    if [ -d "${HOMEDIR}/.R" ]; then
      if [ ! -d "${ARG_HOME}/.R" ] || [ ! "$(ls -A $ARG_HOME/.R)" ]; then
        MNT="$MNT -v ${HOMEDIR}/.R:/home/$NB_USER/.R"
      fi
    fi

    if [ -d "${HOMEDIR}/Dropbox" ]; then
      if [ ! -d "${ARG_HOME}/Dropbox" ] || [ ! "$(ls -A $ARG_HOME/Dropbox)" ]; then
        MNT="$MNT -v ${HOMEDIR}/Dropbox:/home/$NB_USER/Dropbox"
        sed_fun '/^Dropbox$/d' "${ARG_HOME}/.gitignore"
        echo "Dropbox" >> "${ARG_HOME}/.gitignore"
      fi
    fi

    if [ -d "${HOMEDIR}/.rstudio" ] && [ ! -d "${ARG_HOME}/.rstudio" ]; then
      echo "-----------------------------------------------------------------------"
      echo "Copying Rstudio and JupyterLab settings to:"
      echo "${ARG_HOME}"
      echo "-----------------------------------------------------------------------"

      {
        which rsync 2>/dev/null
        HD="$(echo "$HOMEDIR" | sed -E "s|^([A-z]):|/\1|")"
        AH="$(echo "$ARG_HOME" | sed -E "s|^([A-z]):|/\1|")"
        rsync -a "${HD}/.rstudio" "${AH}/" --exclude sessions --exclude projects --exclude projects_settings
      } ||
      {
        cp -r "${HOMEDIR}/.rstudio" "${ARG_HOME}/.rstudio"
        rm -rf "${ARG_HOME}/.rstudio/sessions"
        rm -rf "${ARG_HOME}/.rstudio/projects"
        rm -rf "${ARG_HOME}/.rstudio/projects_settings"
      }

    fi
    if [ -d "${HOMEDIR}/.rsm-msba" ] && [ ! -d "${ARG_HOME}/.rsm-msba" ]; then

      {
        which rsync 2>/dev/null
        HD="$(echo "$HOMEDIR" | sed -E "s|^([A-z]):|/\1|")"
        AH="$(echo "$ARG_HOME" | sed -E "s|^([A-z]):|/\1|")"
        rsync -a "${HD}/.rsm-msba" "${AH}/" --exclude R --exclude bin --exclude lib --exclude share
      } ||
      {
        cp -r "${HOMEDIR}/.rsm-msba" "${ARG_HOME}/.rsm-msba"
        rm -rf "${ARG_HOME}/.rsm-msba/R"
        rm -rf "${ARG_HOME}/.rsm-msba/bin"
        rm -rf "${ARG_HOME}/.rsm-msba/lib"
        rm_list=$(ls "${ARG_HOME}/.rsm-msba/share" | grep -v jupyter)
        for i in ${rm_list}; do
           rm -rf "${ARG_HOME}/.rsm-msba/share/${i}"
        done
      }
    fi
    SCRIPT_HOME="$(script_home)"
    if [ "${SCRIPT_HOME}" != "${ARG_HOME}" ]; then
      cp -p "$0" "${ARG_HOME}/launch-${LABEL}.${EXT}"
      sed_fun "s+^ARG_HOME\=\".*\"+ARG_HOME\=\"\$\(script_home\)\"+" "${ARG_HOME}/launch-${LABEL}.${EXT}"
      if [ "$ARG_TAG" != "" ]; then
        sed_fun "s/^IMAGE_VERSION=\".*\"/IMAGE_VERSION=\"${IMAGE_VERSION}\"/" "${ARG_HOME}/launch-${LABEL}.${EXT}"
      fi
    fi
    HOMEDIR="${ARG_HOME}"
  fi

  BUILD_DATE=$(docker inspect -f '{{.Created}}' ${IMAGE}:${IMAGE_VERSION})

  echo "-----------------------------------------------------------------------"
  echo "Starting the ${LABEL} computing environment on ${ostype}"
  echo "Version   : ${DOCKERHUB_VERSION}"
  echo "Build date: ${BUILD_DATE//T*/}"
  echo "Base dir. : ${HOMEDIR}"
  echo "-----------------------------------------------------------------------"

  has_volume=$(docker volume ls | awk "/pg_data/" | awk '{print $2}')
  if [ "${has_volume}" == "" ]; then
    docker volume create --name=pg_data
  fi
  {
    docker run --rm -p 127.0.0.1:8888:8888 -p 127.0.0.1:8765:8765 \
      -e NB_USER=0 -e NB_UID=1002 -e NB_GID=1002 -e CODE_WORKINGDIR=" ${CODE_WORKINGDIR}" \
      -v "${HOMEDIR}":/home/${NB_USER} $MNT \
      -v pg_data:/var/lib/postgresql/${POSTGRES_VERSION}/main \
      ${IMAGE}:${IMAGE_VERSION}
  } || {
    echo "-----------------------------------------------------------------------"
    echo "It seems there was a problem starting the docker container. Please"
    echo "report the issue and add a screenshot of any messages shown on screen."
    echo "Press [ENTER] to continue"
    echo "-----------------------------------------------------------------------"
    read
  }

  ## make sure abend is set correctly
  ## https://community.rstudio.com/t/restarting-rstudio-server-in-docker-avoid-error-message/10349/2
  rstudio_abend () {
    if [ -d "${HOMEDIR}/.rstudio/sessions/active" ]; then
      RSTUDIO_STATE_FILES=$(find "${HOMEDIR}/.rstudio/sessions/active/*/session-persistent-state" -type f 2>/dev/null)
      if [ "${RSTUDIO_STATE_FILES}" != "" ]; then
        sed_fun 's/abend="1"/abend="0"/' ${RSTUDIO_STATE_FILES}
      fi
    fi
    if [ -d "${HOMEDIR}/.rstudio/monitored/user-settings" ]; then
      touch "${HOMEDIR}/.rstudio/monitored/user-settings/user-settings"
      sed_fun '/^alwaysSaveHistory="[0-1]"/d' "${HOMEDIR}/.rstudio/monitored/user-settings/user-settings"
      sed_fun '/^loadRData="[0-1]"/d' "${HOMEDIR}/.rstudio/monitored/user-settings/user-settings"
      sed_fun '/^saveAction=/d' "${HOMEDIR}/.rstudio/monitored/user-settings/user-settings"
      echo 'alwaysSaveHistory="1"' >> "${HOMEDIR}/.rstudio/monitored/user-settings/user-settings"
      echo 'loadRData="0"' >> "${HOMEDIR}/.rstudio/monitored/user-settings/user-settings"
      echo 'saveAction="0"' >> "${HOMEDIR}/.rstudio/monitored/user-settings/user-settings"
      sed_fun '/^$/d' "${HOMEDIR}/.rstudio/monitored/user-settings/user-settings"
    fi
  }
  rstudio_abend
fi
