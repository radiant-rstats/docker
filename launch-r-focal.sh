#!/bin/bash

## set ARG_HOME to a directory of your choosing if you do NOT
## want to to map the docker home directory to your local
## home directory

## use the command below on macOS or Linux to setup a 'launch'
## command. You can then use that command, e.g., launch ., to
## launch the container from any directory
## ln -s ~/git/docker/launch-r-focal.sh /usr/local/bin/launch

## to map the directory where the launch script is located to
## the docker home directory call the script_home function
script_home () {
  echo "$(echo "$( cd "$(dirname "$0")" ; pwd -P )" | sed -E "s|^/([A-z]{1})/|\1:/|")"
}

function launch_usage() {
  echo "Usage: $0 [-t tag (version)] [-d directory]"
  echo "  -t, --tag         Docker image tag (version) to use"
  echo "  -d, --directory   Base directory to use"
  echo "  -v, --volume      Volume to mount as home directory"
  echo "  -s, --show        Show all output generated on launch"
  echo "  -h, --help        Print help and exit"
  echo ""
  echo "Example: $0 --tag 1.8.0 --directory ~/project_1"
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

## change to some other path to use as default
# ARG_HOME="~/rady"
# ARG_HOME="$(script_home)"
ARG_HOME=""
IMAGE_VERSION="latest"
NB_USER="jovyan"
PASSWORD="jupyter"
ID="vnijs"
LABEL="r-focal"
NETWORK="rsm-docker"
IMAGE=${ID}/${LABEL}
if [ "$ARG_TAG" != "" ]; then
  IMAGE_VERSION="$ARG_TAG"
  DOCKERHUB_VERSION=${IMAGE_VERSION}
else
  ## see https://stackoverflow.com/questions/34051747/get-environment-variable-from-docker-container
  DOCKERHUB_VERSION=$(docker inspect -f '{{range $index, $value := .Config.Env}}{{println $value}} {{end}}' ${IMAGE}:${IMAGE_VERSION} | grep DOCKERHUB_VERSION)
  DOCKERHUB_VERSION="${DOCKERHUB_VERSION#*=}"
fi

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

## script to start shiny-apps, Rstudio, and JupyterLab
if [ "$ARG_SHOW" != "show" ]; then
  clear
fi
has_docker=$(which docker)
if [ "${has_docker}" == "" ]; then
  echo "-----------------------------------------------------------------------"
  echo "Docker is not installed. Download and install Docker from"
  if [[ "$ostype" == "Linux" ]]; then
    echo "https://www.digitalocean.com/community/tutorials/how-to-install-and-use-docker-on-ubuntu-20-04"
  elif [[ "$ostype" == "Darwin" ]]; then
    echo "https://download.docker.com/mac/stable/Docker.dmg"
  else
    echo "https://store.docker.com/editions/community/docker-ce-desktop-windows"
  fi
  echo "-----------------------------------------------------------------------"
  read
else

  ## check if docker is running at all
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
        sleep 1
      done
    else
      echo "-----------------------------------------------------------------------"
      echo "Docker is not running. Please start docker on your computer"
      echo "When docker has finished starting up press [ENTER] to continue"
      echo "-----------------------------------------------------------------------"
      read
    fi
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

  if [[ "$ostype" == "Linux" ]]; then
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
    ostype="macOS"
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
      echo "Copying Rstudio settings to:"
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

  ## based on https://stackoverflow.com/a/52852871/1974918
  has_network=$(docker network ls | awk "/ ${NETWORK} /" | awk '{print $2}')
  if [ "${has_network}" == "" ]; then
    docker network create ${NETWORK} 
  fi

  echo "-----------------------------------------------------------------------"
  echo "Starting the ${LABEL} computing environment on ${ostype}"
  echo "Version   : ${DOCKERHUB_VERSION}"
  echo "Build date: ${BUILD_DATE//T*/}"
  echo "Base dir. : ${HOMEDIR}"
  echo "-----------------------------------------------------------------------"
  {
    docker run --net ${NETWORK} -d \
      -p 127.0.0.1:8181:8181 -p 127.0.0.1:8787:8787 -p 127.0.0.1:2121:22 \
      -e PASSWORD=${PASSWORD} \
      -v "${HOMEDIR}":/home/${NB_USER} $MNT \
      --name test_ssh \
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

  show_service () {
    echo "-----------------------------------------------------------------------"
    echo "${LABEL}:${DOCKERHUB_VERSION} computing environment on ${ostype} (${BUILD_DATE//T*/})"
    echo "-----------------------------------------------------------------------"
    echo "Press (1) to show shiny-apps, followed by [ENTER]:"
    echo "Press (2) to show Rstudio, followed by [ENTER]:"
    echo "Press (3) to show a (ZSH) terminal, followed by [ENTER]:"
    echo "Press (4) to update the ${LABEL} container, followed by [ENTER]:"
    echo "Press (5) to update the launch script, followed by [ENTER]:"
    echo "Press (6) to clear Rstudio sessions and packages, followed by [ENTER]:"
    echo "Press (7) to start a Selenium container, followed by [ENTER]:"
    echo "Press (h) to show help in the terminal and browser, followed by [ENTER]:"
    echo "Press (c) to commit changes, followed by [ENTER]:"
    echo "Press (q) to stop the docker process, followed by [ENTER]:"
    echo "-----------------------------------------------------------------------"
    echo "Note: To start, e.g., Rstudio on a different port type 2 8788 [ENTER]"
    echo "Note: To start a specific container version type, e.g., 4 ${DOCKERHUB_VERSION} [ENTER]"
    echo "Note: To commit changes type, e.g., c myversion [ENTER]"
    echo "-----------------------------------------------------------------------"
    read menu_exec menu_arg

    if [ -z "${menu_exec}" ]; then
      echo "Invalid entry. Resetting launch menu ..."
    elif [ ${menu_exec} == 1 ]; then
      if [ "${menu_arg}" == "" ]; then
        echo "Starting shiny-apps in the default browser on port 8181"
        open_browser http://localhost:8181
      else
        echo "Starting shiny-apps in the default browser on port ${menu_arg}"
        docker run --net ${NETWORK} -d \
          -p 127.0.0.1:${menu_arg}:8181 \
          -v "${HOMEDIR}":/home/${NB_USER} $MNT \
          ${IMAGE}:${IMAGE_VERSION}
        sleep 2s
        open_browser http://localhost:${menu_arg}
      fi
    elif [ ${menu_exec} == 2 ]; then
      if [ "${menu_arg}" == "" ]; then
        echo "Starting Rstudio in the default browser on port 8787"
        open_browser http://localhost:8787
      else
        rstudio_abend
        echo "Starting Rstudio in the default browser on port ${menu_arg}"
        docker run --net ${NETWORK} -d \
          -p 127.0.0.1:${menu_arg}:8787 \
          -e PASSWORD=${PASSWORD} \
          -v "${HOMEDIR}":/home/${NB_USER} $MNT \
          ${IMAGE}:${IMAGE_VERSION}
        sleep 2s
        open_browser http://localhost:${menu_arg}
      fi
    elif [ ${menu_exec} == 3 ]; then
        running=$(docker ps -q | awk '{print $1}')
        if [ "${running}" != "" ]; then
          if [ "$ARG_SHOW" != "show" ]; then
            clear
          fi
          echo "------------------------------------------------------------------------------"
          echo "ZSH Terminal for session ${running} of ${IMAGE}:${IMAGE_VERSION}"
          echo "Type 'exit' to return to the launch menu"
          echo "------------------------------------------------------------------------------"
          echo ""
          docker exec -it --user ${NB_USER} ${running} /bin/zsh
        fi
    elif [ ${menu_exec} == 4 ]; then
      running=$(docker ps -q)
      echo "-----------------------------------------------------------------------"
      echo "Updating the ${LABEL} computing environment"
      docker stop ${running}
      docker rm ${running}
      docker network rm $(docker network ls | awk "/ ${NETWORK} /" | awk '{print $1}')

      if [ "${menu_arg}" == "" ]; then
        echo "Pulling down tag \"latest\""
        VERSION=${IMAGE_VERSION}
      else
        echo "Pulling down tag ${menu_arg}"
        VERSION=${menu_arg}
      fi
      docker pull ${IMAGE}:${VERSION}
      echo "-----------------------------------------------------------------------"
      CMD="$0"
      if [ "${menu_arg}" != "" ]; then
        CMD="$CMD -t ${menu_arg}"
      fi
      if [ "$ARG_DIR" != "" ]; then
        CMD="$CMD -d ${ARG_DIR}"
      fi
      $CMD
      exit 1
    elif [ ${menu_exec} == 5 ]; then
      echo "Updating ${IMAGE} launch script"
      running=$(docker ps -q)
      docker stop ${running}
      docker rm ${running}
      docker network rm $(docker network ls | awk "/ ${NETWORK} /" | awk '{print $1}')

      if [ -d "${HOMEDIR}/Desktop" ]; then
        SCRIPT_DOWNLOAD="${HOMEDIR}/Desktop"
      else
        SCRIPT_DOWNLOAD="${HOMEDIR}"
      fi
      if [ $ostype == "ChromeOS" ]; then
        sudo -- bash -c "rm -f /usr/local/bin/launch; curl https://raw.githubusercontent.com/radiant-rstats/docker/master/launch-$LABEL-chromeos.sh -o /usr/local/bin/launch; chmod 755 /usr/local/bin/launch";
        /usr/local/bin/launch "${@:1}"
      elif [ $ostype == "WSL2" ]; then
        sudo -- bash -c "rm -f /usr/local/bin/launch; curl https://raw.githubusercontent.com/radiant-rstats/docker/master/launch-$LABEL.sh -o /usr/local/bin/launch; chmod 755 /usr/local/bin/launch";
        /usr/local/bin/launch "${@:1}"
      else 
        curl https://raw.githubusercontent.com/radiant-rstats/docker/master/launch-${LABEL}.sh -o "${SCRIPT_DOWNLOAD}/launch-${LABEL}.${EXT}"
        chmod 755 "${SCRIPT_DOWNLOAD}/launch-${LABEL}.${EXT}"
        "${SCRIPT_DOWNLOAD}/launch-${LABEL}.${EXT}"
      fi
      exit 1
    elif [ ${menu_exec} == 6 ]; then
      echo "-----------------------------------------------------"
      echo "Clean up Rstudio sessions (y/n)?"
      echo "-----------------------------------------------------"
      read cleanup

      if [ "${cleanup}" == "y" ]; then
        echo "Cleaning up Rstudio sessions and settings"
        rm -rf "${HOMEDIR}/.rstudio/sessions"
        rm -rf "${HOMEDIR}/.rstudio/projects"
        rm -rf "${HOMEDIR}/.rstudio/projects_settings"
      fi

      echo "-----------------------------------------------------"
      echo "Remove locally installed R packages (y/n)?"
      echo "-----------------------------------------------------"
      read cleanup

      if [ "${cleanup}" == "y" ]; then
        echo "Removing locally installed R packages"
        rm_list=$(ls -d "${HOMEDIR}"/.rsm-msba/R/*/[0-9]\.[0-9] 2>/dev/null)
        for i in ${rm_list}; do
          rm -rf "${i}"
          mkdir "${i}"
        done
      fi
    elif [ "${menu_exec}" == 7 ]; then
      if [ "${menu_arg}" != "" ]; then
        selenium_port=${menu_arg}
      else 
        selenium_port=4444
      fi
      CPORT=$(curl -s localhost:${selenium_port} 2>/dev/null)
      echo "-----------------------------------------------------------------------"
      selenium_nr=($(docker ps -a | awk "/selenium_/" | awk '{print $1}'))
      selenium_nr=${#selenium_nr[@]}
      if [ "$CPORT" != "" ]; then
        echo "A Selenium container may already be running on port ${selenium_port}"
        selenium_nr=$((${selenium_nr}-1))
      else
        docker run --name="selenium_${selenium_nr}" --net ${NETWORK} -d -p ${selenium_port}:4444 selenium/standalone-firefox
      fi
      echo "You can access selenium at ip: selenium_${selenium_nr}, port: 4444 from the"
      echo "${LABEL} container and ip: 127.0.0.1, port: ${selenium_port} from the host OS"
      echo "Press any key to continue"
      echo "-----------------------------------------------------------------------"
      read continue
    elif [ "${menu_exec}" == "h" ]; then
      echo "-----------------------------------------------------------------------"
      echo "Showing help for your OS in the default browser"
      echo "Showing help to start the docker container from the command line"
      echo ""
      if [[ "$ostype" == "macOS" ]]; then
        open_browser https://github.com/radiant-rstats/docker/blob/master/install/rsm-msba-macos.md
      elif [[ "$ostype" == "Windows" ]]; then
        open_browser https://github.com/radiant-rstats/docker/blob/master/install/rsm-msba-windows.md
      elif [[ "$ostype" == "ChromeOS" ]]; then
        open_browser https://github.com/radiant-rstats/docker/blob/master/install/rsm-msba-chromeos.md
      else
        open_browser https://github.com/radiant-rstats/docker/blob/master/install/rsm-msba-linux.md
      fi
      $0 --help
      echo "Press any key to continue"
      echo "-----------------------------------------------------------------------"
      read continue
    elif [ "${menu_exec}" == "c" ]; then
      container_id=($(docker ps -a | awk "/${ID}\/${LABEL}/" | awk '{print $1}'))
      if [ "${menu_arg}" == "" ]; then
        echo "-----------------------------------------------------------------------"
        echo "Are you sure you want to over-write the current image (y/n)?"
        echo "-----------------------------------------------------------------------"
        read menu_commit
        if [ "${menu_commit}" == "y" ]; then
          echo "-----------------------------------------------------------------------"
          echo "Committing changes to ${IMAGE}"
          echo "-----------------------------------------------------------------------"
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

        echo "-----------------------------------------------------------------------"
        echo "Committing changes to ${ID}/${menu_arg}"
        echo "Use the following script to launch:"
        echo "${SCRIPT_COPY}/launch-${menu_arg}.${EXT}"
        echo "-----------------------------------------------------------------------"
        IMAGE_DHUB=${ID}/${menu_arg}
      fi

      echo "-----------------------------------------------------------------------"
      echo "Do you want to push this image to Docker hub (y/n)?"
      echo "Note: This requires an account at https://hub.docker.com/"
      echo "Note: To specify a version tag type, e.g., y 1.0.0"
      echo "-----------------------------------------------------------------------"
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
            docker commit --change "ENV DOCKERHUB_VERSION=${menu_tag}" ${container_id[0]} ${IMAGE_DHUB}:${menu_tag}
            docker push ${IMAGE_DHUB}:${menu_tag}
          fi
        } || {
          echo "-----------------------------------------------------------------------"
          echo "It seems there was a problem with login or pushing to Dockerhub"
          echo "Please make sure you have an account at https://hub.docker.com/"
          echo "-----------------------------------------------------------------------"
          sleep 3s
        }
      fi
    elif [ "${menu_exec}" == "q" ]; then
      echo "-----------------------------------------------------------------------"
      echo "Stopping the ${LABEL} computing environment and cleaning up as needed"
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
        echo "Stopping docker processes ..."
        docker rm ${procs}
      fi
    else
      echo "Invalid entry. Resetting launch menu ..."
    fi

    if [ "${menu_exec}" == "q" ]; then
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
  sleep 2s
  show_service
  ret=$?
  ## keep asking until quit
  while [ $ret -ne 2 ]; do
    sleep 2s
    if [ "$ARG_SHOW" != "show" ]; then
      clear
    fi
    show_service
    ret=$?
  done
fi
