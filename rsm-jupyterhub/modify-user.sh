#!/bin/bash
NB_USER=$1
NB_UID=$2
user_exists=$(id -u $NB_USER > /dev/null 2>&1; echo $?)

groupadd $NB_USER
if [ $user_exists -eq 0 ]; then
   usermod -s /bin/bash -u $NB_UID $NB_USER
else
   useradd -m -s /bin/bash -u $NB_UID $NB_USER
fi

usermod -a -G $NB_USER $NB_USER
