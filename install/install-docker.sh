#!/usr/bin/env bash

sudo apt update
sudo apt install apt-transport-https \
  ca-certificates \
  curl \
  software-properties-common \
  git \
  openssh-client \
  zsh \
  ntpdate \
  python-is-python3 

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu jammy stable"
sudo apt update
apt-cache policy docker-ce
sudo apt install docker-ce
sudo systemctl status docker
sudo usermod -aG docker ${USER}
su - ${USER}
