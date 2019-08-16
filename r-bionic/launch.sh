#!/bin/bash

if [ -d ~/Desktop ]; then
  DIR_label="Desktop"
  DIR=~/Desktop
else 
  DIR_label="Home directory"
  DIR=~
fi

echo "-----------------------------------------------------------------------"
echo "To copy the launch script for this container to your ${DIR_label}"
echo "Press (1) to copy to a macOS host, follow by [ENTER]:"
echo "Press (2) to copy to a Windows or Linux host, follow by [ENTER]:"
echo "-----------------------------------------------------------------------"
read menu_exec

if [ ${menu_exec} == 1 ]; then
  cp -p -i /opt/launch.sh ${DIR}/launch.command
else
  cp -p -i /opt/launch.sh ${DIR}/launch.sh
fi
