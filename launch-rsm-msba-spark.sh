#!/bin/bash

## set ARG_HOME to a directory of your choosing if you do NOT
## want to to map the docker home directory to your local
## home directory

## use the command below on macOS or Linux to setup a 'launch'
## command. You can then use that command, e.g., launch ., to
## launch the container from any directory
## ln -s ~/git/docker/launch-rsm-msba-spark.sh /usr/local/bin/launch

## to map the directory where the launch script is located to
## the docker home directory call the script_home function
script_home () {
  echo "$(echo "$( cd "$(dirname "$0")" ; pwd -P )" | sed -E "s|^/([A-z]{1})/|\1:/|")"
}

## change to some other path to use as default
# ARG_HOME="~/rady"
# ARG_HOME="$(script_home)"
ARG_HOME=""
IMAGE_VERSION="latest"
NB_USER="jovyan"
RPASSWORD="rstudio"
JPASSWORD="jupyter"
ID="vnijs"
LABEL="rsm-msba-spark"
# NETWORK=${LABEL}
NETWORK="rsm-docker"
IMAGE=${ID}/${LABEL}
if [ "$2" != "" ]; then
  IMAGE_VERSION="$2"
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
    echo "Downloading the ${LABEL}:${IMAGE_VERSION} computing container"
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
      sed -i $1 $2
    }
  elif [[ "$ostype" == "Darwin" ]]; then
    ostype="macOS"
    HOMEDIR=~
    open_browser () {
      open $1
    }
    sed_fun () {
      sed -i '' -e $1 $2
    }
  else
    ostype="Windows"
    HOMEDIR="C:/Users/$USERNAME"
    open_browser () {
      start $1
    }
    sed_fun () {
      sed -i $1 $2
    }
  fi

  ## change mapping of docker home directory to local directory if specified
  if [ "${ARG_HOME}" != "" ]; then
    if [ ! -d "${ARG_HOME}" ]; then
      echo "The directory ${ARG_HOME} does not yet exist."
      echo "Please create the directory and restart the launch script"
      sleep 5s
      exit 1
    fi
  fi

  if [ "$1" != "${ARG_HOME}" ]; then
    if [ "$1" != "" ]; then
      ARG_HOME="$(cd $1; pwd)"
      ## https://unix.stackexchange.com/questions/295991/sed-error-1-not-defined-in-the-re-under-os-x
      ARG_HOME="$(echo "$ARG_HOME" | sed -E "s|^/([A-z]{1})/|\1:/|")"

      echo "-------------------------------------------------------------------------"
      echo "Do you want to copy git, ssh, and R configuration to this directory (y/n)"
      echo "${ARG_HOME}"
      echo "-------------------------------------------------------------------------"
      read copy_config

      ## make sure no hidden files go into a git repo
      touch ${ARG_HOME}/.gitignore
      sed_fun '/^\.\*/d' ${ARG_HOME}/.gitignore
      echo ".*" >> ${ARG_HOME}/.gitignore

      if [ "${copy_config}" == "y" ]; then
        if [ -f "${HOMEDIR}/.inputrc" ] && [ ! -f "${ARG_HOME}/.inputrc" ]; then
          cp -p ${HOMEDIR}/.inputrc ${ARG_HOME}/.inputrc
        fi
        if [ -f "${HOMEDIR}/.Rprofile" ] && [ ! -f "${ARG_HOME}/.Rprofile" ]; then
          cp -p ${HOMEDIR}/.Rprofile ${ARG_HOME}/.Rprofile
        fi
        if [ -f "${HOMEDIR}/.Renviron" ] && [ ! -f "${ARG_HOME}/.Renviron" ]; then
          cp -p ${HOMEDIR}/.Renviron ${ARG_HOME}/.Renviron
        fi
        if [ -f "${HOMEDIR}/.gitconfig" ] && [ ! -f "${ARG_HOME}/.gitconfig" ]; then
          cp -p ${HOMEDIR}/.gitconfig ${ARG_HOME}/.gitconfig
        fi
        if [ -d "${HOMEDIR}/.ssh" ] && [ ! -d "${ARG_HOME}/.ssh" ]; then
          ## symlinks won't work because they would point to a non-existent directory
          cp -r -p ${HOMEDIR}/.ssh ${ARG_HOME}/.ssh
        fi
      fi
    fi

    if [ -d "${HOMEDIR}/.R" ]; then
      yes | cp -rf ${HOMEDIR}/.R ${ARG_HOME}/.R
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
        rsync -a ${HD}/.rstudio ${AH}/ --exclude sessions --exclude projects --exclude projects_settings
      } ||
      {
        cp -r ${HOMEDIR}/.rstudio ${ARG_HOME}/.rstudio
        rm -rf ${ARG_HOME}/.rstudio/sessions
        rm -rf ${ARG_HOME}/.rstudio/projects
        rm -rf ${ARG_HOME}/.rstudio/projects_settings
      }

    fi
    if [ -d "${HOMEDIR}/.rsm-msba" ] && [ ! -d "${ARG_HOME}/.rsm-msba" ]; then

      {
        which rsync 2>/dev/null
        HD="$(echo "$HOMEDIR" | sed -E "s|^([A-z]):|/\1|")"
        AH="$(echo "$ARG_HOME" | sed -E "s|^([A-z]):|/\1|")"
        rsync -a ${HD}/.rsm-msba ${AH}/ --exclude R --exclude bin --exclude lib --exclude share
      } ||
      {
        cp -r ${HOMEDIR}/.rsm-msba ${ARG_HOME}/.rsm-msba
        rm -rf ${ARG_HOME}/.rsm-msba/R
        rm -rf ${ARG_HOME}/.rsm-msba/bin
        rm -rf ${ARG_HOME}/.rsm-msba/lib
        rm -rf ${ARG_HOME}/.rsm-msba/share
      }
    fi
    SCRIPT_HOME="$(script_home)"
    if [ "${SCRIPT_HOME}" != "${ARG_HOME}" ]; then
      cp -p "$0" ${ARG_HOME}/launch-${LABEL}.${EXT}
      sed_fun "s+^ARG_HOME\=\".*\"+ARG_HOME\=\"\$\(script_home\)\"+" ${ARG_HOME}/launch-${LABEL}.${EXT}
      if [ "$2" != "" ]; then
        sed_fun "s/^IMAGE_VERSION=\".*\"/IMAGE_VERSION=\"${IMAGE_VERSION}\"/" ${ARG_HOME}/launch-${LABEL}.${EXT}
      fi
    fi
    HOMEDIR=${ARG_HOME}
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
    fi
    echo "-----------------------------------------------------------------------"
  fi

  BUILD_DATE=$(docker inspect -f '{{.Created}}' ${IMAGE}:${IMAGE_VERSION})

  echo "-----------------------------------------------------------------------"
  echo "Starting the ${LABEL} computing container on ${ostype}"
  echo "Version   : ${DOCKERHUB_VERSION}"
  echo "Build date: ${BUILD_DATE//T*/}"
  echo "-----------------------------------------------------------------------"

  ## based on https://stackoverflow.com/a/52852871/1974918
  has_network=$(docker network ls | awk "/ ${NETWORK} /" | awk '{print $2}')
  if [ "${has_network}" == "" ]; then
    docker network create ${NETWORK}  # default options are fine
  fi
  has_volume=$(docker volume ls | awk "/pg_data/" | awk '{print $2}')
  if [ "${has_volume}" == "" ]; then
    docker volume create --name=pg_data
  fi
  {
    docker run --net ${NETWORK} -d \
      -p 8080:8080 -p 8787:8787 -p 8989:8989 -p 5432:5432 \
      -e RPASSWORD=${RPASSWORD} -e JPASSWORD=${JPASSWORD} \
      -v ${HOMEDIR}:/home/${NB_USER} \
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
    if [ -d ${HOMEDIR}/.rstudio/sessions/active ]; then
      RSTUDIO_STATE_FILES=$(find ${HOMEDIR}/.rstudio/sessions/active/*/session-persistent-state -type f 2>/dev/null)
      if [ "${RSTUDIO_STATE_FILES}" != "" ]; then
        sed_fun 's/abend="1"/abend="0"/' ${RSTUDIO_STATE_FILES}
      fi
    fi
    if [ -d ${HOMEDIR}/.rstudio/monitored/user-settings ]; then
      touch ${HOMEDIR}/.rstudio/monitored/user-settings/user-settings
      sed_fun '/^alwaysSaveHistory="[0-1]"/d' ${HOMEDIR}/.rstudio/monitored/user-settings/user-settings
      sed_fun '/^loadRData="[0-1]"/d' ${HOMEDIR}/.rstudio/monitored/user-settings/user-settings
      sed_fun '/^saveAction="[0-1]"/d' ${HOMEDIR}/.rstudio/monitored/user-settings/user-settings
      echo 'alwaysSaveHistory="1"' >> ${HOMEDIR}/.rstudio/monitored/user-settings/user-settings
      echo 'loadRData="0"' >> ${HOMEDIR}/.rstudio/monitored/user-settings/user-settings
      echo 'saveAction="0"' >> ${HOMEDIR}/.rstudio/monitored/user-settings/user-settings
      sed_fun '/^$/d' ${HOMEDIR}/.rstudio/monitored/user-settings/user-settings
    fi
  }
  rstudio_abend

  show_service () {
    echo "-----------------------------------------------------------------------"
    echo "${LABEL}:${DOCKERHUB_VERSION} computing container on ${ostype} (${BUILD_DATE//T*/})"
    echo "-----------------------------------------------------------------------"
    echo "Press (1) to show Radiant, followed by [ENTER]:"
    echo "Press (2) to show Rstudio, followed by [ENTER]:"
    echo "Press (3) to show Jupyter Lab, followed by [ENTER]:"
    echo "Press (4) to update the ${LABEL} container, followed by [ENTER]:"
    echo "Press (5) to update the launch script, followed by [ENTER]:"
    echo "Press (6) to clear Rstudio sessions and packages, followed by [ENTER]:"
    echo "Press (7) to clear Python packages, followed by [ENTER]:"
    echo "Press (q) to stop the docker process, followed by [ENTER]:"
    echo "-----------------------------------------------------------------------"
    echo "Note: To start, e.g., Rstudio on a different port type 2 8788 [ENTER]"
    echo "Note: To start a specific container version type, e.g., 4 ${DOCKERHUB_VERSION} [ENTER]"
    echo "-----------------------------------------------------------------------"
    read startup port

    if [ -z "${startup}" ]; then
      echo "Invalid entry. Resetting launch menu ..."
    elif [ ${startup} == 1 ]; then
      RPROF=${HOMEDIR}/.Rprofile
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
          echo '' >> ${RPROF}
          echo '' >> ${RPROF}
        fi
      fi
      if [ "${port}" == "" ]; then
        echo "Starting Radiant in the default browser on port 8080"
        open_browser http://localhost:8080
      else
        echo "Starting Radiant in the default browser on port ${port}"
        docker run --net ${NETWORK} -d \
          -p ${port}:8080 \
          -v ${HOMEDIR}:/home/${NB_USER} \
          ${IMAGE}:${IMAGE_VERSION}
        sleep 2s
        open_browser http://localhost:${port}
      fi
    elif [ ${startup} == 2 ]; then
      if [ "${port}" == "" ]; then
        echo "Starting Rstudio in the default browser on port 8787"
        open_browser http://localhost:8787
      else
        rstudio_abend
        echo "Starting Rstudio in the default browser on port ${port}"
        docker run --net ${NETWORK} -d \
          -p ${port}:8787 \
          -e RPASSWORD=${RPASSWORD} \
          -v ${HOMEDIR}:/home/${NB_USER} \
          ${IMAGE}:${IMAGE_VERSION}
        sleep 2s
        open_browser http://localhost:${port}
      fi
    elif [ ${startup} == 3 ]; then
      if [ "${port}" == "" ]; then
        echo "Starting Jupyter Lab in the default browser on port 8989"
        sleep 4s
        open_browser http://localhost:8989/lab
      else
        echo "Starting Jupyter Lab in the default browser on port ${port}"
        docker run --net ${NETWORK} -d \
          -p ${port}:8989 \
          -e JPASSWORD=${JPASSWORD} \
          -v ${HOMEDIR}:/home/${NB_USER}
          ${IMAGE}:${IMAGE_VERSION}
        sleep 5s
        open_browser http://localhost:${port}/lab
      fi
    elif [ ${startup} == 4 ]; then
      running=$(docker ps -q)
      echo "-----------------------------------------------------------------------"
      echo "Updating the ${LABEL} computing container"
      docker stop ${running}
      docker rm ${running}
      docker network rm $(docker network ls | awk "/ ${NETWORK} /" | awk '{print $1}')

      if [ "${port}" == "" ]; then
        echo "Pulling down tag \"latest\""
        VERSION=${IMAGE_VERSION}
      else
        echo "Pulling down tag ${port}"
        VERSION=${port}
      fi

      docker pull ${IMAGE}:${VERSION}

      echo "-----------------------------------------------------------------------"
      ## based on https://stackoverflow.com/a/52852871/1974918
      has_network=$(docker network ls | awk "/ ${NETWORK} /" | awk '{print $2}')
      if [ "${has_network}" == "" ]; then
        docker network create ${NETWORK}  # default options are fine
      fi

      docker run --net ${NETWORK} -d \
        -p 8080:8080 -p 8787:8787 -p 8989:8989 -p 5432:5432 \
        -e RPASSWORD=${RPASSWORD} -e JPASSWORD=${JPASSWORD} \
        -v ${HOMEDIR}:/home/${NB_USER} \
        -v pg_data:/var/lib/postgresql/${POSTGRES_VERSION}/main \
        ${IMAGE}:${IMAGE_VERSION}

      echo "-----------------------------------------------------------------------"
    elif [ ${startup} == 5 ]; then
      echo "Updating ${ID}/${LABEL} launch script"
      running=$(docker ps -q)
      docker stop ${running}
      docker rm ${running}
      docker network rm $(docker network ls | awk "/ ${NETWORK} /" | awk '{print $1}')
      if [ -d "${HOMEDIR}/Desktop" ]; then
        SCRIPT_DOWNLOAD="${HOMEDIR}/Desktop"
      else
        SCRIPT_DOWNLOAD=${HOMEDIR}
      fi
      curl https://raw.githubusercontent.com/radiant-rstats/docker/master/launch-${LABEL}.sh -o ${SCRIPT_DOWNLOAD}/launch-${LABEL}.${EXT}
      chmod 755 ${SCRIPT_DOWNLOAD}/launch-${LABEL}.${EXT}
      ${SCRIPT_DOWNLOAD}/launch-${LABEL}.${EXT}
      exit 1
    elif [ ${startup} == 6 ]; then
      echo "Removing old Rstudio sessions and locally installed R packages from the .rsm-msba directory"
      rm -rf ${HOMEDIR}/.rstudio/sessions
      rm -rf ${HOMEDIR}/.rstudio/projects
      rm -rf ${HOMEDIR}/.rstudio/projects_settings
      rm -rf ${HOMEDIR}/.rsm-msba/R
    elif [ ${startup} == 7 ]; then
      echo "Removing locally installed Python packages from the .rsm-msba directory"
      rm -rf ${HOMEDIR}/.rsm-msba/bin
      rm -rf ${HOMEDIR}/.rsm-msba/lib
      rm -rf ${HOMEDIR}/.rsm-msba/share
    elif [ "${startup}" == "q" ]; then
      echo "-----------------------------------------------------------------------"
      echo "Stopping the ${LABEL} computing container and cleaning up as needed"
      echo "-----------------------------------------------------------------------"

      running=$(docker ps -q)
      if [ "${running}" != "" ]; then
        echo "Stopping running containers ..."
        suspend_sessions () {
          active_session=$(docker exec -t $1 rstudio-server active-sessions | awk '/[0-9]+/ { print $1}' 2>/dev/null)
          if [ "${active_session}" != "" ] && [ "${active_session}" != "OCI" ]; then
            docker exec -t $1 rstudio-server suspend-session ${active_session} 2>/dev/null
          fi
        }
        for index in ${running}; do
          suspend_sessions $index
        done
        docker stop ${running}
        docker network rm $(docker network ls | awk "/ ${NETWORK} /" | awk '{print $1}')
      fi

      imgs=$(docker images | awk '/<none>/ { print $3 }')
      if [ "${imgs}" != "" ]; then
        echo "Removing unused containers ..."
        docker rmi -f ${imgs}
      fi

      procs=$(docker ps -a -q --no-trunc)
      if [ "${procs}" != "" ]; then
        echo "Removing errand docker processes ..."
        docker rm ${procs}
      fi
    else
      echo "Invalid entry. Resetting launch menu ..."
    fi

    if [ "${startup}" == "q" ]; then
      return 2
    else
      return 1
    fi
  }

  ## sleep to give the server time to start up fully
  sleep 2s
  show_service
  ret=$?
  ## keep asking until quit
  while [ $ret -ne 2 ]; do
    sleep 2s
    clear
    show_service
    ret=$?
  done
fi
