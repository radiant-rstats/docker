#!/usr/bin/env bash

## setup for docker
sudo apt-get update
sudo apt-get install \
  apt-transport-https \
  ca-certificates \
  curl \
  software-properties-common \
  wget

curl -fsSL https://download.docker.com/linux/debian/gpg | sudo apt-key add -
sudo add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/debian \
   $(lsb_release -cs) \
   stable"

sudo apt-get update
sudo apt-get install docker-ce

sudo groupadd docker
sudo usermod -aG docker $USER
newgrp docker

## cloning the docker repo
git clone https://github.com/radiant-rstats/docker.git ~/git/docker;

## creating a shortcut to launch the docker container
ln -s ~/git/docker/launch-rsm-msba-spark.sh /usr/local/bin/launch;
