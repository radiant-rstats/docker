#!/usr/bin/with-contenv bash

# set defaults for environmental variables in case they are undefined
NB_USER=${NB_USER:=jovyan}
RPASSWORD=${RPASSWORD:=rstudio}

# works for jupyterlab but conflicts with rstudio on alternate port
# export JPASSWORD=${JPASSWORD:=jupyter}

# add a password for user
echo "$NB_USER:$RPASSWORD" | chpasswd
