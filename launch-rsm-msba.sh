#!/bin/bash

ID="vnijs"
LABEL="rsm-msba"
IMAGE=${ID}/${LABEL}

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

  available=$(docker images -q ${IMAGE})
  if [ "${available}" == "" ]; then
    echo "-----------------------------------------------------------------------"
    echo "Downloading the ${LABEL} computing container"
    echo "-----------------------------------------------------------------------"
    docker logout
    docker pull ${IMAGE}
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
    HOMEDIR="C:/Users/$USERNAME"
    open_browser () {
      start $1
    }
  fi

  BUILD_DATE=$(docker inspect -f '{{.Created}}' ${IMAGE})

  echo "-----------------------------------------------------------------------"
  echo "Starting the ${LABEL} computing container on ${ostype}"
  echo "Build date: ${BUILD_DATE//T*/}"
  echo "-----------------------------------------------------------------------"

  docker run -d -p 8080:80 -p 8787:8787 -p 8989:8888 -v ${HOMEDIR}:/home/rstudio ${IMAGE}

  ## make sure abend is set correctly
  ## https://community.rstudio.com/t/restarting-rstudio-server-in-docker-avoid-error-message/10349/2
  rstudio_abend () {
    if [ -d ${HOMEDIR}/.rstudio/sessions/active ]; then
      find ${HOMEDIR}/.rstudio/sessions/active/*/session-persistent-state -type f | xargs sed -i '' -e 's/abend="1"/abend="0"/'
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
    echo "Press (4) to update the ${LABEL} container, followed by [ENTER]:"
    echo "Press (5) to update the launch scripts, followed by [ENTER]:"
    echo "Press (q) to stop the docker process, followed by [ENTER]:"
    echo "-----------------------------------------------------------------------"
    echo "Note: To start, e.g., Rstudio on a different port type 2 8788 [ENTER]"
    echo "Note: To start a specific container version type, e.g., 4 0.8.6 [ENTER]"
    echo "-----------------------------------------------------------------------"
    read startup port

    if [ ${startup} == 4 ]; then
      running=$(docker ps -q)
      echo "-----------------------------------------------------------------------"
      echo "Updating the ${LABEL} computing container"
      docker stop ${running}

      if [ "${port}" == "" ]; then
        echo "Pulling down tag \"latest\""
        VERSION="latest"
      else
        echo "Pulling down tag ${port}"
        VERSION=${port}
      fi

      docker pull ${IMAGE}:${VERSION}

      echo "-----------------------------------------------------------------------"
      docker run -d -p 8080:80 -p 8787:8787 -p 8989:8888 -v ${HOMEDIR}:/home/rstudio ${IMAGE}:${VERSION}
      echo "-----------------------------------------------------------------------"
    elif [ ${startup} == 5 ]; then
      echo "Updating ${ID} launch script"
      wget https://raw.githubusercontent.com/radiant-rstats/docker/master/launch-rsm-msba.sh -O ${HOMEDIR}/Desktop/launch-rsm-msba.sh
      chmod 755 ${HOMEDIR}/Desktop/launch-rsm-msba.sh
      sh ${HOMEDIR}/Desktop/launch-rsm-msba.sh
      exit 1
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
        docker run -d -p ${port}:80 -v ${HOMEDIR}:/home/rstudio ${IMAGE}
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
        docker run -d -p ${port}:8787 -v ${HOMEDIR}:/home/rstudio ${IMAGE}
        sleep 2s
        open_browser http://localhost:${port}
      fi
    elif [ ${startup} == 3 ]; then
      if [ "${port}" == "" ]; then
        echo "Starting Jupyter Lab in the default browser on port 8989"
        open_browser http://localhost:8989/lab
      else
        echo "Starting Jupyter Lab in the default browser on port ${port}"
        docker run -d -p ${port}:8888 -v ${HOMEDIR}:/home/rstudio ${IMAGE}
        sleep 2s
        open_browser http://localhost:${port}/lab
      fi
    elif [ "${startup}" == "q" ]; then
      echo "-----------------------------------------------------------------------"
      echo "Stopping the ${LABEL} computing container and cleaning up as needed"
      echo "-----------------------------------------------------------------------"

      running=$(docker ps -q)
      if [ "${running}" != "" ]; then
        echo "Stopping running containers ..."
        docker stop ${running}
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
