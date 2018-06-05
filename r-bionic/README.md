Dockerized Shiny-server and Rstudio-server - Ubuntu 18.04 (Bionic)
====================================================================

This repo contains the configuration to setup Rstudio-server and Shiny-server in a Docker container

## Install docker

* For Mac: https://docs.docker.com/docker-for-mac/
* For Windows: https://docs.docker.com/docker-for-windows/
* For Linux: https://docs.docker.com/engine/installation/

After installing Docker check that it is running by typing `docker --version` in a terminal which should return something like the below:

```bash
docker --version
Docker version 18.03.1-ce, build 9ee9f40
```

## Building on this container

To build a new container based on `r-bionic` add the following at the top of your Dockerfile

```sh
FROM vnijs:r-bionic
```

## Building the container

Use the terminal to change the working directory to the location where you cloned the repo and change the working directory to `r-bionic`. Then build the docker image using:

```sh
docker build -t $USER/r-bionic .
```

## General docker related commands

Check the disk space used by docker images

```bash
docker ps -s
```

```bash
docker system df
```

On mac you can use the commands below to push your custom image to docker hub:

```bash
sudo docker login 
docker push $USER/r-bionic
```

## Trademarks

Shiny and Shiny Server are registered trademarks of RStudio, Inc. The use of the trademarked terms Shiny and Shiny Server and the distribution of the Shiny Server through the images hosted on hub.docker.com has been granted by explicit permission of RStudio. Please review RStudio's trademark use policy and address inquiries about further distribution or other questions to permissions@rstudio.com.
