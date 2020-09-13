#!/bin/bash

ostype=`uname`
if [[ "$ostype" == "Linux" ]]; then
  HOMEDIR=~
  sed_fun () {
    sed -i $1 "$2"
  }
  is_wsl=$(which explorer.exe)
  if [[ "$is_wsl" != "" ]]; then
    ostype="WSL2"
    HOMEDIR=~
  fi
elif [[ "$ostype" == "Darwin" ]]; then
  ostype="macOS"
  HOMEDIR=~
  sed_fun () {
    sed -i '' -e $1 "$2"
  }
else
  ostype="Windows"
  HOMEDIR="C:/Users/$USERNAME"
  sed_fun () {
    sed -i $1 "$2"
  }
fi

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

echo "-----------------------------------------------------------------------"
echo "Set appropriate default settings for Rstudio"
echo "-----------------------------------------------------------------------"

rstudio_abend

echo "-----------------------------------------------------------------------"
echo "Set report generation options for Radiant"
echo "-----------------------------------------------------------------------"

RPROF="${HOMEDIR}/.Rprofile"
touch "${RPROF}"

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
if ! grep -q 'options(\s*repos\s*' ${RPROF}; then
  echo 'if (Sys.info()["sysname"] == "Linux") {
    options(repos = c(
      RSM = "https://rsm-compute-01.ucsd.edu:4242/rsm-msba/__linux__/focal/latest",
      RSPM = "https://packagemanager.rstudio.com/all/__linux__/focal/latest",
      CRAN = "https://cloud.r-project.org"
    ))
  } else {
    options(repos = c(
      RSM = "https://radiant-rstats.github.io/minicran",
      CRAN = "https://cloud.r-project.org"
    ))
  }' >> "${RPROF}"
fi
echo '# List specific directories you want to use with radiant' >> "${RPROF}"
echo '# options(radiant.sf_volumes = c(Git = "/home/jovyan/git"))' >> "${RPROF}"
echo '' >> "${RPROF}"
sed_fun '/^[\s]*$/d' "${RPROF}"

echo "-----------------------------------------------------------------------"
echo "Setup extensions for VS Code"
echo "-----------------------------------------------------------------------"

mkdir -p ~/.rsm-msba/share/code-server/User
# rm -rf ~/.rsm-msba/share/code-server/User
cp /opt/code-server/settings.json ~/.rsm-msba/share/code-server/User/settings.json

# extension available in code-server market place
extensions="mechatroner.rainbow-csv"

for ext in $extensions; do
  echo "Installing extension: $ext"
  code-server --extensions-dir  $CODE_EXTENSIONS_DIR --install-extension "$ext" > /dev/null 2>&1
done

# avoid including (large) vscode extensions
wget https://raw.githubusercontent.com/radiant-rstats/docker-vsix/master/vsix_list.txt
wget -i vsix_list.txt

for file in *.vsix; do
  f=$(basename "$file" .vsix)
  echo "Installing extension: $f"
  code-server --extensions-dir  $CODE_EXTENSIONS_DIR --install-extension "$file" > /dev/null 2>&1
done
rm -f *.vsix
rm -f vsix_list.txt

echo "-----------------------------------------------------------------------"
echo "Setting up oh-my-zsh shell"
echo "-----------------------------------------------------------------------"

if [ ! -f "${HOMEDIR}/.p10k.zsh" ]; then
  cp /etc/skel/.p10k.zsh "${HOMEDIR}/.p10k.zsh"
else
  echo "-----------------------------------------------------"
  echo "You have an existing .p10k.zsh file. Do you want to"
  echo "replace it with the recommended version for this docker"
  echo "container (y/n)?"
  echo "-----------------------------------------------------"
  read overwrite
  if [ "${overwrite}" == "y" ]; then
    \cp /etc/skel/.p10k.zsh "${HOMEDIR}/.p10k.zsh"
  fi
fi

if [ ! -d "${HOMEDIR}/.oh-my-zsh" ]; then
  cp -r /etc/skel/.oh-my-zsh "${HOMEDIR}/.oh-my-zsh"
else
  echo "-----------------------------------------------------"
  echo "You have an existing .oh-my-zsh directory. Do you"
  echo "want to replace it with the recommended version for"
  echo "this docker container (y/n)?"
  echo "-----------------------------------------------------"
  read overwrite
  if [ "${overwrite}" == "y" ]; then
    \cp -r /etc/skel/.oh-my-zsh "${HOMEDIR}/.oh-my-zsh"
  fi
fi

if [ ! -f "${HOMEDIR}/.zshrc" ]; then
  cp /etc/skel/.zshrc "${HOMEDIR}/.zshrc"
  source ~/.zshrc 2>/dev/null
else
  echo "---------------------------------------------------"
  echo "You have an existing .zshrc file. Do you want to"
  echo "with the recommended version for this docker"
  echo "container (y/n)?"
  echo "---------------------------------------------------"
  read overwrite
  if [ "${overwrite}" == "y" ]; then
    \cp /etc/skel/.zshrc "${HOMEDIR}/.zshrc"
    source ~/.zshrc 2>/dev/null
  fi
fi

echo "-----------------------------------------------------------------------"
echo "Setup complete"
echo "-----------------------------------------------------------------------"
