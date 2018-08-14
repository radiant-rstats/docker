#!/bin/bash

## script to start Radiant, Rstudio, and JupyterLab on a remote
## server
## call script with ./ssh/launch-ssh.sh myid@123.123.123.123
## where myid is your userid and 123.... is the ip address of
## the server
## in the example below "mac" is set in ~/.ssh/config as a shortcut
## to myid@123.123.123.123

UHOST={$1:-mac}

clear

## what os is being used
ostype=`uname`
## function is not efficient by alias has scopping issues
if [[ "$ostype" == "Linux" ]]; then
  open_browser () {
    xdg-open $1
  }
elif [[ "$ostype" == "Darwin" ]]; then
  open_browser () {
    open $1
  }
else
  open_browser () {
    start $1
  }
fi

## make connection to host running docker trough ssh
ssh -M -S .tmp-ssh-info -fnNT -L 8080:localhost:8080 -L 8787:localhost:8787 -L 8989:localhost:8989 ${UHOST}

show_service () {
  echo "---------------------------------------------------------------------"
  echo "Press (1) to show Radiant, followed by [ENTER]:"
  echo "Press (2) to show Rstudio, followed by [ENTER]:"
  echo "Press (3) to show Jupyter Lab, followed by [ENTER]:"
  echo "Press (q) to stop the docker process, followed by [ENTER]:"
  echo "---------------------------------------------------------------------"
  read startup

  if [ ${startup} == 1 ]; then
    echo "Starting Radiant in the default browser on port 8080"
    open_browser http://localhost:8080
  elif [ ${startup} == 2 ]; then
    echo "Starting Rstudio in the default browser on port 8787"
    open_browser http://localhost:8787
  elif [ ${startup} == 3 ]; then
    echo "Starting Jupyter Lab in the default browser on port 8989"
    open_browser http://localhost:8989/lab
  elif [ "${startup}" == "q" ]; then
    ssh -S .tmp-ssh-info -O exit ${UHOST}
    echo "---------------------------------------------------------------------"
    echo "Stopping ssh connection"
    echo "---------------------------------------------------------------------"
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
