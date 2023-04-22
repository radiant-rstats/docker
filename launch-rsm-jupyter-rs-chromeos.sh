#!/bin/bash

## set ARG_HOME to a directory of your choosing if you do NOT
## want to to map the docker home directory to your local
## home directory

## use the command below on to launch the container:
## ~/git/docker/launch-rsm-jupyter-rs.sh -v ~

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
  echo "Example: $0 --tag 2.6.3 --volume ~/project_1"
  echo ""
  exit 1
}

LAUNCH_ARGS="${@:1}"

## parse command-line arguments
while [[ "$#" > 0 ]]; do case $1 in
  -t|--tag) ARG_TAG="$2"; shift;shift;;
  -d|--directory) ARG_DIR="$2";shift;shift;;
  -v|--volume) ARG_VOLUME="$2";shift;shift;;
  -s|--show) ARG_SHOW="show";shift;shift;;
  -h|--help) launch_usage;shift; shift;;
  *) echo "Unknown parameter passed: $1"; echo ""; launch_usage; shift; shift;;
esac; done

## change to some other path to use as default
# ARG_HOME="~/rady"
# ARG_HOME="$(script_home)"
ARG_HOME=""
IMAGE_VERSION="latest"
NB_USER="jovyan"
ID="vnijs"
LABEL="rsm-jupyter-rs"
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
    ostype="ChromeOS"
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
    echo "--- Docker network ${NETWORK} already exists ---"
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
  echo $BOUNDARY

  has_volume=$(docker volume ls | awk "/pg_data/" | awk '{print $2}')
  if [ "${has_volume}" == "" ]; then
    docker volume create --name=pg_data
  fi
  {
    docker run --name ${LABEL} --net ${NETWORK} -d \
      -p 0.0.0.0:8989:8989 -p 0.0.0.0:8765:8765 -p 0.0.0.0:8181:8181 -p 0.0.0.0:8282:8282 -p 0.0.0.0:8501:8501 -p 0.0.0.0:8000:8000 -p 0.0.0.0:6006:6006 \
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

  show_service () {
    echo $BOUNDARY
    echo "Starting the ${LABEL} computing environment on ${ostype} ${chip}"
    echo "Version   : ${DOCKERHUB_VERSION}"
    echo "Build date: ${BUILD_DATE//T*/}"
    echo "Base dir. : ${HOMEDIR}"
    echo "Cont. name: ${LABEL}"
    echo $BOUNDARY
    echo "Press (1) to show Jupyter Lab, followed by [ENTER]:"
    echo "Press (2) to show Rstudio, followed by [ENTER]:"
    echo "Press (3) to show Radiant, followed by [ENTER]:"
    echo "Press (4) to show GitGadget, followed by [ENTER]:"
    echo "Press (5) to show a (ZSH) terminal, followed by [ENTER]:"
    echo "Press (6) to update the ${LABEL} container, followed by [ENTER]:"
    echo "Press (7) to update the launch script, followed by [ENTER]:"
    echo "Press (8) to clear Rstudio sessions and packages, followed by [ENTER]:"
    echo "Press (9) to clear local Python packages, followed by [ENTER]:"
    echo "Press (10) to start a Selenium container, followed by [ENTER]:"
    echo "Press (h) to show help in the terminal and browser, followed by [ENTER]:"
    echo "Press (c) to commit changes, followed by [ENTER]:"
    echo "Press (q) to stop the docker process, followed by [ENTER]:"
    echo $BOUNDARY
    echo "Note: To start, e.g., Jupyter on a different port type 1 8991 [ENTER]"
    echo "Note: To start a specific container version type, e.g., 6 ${DOCKERHUB_VERSION} [ENTER]"
    echo "Note: To commit changes to the container type, e.g., c myversion [ENTER]"
    echo $BOUNDARY
    read menu_exec menu_arg

    # function to shut down running rsm containers
    clean_rsm_containers () {
      rsm_containers=$(docker ps -a --format {{.Names}} | grep "${LABEL}" | tr '\n' ' ')
      eval "docker stop $rsm_containers"
      eval "docker container rm $rsm_containers"
      docker network rm ${NETWORK}
    }

    if [ -z "${menu_exec}" ]; then
      echo "Invalid entry. Resetting launch menu ..."
    elif [ ${menu_exec} == 1 ]; then
      if [ "${menu_arg}" == "" ]; then
        echo "Starting Jupyter Lab in the default browser on localhost:8989/lab"
        sleep 2
        open_browser http://localhost:8989/lab
      else
        echo "Starting Jupyter Lab in the default browser on localhost:${menu_arg}/lab"
        docker run --net ${NETWORK} --name "${LABEL}-${menu_arg}" -d \
          -p 0.0.0.0:${menu_arg}:8989 \
          -e TZ=${TIMEZONE} \
          -v "${HOMEDIR}":/home/${NB_USER} $MNT \
          -v pg_data:/var/lib/postgresql/${POSTGRES_VERSION}/main \
          ${IMAGE}:${IMAGE_VERSION}
        sleep 3
        open_browser http://localhost:${menu_arg}/lab
      fi
    elif [ ${menu_exec} == 2 ]; then
      if [ "${menu_arg}" == "" ]; then
        echo "Starting Rstudio in the default browser on localhost:8989/rstudio"
        open_browser http://localhost:8989/rstudio
      else
        echo "Starting Rstudio in the default browser on localhost:${menu_arg}/rstudio"
        { 
          docker run --name "${LABEL}_${menu_arg}" --net ${NETWORK} -d \
            -p 0.0.0.0:${menu_arg}:8989 \
            -e TZ=${TIMEZONE} \
            -v "${HOMEDIR}":/home/${NB_USER} $MNT \
            -v pg_data:/var/lib/postgresql/${POSTGRES_VERSION}/main \
            ${IMAGE}:${IMAGE_VERSION} 2>/dev/null
          rstudio_abend
          sleep 4
        }
        open_browser http://localhost:${menu_arg}/rstudio
      fi
    elif [ ${menu_exec} == 3 ]; then
      RPROF="${HOMEDIR}/.Rprofile"
      touch "${RPROF}"
      if ! grep -q 'radiant.report = TRUE' ${RPROF} || ! grep -q 'radiant.shinyFiles = TRUE' ${RPROF}; then
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
          sed_fun '/^options(radiant.ace_autoComplete/d' "${RPROF}"
          sed_fun '/^options(radiant.ace_theme/d' "${RPROF}"
          sed_fun '/^#.*List.*specific.*directories.*you.*want.*to.*use.*with.*radiant/d' "${RPROF}"
          sed_fun '/^#.*options(radiant\.sf_volumes.*=.*c(Git.*=.*"\/home\/jovyan\/git"))/d' "${RPROF}"
          echo 'options(radiant.maxRequestSize = -1)' >> "${RPROF}"
          echo 'options(radiant.report = TRUE)' >> "${RPROF}"
          echo 'options(radiant.shinyFiles = TRUE)' >> "${RPROF}"
          echo 'options(radiant.ace_autoComplete = "live")' >> "${RPROF}"
          echo 'options(radiant.ace_theme = "tomorrow")' >> "${RPROF}"
          echo '# List specific directories you want to use with radiant' >> "${RPROF}"
          echo '# options(radiant.sf_volumes = c(Git = "/home/jovyan/git"))' >> "${RPROF}"
          echo '' >> "${RPROF}"
          sed_fun '/^[\s]*$/d' "${RPROF}"
        fi
      fi
      if [ "${menu_arg}" == "" ]; then
        echo "Starting Radiant in the default browser on port 8181"
        docker exec -d ${LABEL} /usr/local/bin/R -e "radiant.data:::launch(package='radiant', host='0.0.0.0', port=8181, run=FALSE)"
        sleep 4
        open_browser http://localhost:8181
      else
        echo "Starting Radiant in the default browser on port ${menu_arg}"
        docker run --net ${NETWORK} --name "${LABEL}-${menu_arg}" -d \
          -p 0.0.0.0:${menu_arg}:8181 \
          -e TZ=${TIMEZONE} \
          -v "${HOMEDIR}":/home/${NB_USER} $MNT \
          ${IMAGE}:${IMAGE_VERSION}
        docker exec -d "${LABEL}-${menu_arg}" /usr/local/bin/R -e "radiant.data:::launch(package='radiant', host='0.0.0.0', port=8181, run=FALSE)"
        sleep 4
        open_browser http://localhost:${menu_arg} 
      fi
    elif [ ${menu_exec} == 4 ]; then
      if [ "${menu_arg}" == "" ]; then
        echo "Starting GitGadget in the default browser on port 8282"
        docker exec -d ${LABEL} /usr/local/bin/R -e "gitgadget:::gitgadget(host='0.0.0.0', port=8282, launch.browser=FALSE)"
        sleep 2
        open_browser http://localhost:8282
      else
        echo "Starting GitGadget in the default browser on port ${menu_arg}"
        docker run --net ${NETWORK} --name "${LABEL}-${menu_arg}" -d \
          -p 0.0.0.0:${menu_arg}:8282 \
          -e TZ=${TIMEZONE} \
          -v "${HOMEDIR}":/home/${NB_USER} $MNT \
          ${IMAGE}:${IMAGE_VERSION}
        docker exec -d "${LABEL}-${menu_arg}" /usr/local/bin/R -e "gitgadget:::gitgadget(host='0.0.0.0', port=${menu_arg}, launch.browser=FALSE)"
        sleep 2
        open_browser http://localhost:${menu_arg} 
      fi
    elif [ ${menu_exec} == 5 ]; then
      if [ "$ARG_SHOW" != "show" ]; then
        clear
      fi
      if [ "${menu_arg}" == "" ]; then
        zsh_lab="${LABEL}"
      else
        zsh_lab="${LABEL}-${menu_arg}"
      fi

      echo $BOUNDARY
      echo "ZSH terminal for container ${zsh_lab} of ${IMAGE}:${IMAGE_VERSION}"
      echo "Type 'exit' to return to the launch menu"
      echo $BOUNDARY
      echo ""
      ## git bash has issues with tty
      if [[ "$ostype" == "Windows" ]]; then
        winpty docker exec -it --user ${NB_USER} ${zsh_lab} sh
      else
        docker exec -it --user ${NB_USER} ${zsh_lab} /bin/zsh
      fi
    elif [ ${menu_exec} == 6 ]; then
      echo $BOUNDARY
      echo "Updating the ${LABEL} computing environment"
      clean_rsm_containers

      if [ "${menu_arg}" == "" ]; then
        echo "Pulling down tag \"latest\""
        VERSION=${IMAGE_VERSION}
      else
        echo "Pulling down tag ${menu_arg}"
        VERSION=${menu_arg}
      fi
      docker pull ${IMAGE}:${VERSION}
      echo $BOUNDARY
      CMD="$0"
      if [ "${menu_arg}" != "" ]; then
        CMD="$CMD -t ${menu_arg}"
      fi
      if [ "$ARG_DIR" != "" ]; then
        CMD="$CMD -d ${ARG_DIR}"
      fi
      if [ "$ARG_VOLUME" != "" ]; then
        CMD="$CMD -v ${ARG_VOLUME}"
      fi
      $CMD
      exit 1
    elif [ ${menu_exec} == 7 ]; then
      echo "Updating ${IMAGE} launch script"
      clean_rsm_containers
      if [ -d "${HOMEDIR}/Desktop" ]; then
        SCRIPT_DOWNLOAD="${HOMEDIR}/Desktop"
      else
        SCRIPT_DOWNLOAD="${HOMEDIR}"
      fi
      {
        cd ~/git/docker 2>/dev/null;
        git pull 2>/dev/null;
        cd -;
        chmod 755 ~/git/docker/launch-${LABEL}.sh 2>/dev/null;
        eval "~/git/docker/launch-${LABEL}.sh ${LAUNCH_ARGS}"
        exit 1
        sleep 10
      } || {
        echo "Updating the launch script failed\n"
        echo "Copy the code below and run it after stopping the docker container with q + Enter\n"
        echo "rm -rf ~/git/docker;\n"
        echo "git clone https://github.com/radiant-rstats/docker.git ~/git/docker;\n"
        echo "\nPress any key to continue"
        read any_to_continue
      }
    elif [ ${menu_exec} == 8 ]; then
      echo $BOUNDARY
      echo "Clean up Rstudio sessions (y/n)?"
      echo $BOUNDARY
      read cleanup

      if [ "${cleanup}" == "y" ]; then
        echo "Cleaning up Rstudio sessions and settings"
        rm -rf "${HOMEDIR}/.rstudio/sessions"
        rm -rf "${HOMEDIR}/.rstudio/projects"
        rm -rf "${HOMEDIR}/.rstudio/projects_settings"
      fi

      echo $BOUNDARY
      echo "Remove locally installed R packages (y/n)?"
      echo $BOUNDARY
      read cleanup

      if [ "${cleanup}" == "y" ]; then
        echo "Removing locally installed R packages"
        rm_list=$(ls -d "${HOMEDIR}"/.rsm-msba/R/* 2>/dev/null)
        for i in ${rm_list}; do
          echo ${i}
          rm -rf "${i}"
          mkdir "${i}"
        done
      fi
    elif [ ${menu_exec} == 9 ]; then
      echo $BOUNDARY
      echo "Remove locally installed Pyton packages (y/n)?"
      echo $BOUNDARY
      read cleanup
      if [ "${cleanup}" == "y" ]; then
        echo "Removing locally installed Python packages"
        rm -rf "${HOMEDIR}/.rsm-msba/bin"
        rm -rf "${HOMEDIR}/.rsm-msba/lib"
        if [ -d "${HOMEDIR}/.rsm-msba/share" ]; then
          rm_list=$(ls "${HOMEDIR}/.rsm-msba/share" | grep -v jupyter)
          for i in ${rm_list}; do
            rm -rf "${HOMEDIR}/.rsm-msba/share/${i}"
          done
        fi
      fi
    elif [ "${menu_exec}" == 10 ]; then
      if [ "${menu_arg}" != "" ]; then
        selenium_port=${menu_arg}
      else 
        selenium_port=4444
      fi
      CPORT=$(curl -s localhost:${selenium_port} 2>/dev/null)
      echo $BOUNDARY
      selenium_nr=($(docker ps -a | awk "/selenium_/" | awk '{print $1}'))
      selenium_nr=${#selenium_nr[@]}
      if [ "$CPORT" != "" ]; then
        echo "A Selenium container may already be running on port ${selenium_port}"
        selenium_nr=$((${selenium_nr}-1))
      else
        docker run --name="selenium_${selenium_nr}" --net ${NETWORK} -d -p 0.0.0.0:${selenium_port}:4444 selenium/standalone-firefox
      fi
      echo "You can access selenium at ip: selenium_${selenium_nr}, port: 4444 from the"
      echo "${LABEL} container and ip: 0.0.0.0, port: ${selenium_port} from the host OS"
      echo "Press any key to continue"
      echo $BOUNDARY
      read continue
    elif [ "${menu_exec}" == "h" ]; then
      echo $BOUNDARY
      echo "Showing help for your OS in the default browser"
      echo "Showing help to start the docker container from the command line"
      echo ""
      if [[ "$ostype" == "macOS" ]]; then
        if [[ "$archtype" == "arm64" ]]; then
          open_browser https://github.com/radiant-rstats/docker/blob/master/install/rsm-msba-macos-m1.md
        else
          open_browser https://github.com/radiant-rstats/docker/blob/master/install/rsm-msba-macos.md
        fi
      elif [[ "$ostype" == "Windows" ]]; then
        open_browser https://github.com/radiant-rstats/docker/blob/master/install/rsm-msba-windows-1909.md
      elif [[ "$ostype" == "WSL2" ]]; then
        open_browser https://github.com/radiant-rstats/docker/blob/master/install/rsm-msba-windows.md
      elif [[ "$ostype" == "ChromeOS" ]]; then
        open_browser https://github.com/radiant-rstats/docker/blob/master/install/rsm-msba-chromeos.md
      else
        open_browser https://github.com/radiant-rstats/docker/blob/master/install/rsm-msba-linux.md
      fi
      $0 --help
      echo "Press any key to continue"
      echo $BOUNDARY
      read continue
    elif [ "${menu_exec}" == "c" ]; then
      container_id=($(docker ps -a | awk "/${ID}\/${LABEL}/" | awk '{print $1}'))
      if [ "${menu_arg}" == "" ]; then
        echo $BOUNDARY
        echo "Are you sure you want to over-write the current image (y/n)?"
        echo $BOUNDARY
        read menu_commit
        if [ "${menu_commit}" == "y" ]; then
          echo $BOUNDARY
          echo "Committing changes to ${IMAGE}"
          echo $BOUNDARY
          docker commit ${container_id[0]} ${IMAGE}:${IMAGE_VERSION}
        else 
          return 1
        fi
        IMAGE_DHUB=${IMAGE}
      else
        menu_arg="${LABEL}-$(echo -e "${menu_arg}" | tr -d '[:space:]')"
        docker commit ${container_id[0]} $ID/${menu_arg}:${IMAGE_VERSION}

        if [ -d "${HOMEDIR}/Desktop" ]; then
          SCRIPT_COPY="${HOMEDIR}/Desktop"
        else
          SCRIPT_COPY="${HOMEDIR}"
        fi
        cp -p "$0" "${SCRIPT_COPY}/launch-${menu_arg}.${EXT}"
        sed_fun "s+^ID\=\".*\"+ID\=\"${ID}\"+" "${SCRIPT_COPY}/launch-${menu_arg}.${EXT}"
        sed_fun "s+^LABEL\=\".*\"+LABEL\=\"${menu_arg}\"+" "${SCRIPT_COPY}/launch-${menu_arg}.${EXT}"

        echo $BOUNDARY
        echo "Committing changes to ${ID}/${menu_arg}"
        echo "Use the following script to launch:"
        echo "${SCRIPT_COPY}/launch-${menu_arg}.${EXT}"
        echo $BOUNDARY
        IMAGE_DHUB=${ID}/${menu_arg}
      fi

      echo $BOUNDARY
      echo "Do you want to push this image to Docker hub (y/n)?"
      echo "Note: This requires an account at https://hub.docker.com/"
      echo "Note: To specify a version tag type, e.g., y 1.0.0"
      echo $BOUNDARY
      read menu_push menu_tag
      if [ "${menu_push}" == "y" ]; then
        {
          docker login
          if [ "${menu_tag}" == "" ]; then
            docker push ${IMAGE_DHUB}:latest
          else
            if [ "${menu_arg}" == "" ]; then
              sed_fun "s/^IMAGE_VERSION=\".*\"/IMAGE_VERSION=\"${menu_tag}\"/" "$0"
            else
              sed_fun "s/^IMAGE_VERSION=\".*\"/IMAGE_VERSION=\"${menu_tag}\"/" "${SCRIPT_COPY}/launch-${menu_arg}.${EXT}"
            fi
            # echo 'docker commit --change "ENV DOCKERHUB_VERSION=${menu_tag}" ${container_id[0]} ${IMAGE_DHUB}:${menu_tag}'
            docker commit --change "ENV DOCKERHUB_VERSION=${menu_tag}" ${container_id[0]} ${IMAGE_DHUB}:${menu_tag}
            docker push ${IMAGE_DHUB}:${menu_tag}
          fi
        } || {
          echo $BOUNDARY
          echo "It seems there was a problem with login or pushing to Dockerhub"
          echo "Please make sure you have an account at https://hub.docker.com/"
          echo $BOUNDARY
          sleep 3s
        }
      fi
    elif [ "${menu_exec}" == "q" ]; then
      echo $BOUNDARY
      echo "Stopping the ${LABEL} computing environment and cleaning up as needed"
      echo $BOUNDARY

      suspend_sessions () {
        active_session=$(docker exec -t $1 rstudio-server active-sessions | awk '/[0-9]+/ { print $1}' 2>/dev/null)
        if [ "${active_session}" != "" ] && [ "${active_session}" != "OCI" ]; then
          docker exec -t $1 rstudio-server suspend-session ${active_session} 2>/dev/null
        fi
      }

      running=$(docker ps -q)
      for index in ${running}; do
        suspend_sessions $index
      done

      clean_rsm_containers

      selenium_containers=$(docker ps -a --format {{.Names}} | grep 'selenium' | tr '\n' ' ')
      if [ "${selenium_containers}" != "" ]; then
        eval "docker stop $selenium_containers"
        eval "docker container rm $selenium_containers"
      fi

      imgs=$(docker images | awk '/<none>/ { print $3 }')
      if [ "${imgs}" != "" ]; then
        echo "Removing unused containers ..."
        docker rmi -f ${imgs}
      fi

      # procs=$(docker ps -a -q --no-trunc)
      # if [ "${procs}" != "" ]; then
      #   echo "Stopping docker processes ..."
      #   docker rm ${procs}
      # fi
    else
      echo "Invalid entry. Resetting launch menu ..."
    fi

    if [ "${menu_exec}" == "q" ]; then
      ## removing empty files and directories created after -v mounting
      if [ "$ARG_HOME" != "" ]; then
        echo "Removing empty files and directories ..."
        find "$ARG_HOME" -empty -type d -delete
        find "$ARG_HOME" -empty -type f -delete
      fi
      return 2
    else
      return 1
    fi
  }

  ## sleep to give the server time to start up fully
  sleep 2
  show_service
  ret=$?
  ## keep asking until quit
  while [ $ret -ne 2 ]; do
    sleep 2
    if [ "$ARG_SHOW" != "show" ]; then
      clear
    fi
    show_service
    ret=$?
  done
fi
