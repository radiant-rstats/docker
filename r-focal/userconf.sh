#!/usr/bin/with-contenv bash

# set defaults for environmental variables in case they are undefined
NB_USER=${NB_USER:=jovyan}
PASSWORD=${PASSWORD:=jupyter}

if [[ ${DISABLE_AUTH} == "true" ]]; then
  mv /etc/rstudio/disable_auth_rserver.conf /etc/rstudio/rserver.conf
  echo "USER=$NB_USER" >> /etc/environment
fi

# add a password for user
echo "$NB_USER:$PASSWORD" | chpasswd
