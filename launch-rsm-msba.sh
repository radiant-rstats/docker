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
LABEL="rsm-msba"
if [ "$2" != "" ]; then
  IMAGE_VERSION="$2"
else
  IMAGE_VERSION="latest"
fi
IMAGE=${ID}/${LABEL}

## username and password for postgres and pgadmin4
POSTGRES_USER=postgres
POSTGRES_PASSWORD=postgres
PGADMIN_DEFAULT_EMAIL=admin@pgadmin.com
PGADMIN_DEFAULT_PASSWORD=pgadmin
POSTGRES_VERSION=10.6
PGADMIN_VERSION=3.6

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

  ## based on https://stackoverflow.com/a/52852871/1974918
  has_network=$(docker network ls | awk "/${LABEL}/" | awk '{print $2}')
  if [ "${has_network}" == "" ]; then
    docker network create ${LABEL}  # default options are fine
  fi
  docker run --net ${LABEL} -d -p 8080:8080 -p 8787:8787 -p 8989:8989 -v ${HOMEDIR}:/home/rstudio ${IMAGE}:${IMAGE_VERSION}

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

  show_service () {
    echo "-----------------------------------------------------------------------"
    echo "${LABEL} computing container on ${ostype} (${BUILD_DATE//T*/})"
    echo "-----------------------------------------------------------------------"
    echo "Press (1) to show Radiant, followed by [ENTER]:"
    echo "Press (2) to show Rstudio, followed by [ENTER]:"
    echo "Press (3) to show Jupyter Lab, followed by [ENTER]:"
    echo "Press (4) to launch postgres server, followed by [ENTER]:"
    echo "Press (5) to launch pgadmin4, followed by [ENTER]:"
    echo "Press (6) to update the ${LABEL} container, followed by [ENTER]:"
    echo "Press (7) to update the launch script, followed by [ENTER]:"
    echo "Press (q) to stop the docker process, followed by [ENTER]:"
    echo "-----------------------------------------------------------------------"
    echo "Note: To start, e.g., Rstudio on a different port type 2 8788 [ENTER]"
    echo "Note: To start a specific container version type, e.g., 6 0.9.2 [ENTER]"
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
        docker run --net ${LABEL} -d -p ${port}:8080 -v ${HOMEDIR}:/home/rstudio ${IMAGE}:${IMAGE_VERSION}
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
        docker run --net ${LABEL} -d -p ${port}:8787 -v ${HOMEDIR}:/home/rstudio ${IMAGE}:${IMAGE_VERSION}
        sleep 2s
        open_browser http://localhost:${port}
      fi
    elif [ ${startup} == 3 ]; then
      if [ "${port}" == "" ]; then
        echo "Starting Jupyter Lab in the default browser on port 8989"
        open_browser http://localhost:8989/lab
      else
        echo "Starting Jupyter Lab in the default browser on port ${port}"
        docker run --net ${LABEL} -d -p ${port}:8989 -v ${HOMEDIR}:/home/rstudio ${IMAGE}:${IMAGE_VERSION}
        sleep 2s
        open_browser http://localhost:${port}/lab
      fi
    elif [ ${startup} == 4 ]; then
      if [ "${port}" == "" ]; then
        port=5432
      fi
      if [ ! -d "${HOMEDIR}/postgresql/data" ]; then
        mkdir -p "${HOMEDIR}/postgresql/data"
      fi
      echo "Starting postgres on port ${port}"
      docker run --net ${LABEL} -p ${port}:5432 \
        --name postgres \
        -e POSTGRES_USER=${POSTGRES_USER} \
        -e POSTGRES_PASSWORD=${POSTGRES_PASSWORD} \
        -e PGDATA=/var/lib/postgresql/data \
        -v ${HOMEDIR}/postgresql/data:/var/lib/postgresql/data \
        -d postgres:${POSTGRES_VERSION}
      sleep 2s
    elif [ ${startup} == 5 ]; then
      if [ "${port}" == "" ]; then
        port=5050
      fi
      if [ ! -d "${HOMEDIR}/postgresql/pgadmin" ]; then
        mkdir -p "${HOMEDIR}/postgresql/pgadmin"
      fi
      echo "Starting pgadmin4 on port ${port}"
      docker run --net ${LABEL} -p ${port}:80 \
        --name pgadmin \
        -e PGADMIN_DEFAULT_EMAIL=${PGADMIN_DEFAULT_EMAIL} \
        -e PGADMIN_DEFAULT_PASSWORD=${PGADMIN_DEFAULT_PASSWORD} \
        -v ${HOMEDIR}/postgresql/pgadmin:/var/lib/pgadmin \
        -d dpage/pgadmin4:${PGADMIN_VERSION}
      sleep 2s
      open_browser http://localhost:${port}
    elif [ ${startup} == 6 ]; then
      running=$(docker ps -q)
      echo "-----------------------------------------------------------------------"
      echo "Updating the ${LABEL} computing container"
      docker stop ${running}
      docker rm ${running}
      docker network rm ${LABEL}

      if [ "${port}" == "" ]; then
        echo "Pulling down tag \"latest\""
        VERSION=${IMAGE_VERSION}
      else
        echo "Pulling down tag ${port}"
        VERSION=${port}
      fi

      docker pull ${IMAGE}:${VERSION}

      if [ "$(docker images -q postgres:${POSTGRES_VERSION})" != "" ]; then
        docker pull postgres:${POSTGRES_VERSION}
      fi

      if [ "$(docker images -q dpage/pgadmin4${PGADMIN_VERSION})" != "" ]; then
        docker pull dpage/pgadmin4:${PGADMIN_VERSION}
      fi

      echo "-----------------------------------------------------------------------"
      ## based on https://stackoverflow.com/a/52852871/1974918
      has_network=$(docker network ls | awk "/${LABEL}/" | awk '{print $2}')
      if [ "${has_network}" == "" ]; then
        docker network create ${LABEL}  # default options are fine
      fi
      docker run --net ${LABEL} -d -p 8080:8080 -p 8787:8787 -p 8989:8989 -v ${HOMEDIR}:/home/rstudio ${IMAGE}:${VERSION}
      echo "-----------------------------------------------------------------------"
    elif [ ${startup} == 7 ]; then
      echo "Updating ${ID}/${LABEL} launch script"
      running=$(docker ps -q)
      docker stop ${running}
      docker rm ${running}
      docker network rm ${LABEL}
      curl https://raw.githubusercontent.com/radiant-rstats/docker/master/launch-${LABEL}.sh -o ${HOMEDIR}/Desktop/launch-${LABEL}.sh
      chmod 755 ${HOMEDIR}/Desktop/launch-${LABEL}.sh
      ${HOMEDIR}/Desktop/launch-${LABEL}.sh
      exit 1

    elif [ "${startup}" == "q" ]; then
      echo "-----------------------------------------------------------------------"
      echo "Stopping the ${LABEL} computing container and cleaning up as needed"
      echo "-----------------------------------------------------------------------"

      running=$(docker ps -q)
      if [ "${running}" != "" ]; then
        echo "Stopping running containers ..."
        docker stop ${running}
        docker network rm ${LABEL}
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
