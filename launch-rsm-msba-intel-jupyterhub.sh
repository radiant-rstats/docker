#!/bin/bash

## set ARG_HOME to a directory of your choosing if you do NOT
## want to to map the docker home directory to your local
## home directory

## use the command below on to launch the container:
## ~/git/docker/launch-rsm-msba-intel.sh -v ~

## to map the directory where the launch script is located to
## the docker home directory call the script_home function
script_home () {
  echo "$(echo "$( cd "$(dirname "$0")" ; pwd -P )" | sed -E "s|^/([A-z]{1})/|\1:/|")"
}

function launch_usage() {
  echo "Usage: $0 [-t tag (version)] [-d directory]"
  echo "  -t, --tag         Docker image tag (version) to use"
  echo "  -d, --directory   Project directory to use"
  echo "  -v, --volume      Volume to mount as home directory"
  echo "  -s, --show        Show all output generated on launch"
  echo "  -h, --help        Print help and exit"
  echo ""
  echo "Example: $0 --tag 2.8.0 --volume ~/project_1"
  echo ""
  exit 1
}

## parse command-line arguments
while [[ "$#" > 0 ]]; do case $1 in
  -t|--tag) ARG_TAG="$2"; shift;shift;;
  -d|--directory) ARG_DIR="$2";shift;shift;;
  -v|--volume) ARG_VOLUME="$2";shift;shift;;
  -s|--show) ARG_SHOW="show";shift;shift;;
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
ID="vnijs"
LABEL="rsm-msba-intel-jupyterhub"
NETWORK="rsm-docker"
IMAGE=${ID}/${LABEL}
# Choose your timezone https://en.wikipedia.org/wiki/List_of_tz_database_time_zones
TIMEZONE="America/Los_Angeles"
if [ "$ARG_TAG" != "" ]; then
  IMAGE_VERSION="$ARG_TAG"
  DOCKERHUB_VERSION=${IMAGE_VERSION}
else
  ## see https://stackoverflow.com/questions/34051747/get-environment-variable-from-docker-container
  DOCKERHUB_VERSION=$(docker inspect -f '{{range $index, $value := .Config.Env}}{{println $value}} {{end}}' ${IMAGE}:${IMAGE_VERSION} | grep DOCKERHUB_VERSION)
  DOCKERHUB_VERSION="${DOCKERHUB_VERSION#*=}"
fi
POSTGRES_VERSION=14

## what os is being used
ostype=`uname`
if [ "$ostype" == "Darwin" ]; then
  EXT="command"
else
  EXT="sh"
fi

BOUNDARY="---------------------------------------------------------------------------"

## check the return code - if curl can connect something is already running
curl -S localhost:8989 2>/dev/null
ret_code=$?
if [ "$ret_code" == 0 ]; then
  echo $BOUNDARY
  echo "A launch script may already be running. To close the new session and"
  echo "continue with the previous session press q + enter. To continue with"
  echo "the new session and stop the previous session, press enter"
  echo $BOUNDARY
  read contd
  if [ "${contd}" == "q" ]; then
    exit 1
  fi
fi

## script to start Radiant, Rstudio, and JupyterLab
if [ "$ARG_SHOW" != "show" ]; then
  clear
fi
has_docker=$(which docker)
if [ "${has_docker}" == "" ]; then
  echo $BOUNDARY
  echo "Docker is not installed. Download and install Docker from"
  if [[ "$ostype" == "Linux" ]]; then
    is_wsl=$(which explorer.exe)
    if [[ "$is_wsl" != "" ]]; then
      echo "https://hub.docker.com/editions/community/docker-ce-desktop-windows"
    else
      echo "https://www.digitalocean.com/community/tutorials/how-to-install-and-use-docker-on-ubuntu-20-04"
    fi
  elif [[ "$ostype" == "Darwin" ]]; then
    echo "https://hub.docker.com/editions/community/docker-ce-desktop-mac"
  else
    echo "https://hub.docker.com/editions/community/docker-ce-desktop-windows"
  fi
  echo $BOUNDARY
  read
else

  ## check docker is running at all
  ## based on https://stackoverflow.com/questions/22009364/is-there-a-try-catch-command-in-bash
  {
    docker ps -q 2>/dev/null
  } || {
    if [[ "$ostype" == "Darwin" ]]; then
      ## from https://stackoverflow.com/a/48843074/1974918
      # On Mac OS this would be the terminal command to launch Docker
      open /Applications/Docker.app
      #Wait until Docker daemon is running and has completed initialisation
      while (! docker stats --no-stream 2>/dev/null); do
        echo "Please wait while Docker starts up ..."
        sleep 2
      done
    else
      echo $BOUNDARY
      echo "Docker is not running. Please start docker on your computer"
      echo "When docker has finished starting up press [ENTER] to continue"
      echo $BOUNDARY
      read
    fi
  }

  ## kill running containers
  running=$(docker ps -a --format {{.Names}} | grep ${LABEL} -w)
  if [ "${running}" != "" ]; then
    echo $BOUNDARY
    echo "Stopping running containers"
    echo $BOUNDARY
    docker stop ${LABEL}
    docker container rm ${LABEL} 2>/dev/null
  fi

  ## download image if not available
  available=$(docker images -q ${IMAGE}:${IMAGE_VERSION})
  if [ "${available}" == "" ]; then
    echo $BOUNDARY
    echo "Downloading the ${LABEL}:${IMAGE_VERSION} computing environment"
    echo $BOUNDARY
    docker logout
    docker pull ${IMAGE}:${IMAGE_VERSION}
  fi

  chip=""
  if [[ "$ostype" == "Linux" ]]; then
    ostype="Linux"
    if [[ "$archtype" == "aarch64" ]]; then
      chip="(ARM64)"
    else
      chip="(Intel)"
    fi
    HOMEDIR=~
    ID=$USER
    open_browser () {
      xdg-open $1
    }
    sed_fun () {
      sed -i $1 "$2"
    }
    if [ -d "/media" ]; then
      MNT="-v /media:/media"
    else
      MNT=""
    fi

    is_wsl=$(which explorer.exe)
    if [[ "$is_wsl" != "" ]]; then
      ostype="WSL2"
      HOMEDIR="/mnt/c/Users/$USER"
      if [ -d "/mnt/c" ]; then
        MNT="$MNT -v /mnt/c:/mnt/c"
      fi
      if [ -d "/mnt/d" ]; then
        MNT="$MNT -v /mnt/d:/mnt/d"
      fi
    fi
  elif [[ "$ostype" == "Darwin" ]]; then
    archtype=`arch`
    ostype="macOS"
    if [[ "$archtype" == "arm64" ]]; then
      chip="(ARM64)"
    else
      chip="(Intel)"
    fi
    HOMEDIR=~
    ID=$USER
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
    ID=$USERNAME
    open_browser () {
      start $1
    }
    sed_fun () {
      sed -i $1 "$2"
    }
    MNT=""
  fi

  if [ "$ARG_VOLUME" != "" ]; then
    HOMEDIR="$ARG_VOLUME"
  fi

  if [ "$ARG_DIR" != "" ] || [ "$ARG_HOME" != "" ]; then
    ## change mapping of docker home directory to local directory if specified
    if [ "${ARG_HOME}" != "" ] && [ ! -d "${ARG_HOME}" ]; then
      echo "The directory ${ARG_HOME} does not yet exist."
      echo "Please create the directory and restart the launch script"
      sleep 5
      exit 1
    fi
    if [ "$ARG_DIR" != "" ]; then
      if [ ! -d "${ARG_DIR}" ]; then
        echo "The directory ${ARG_DIR} does not yet exist."
        echo "Please create the directory and restart the launch script"
        sleep 5
        exit 1
      fi
      ARG_HOME="$(cd "$ARG_DIR"; pwd)"
      ## https://unix.stackexchange.com/questions/295991/sed-error-1-not-defined-in-the-re-under-os-x
      ARG_HOME="$(echo "$ARG_HOME" | sed -E "s|^/([A-z]{1})/|\1:/|")"

      echo $BOUNDARY
      echo "Do you want to access git, ssh, and R configuration in this directory (y/n)"
      echo "${ARG_HOME}"
      echo $BOUNDARY
      read copy_config
    else
      copy_config="y"
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
      echo $BOUNDARY
      echo "Copying Rstudio and JupyterLab settings to:"
      echo "${ARG_HOME}"
      echo $BOUNDARY

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

  RPROF="${HOMEDIR}/.Rprofile"
  touch "${RPROF}"
  if ! grep -q 'radiant.report = TRUE' ${RPROF}; then
    echo "Your setup does not allow report generation in Radiant."
    echo "Would you like to add relevant code to .Rprofile?"
    echo "Press y or n, followed by [ENTER]:"
    echo ""
    read allow_report
    if [ "${allow_report}" == "y" ]; then
      ## Windows does not reliably use newlines with printf
      sed_fun '/^options(radiant.maxRequestSize/d' "${RPROF}"
      sed_fun '/^options(radiant.report/d' "${RPROF}" 
      sed_fun '/^options(radiant.shinyFiles/d' "${RPROF}"
      sed_fun '/^#.*List.*specific.*directories.*you.*want.*to.*use.*with.*radiant/d' "${RPROF}"
      sed_fun '/^#.*options(radiant\.sf_volumes.*=.*c(Git.*=.*"\/home\/jovyan\/git"))/d' "${RPROF}"
      echo 'options(radiant.maxRequestSize = -1)' >> "${RPROF}"
      echo 'options(radiant.report = TRUE)' >> "${RPROF}"
      echo 'options(radiant.shinyFiles = TRUE)' >> "${RPROF}"
      echo '# List specific directories you want to use with radiant' >> "${RPROF}"
      echo '# options(radiant.sf_volumes = c(Git = "/home/jovyan/git"))' >> "${RPROF}"
      echo '' >> "${RPROF}"
      sed_fun '/^[\s]*$/d' "${RPROF}"
    fi
  fi

  ## adding an environment dir for conda to use
  if [ ! -d "${HOMEDIR}/.rsm-msba/conda/envs" ]; then
    mkdir -p "${HOMEDIR}/.rsm-msba/conda/envs"
  fi

  ## adding an dir for zsh to use
  if [ ! -d "${HOMEDIR}/.rsm-msba/zsh" ]; then
    mkdir -p "${HOMEDIR}/.rsm-msba/zsh"
  fi

  BUILD_DATE=$(docker inspect -f '{{.Created}}' ${IMAGE}:${IMAGE_VERSION})

  {
    # check if network already exists
    docker network inspect ${NETWORK} >/dev/null 2>&1 
  } || {
    # if network doesn't exist create it
    echo "--- Creating docker network: ${NETWORK} ---"
    docker network create ${NETWORK} 
  }

  echo $BOUNDARY
  echo "Starting the ${LABEL} computing environment on ${ostype} ${chip}"
  echo "Version   : ${DOCKERHUB_VERSION}"
  echo "Build date: ${BUILD_DATE//T*/}"
  echo "Base dir. : ${HOMEDIR}"
  echo "Cont. name: ${LABEL}"
  echo $BOUNDARY

  has_volume=$(docker volume ls | awk "/pg_data/" | awk '{print $2}')
  if [ "${has_volume}" == "" ]; then
    docker volume create --name=pg_data
  fi
  {
    docker run --name ${LABEL} --net ${NETWORK} --rm \
      -p 127.0.0.1:2222:22 -p 127.0.0.1:8989:8989 -p 127.0.0.1:8765:8765 -p 127.0.0.1:8501:8501 -p 127.0.0.1:8000:8000 \
      -e NB_USER=0 -e NB_UID=1002 -e NB_GID=1002 \
      -e TZ=${TIMEZONE} \
      -v "${HOMEDIR}":/home/${NB_USER} $MNT \
      -v pg_data:/var/lib/postgresql/${POSTGRES_VERSION}/main \
      ${IMAGE}:${IMAGE_VERSION}
  } || {
    echo $BOUNDARY
    echo "It seems there was a problem starting the docker container. Please"
    echo "report the issue and add a screenshot of any messages shown on screen."
    echo "Press [ENTER] to continue"
    echo $BOUNDARY
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
