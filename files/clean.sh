#!/bin/bash

## script to run from jupyter lab to clean up settings
## and remove locally install R and python packages
## cleaning up settings is a common requirement for Rstudio

HOMEDIR="/home/$(whoami)"

if [ ! -d "${HOMEDIR}/.rsm-msba" ]; then
  echo "-----------------------------------------------------"
  echo "Directory ${HOMEDIR}/.rsm-msba not found"
  echo "No cleanup done"
  echo "-----------------------------------------------------"
else
  echo "-----------------------------------------------------"
  echo "Clean up Rstudio sessions and settings (y/n)?"
  echo "-----------------------------------------------------"
  read cleanup

  if [ "${cleanup}" == "y" ]; then
    echo "Cleaning up Rstudio sessions and settings"
    rm -rf "${HOMEDIR}/.rstudio/sessions"
    rm -rf "${HOMEDIR}/.rstudio/projects"
    rm -rf "${HOMEDIR}/.rstudio/projects_settings"

    ## make sure abend is set correctly
    ## https://community.rstudio.com/t/restarting-rstudio-server-in-docker-avoid-error-message/10349/2
    rstudio_abend () {
      if [ -d "${HOMEDIR}/.rstudio/monitored/user-settings" ]; then
        touch "${HOMEDIR}/.rstudio/monitored/user-settings/user-settings"
        sed -i '/^alwaysSaveHistory="[0-1]"/d' "${HOMEDIR}/.rstudio/monitored/user-settings/user-settings"
        sed -i '/^loadRData="[0-1]"/d' "${HOMEDIR}/.rstudio/monitored/user-settings/user-settings"
        sed -i '/^saveAction=/d' "${HOMEDIR}/.rstudio/monitored/user-settings/user-settings"
        echo 'alwaysSaveHistory="1"' >> "${HOMEDIR}/.rstudio/monitored/user-settings/user-settings"
        echo 'loadRData="0"' >> "${HOMEDIR}/.rstudio/monitored/user-settings/user-settings"
        echo 'saveAction="0"' >> "${HOMEDIR}/.rstudio/monitored/user-settings/user-settings"
        sed -i '/^$/d' "${HOMEDIR}/.rstudio/monitored/user-settings/user-settings"
      fi
    }
    rstudio_abend
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

  echo "-----------------------------------------------------"
  echo "Remove locally installed Python packages (y/n)?"
  echo "-----------------------------------------------------"
  read cleanup

  if [ "${cleanup}" == "y" ]; then
    echo "Removing locally installed Python packages"
    rm -rf "${HOMEDIR}/.rsm-msba/bin"
    rm -rf "${HOMEDIR}/.rsm-msba/lib"
    rm_list=$(ls "${HOMEDIR}/.rsm-msba/share" | grep -v jupyter | grep -v code-server)
    for i in ${rm_list}; do
       rm -rf "${HOMEDIR}/.rsm-msba/share/${i}"
    done
  fi

  echo "-----------------------------------------------------"
  echo "Cleanup complete"
  echo "-----------------------------------------------------"
fi
