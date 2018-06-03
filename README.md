Dockerized Business Analytics
==================================

This repo contains information to setup a dockerized instance with R, Rstudio, Shiny, [Radiant](https://radiant-rstats/radiant), Python, and JupyterLab 

## Install Docker

To use the docker images you first need to install Docker

* For Mac: https://docs.docker.com/docker-for-mac/
* For Windows: https://docs.docker.com/docker-for-windows/
* For Linux: https://docs.docker.com/engine/installation/

After installing Docker, check that it is running by typing `docker --version` in a terminal. This should return something like the below:

```bash
docker --version
Docker version 18.03.1-ce, build 9ee9f40
```

The full `rsm-msba` setup uses Docker Compose so also check this is available by typing `docker-compose --version` in a terminal. This should return something like the below:

```bash
docker-compose --version
docker-compose version 1.21.1, build 5a3f1a3
```

## TL;DR

To jump straight in and run the main application run the command below:

```bash
docker run --rm -p 80:80 -p 8787:8787 -p 8888:8888 -v ~/Desktop:/home/rstudio/Desktop -v ~/Dropbox:/home/rstudio/Dropbox vnijs/rsm-msba
```

An alternative approach is to use `docker-compose` and the command below after cloning the repo:

```bash
docker-compose -f ./rsm-msba/docker-rsm-msba.yml up
```

For more information about running the `radiant` application see [radiant/README.md](./radiant/README.md)

For more information about running the `rsm-msba` application see [rsm-msba/README.md](./rsm-msba/README.md)

## r-bionic

You probably don't want to _run_ this image by itself. It is used in the radiant and rsm-msba application (see below).

The first image contains R, Rstudio-sever, and Shiny-server. To build a new container based on `r-bionic` add the following at the top of your Dockerfile

```
FROM vnijs:docker-bionic
```

To build r-bionic yourself use:

```sh
docker build -t $USER/r-bionic ./r-bionic
```

Push to docker hub:

```bash
sudo docker login 
docker push $USER/r-bionic
```

## radiant

The second image builds on r-bionic and adds [radiant](https://github.com/radiant-rstats/radiant) and required R-packages. 


To build a new container based on `radiant` add the following at the top of your Dockerfile

```
FROM vnijs:radiant
```

To build radiant yourself use:

```sh
docker build -t $USER/radiant ./radiant
```

Push to docker hub:

```bash
sudo docker login 
docker push $USER/radiant
```

## rsm-msba

The third image builds on the radiant image and adds python and Jupyter. To build a new container based on `rsm-msba` add the following at the top of your Dockerfile

```
FROM vnijs:rsm-msba
```

To build rsm-msba yourself use:

```sh
docker build -t $USER/rsm-msba ./rsm-msba
```

Push to docker hub:

```bash
sudo docker login 
docker push $USER/rsm-msba
```

The rsm-msba directory also contains a docker-compose file that pulls in a postgres image and database admin tool adminer. To run the full application use the command below. 

```sh
docker-compose -f ./rsm-msba/docker-compose.yml up
```

## Trouble shooting 

To stop (all) running containers use:

```bash
docker kill $(docker ps -q)
```

If the build fails for some reason you can access the container through the bash shell using to investigate what went wrong:

```sh
docker run -t -i $USER/rsm-msba /bin/bash
```

To remove an existing image use:

```sh
docker rmi --force $USER/rsm-msba
```

To remove stop all running containers, remove unused images, and errand docker processes use the `dclean.sh` script

```sh
./dclean.sh
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
docker push $USER/rsm-msba
```

## Trademarks

Shiny and Shiny Server are registered trademarks of RStudio, Inc. The use of the trademarked terms Shiny and Shiny Server and the distribution of the Shiny Server through the images hosted on hub.docker.com has been granted by explicit permission of RStudio. Please review RStudio's trademark use policy and address inquiries about further distribution or other questions to permissions@rstudio.com.

Jupyter is distributed under the BSD 3-Clause license (Copyright (c) 2017, Project Jupyter Contributors)

## Acknowledgements

Thanks to Ajar Vashisth for helping me get started with Docker and Docker Compose 
