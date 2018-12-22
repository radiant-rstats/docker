#!/usr/bin/with-contenv bash

## Set defaults for environmental variables in case they are undefined
NB_USER=${NB_USER:=jovyan}
RPASSWORD=${RPASSWORD:=rstudio}

## Add a password to user
echo "$NB_USER:$RPASSWORD" | chpasswd
