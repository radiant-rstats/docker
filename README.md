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

On windows please install Git Bash:

http://www.techoism.com/how-to-install-git-bash-on-windows/

For detailed install instructions on Windows see [install/rsm-msba-windows.md](install/rsm-msba-windows.md)

For detailed install instructions on macOS see [install/rsm-msba-macos.md](install/rsm-msba-macos.md)

## TL;DR

To jump straight in and run the main application run the command below on macOS:

```bash
docker run --rm -p 80:80 -p 8787:8787 -p 8888:8888 -v ~:/home/rstudio vnijs/rsm-msba
```

For Windows run the command below:

```bash
docker run --rm -p 80:80 -p 8787:8787 -p 8888:8888 -v c:/Users/$USERNAME:/home/rstudio vnijs/rsm-msba
```

Perhaps even easier, you can start the `rsm-msba` container on macOS using `launch-mac.command` and on Windows using `launch-windows.sh`. To get these files download the repo https://github.com/radiant-rstats/docker or clone the repo using `git clone https://github.com/radiant-rstats/docker.git` is you have git installed. To run the script on Windows you will need [Git Bash installed](https://github.com/git-for-windows/git/releases/download/v2.18.0.windows.1/Git-2.18.0-64-bit.exe)
 as referenced above.

Another alternative approach is to use `docker-compose` and the command below after cloning the repo:

```bash
docker-compose -f ./rsm-msba/docker-rsm-msba.yml up
```

Note: For Windows you may need to change the path in the `volumes:` section to `c:/Users/$USERNAME`

For more information about running the `radiant` application see [radiant/README.md](./radiant/README.md)

For more information about running the `rsm-msba` application see [rsm-msba/README.md](./rsm-msba/README.md)

## r-bionic

You probably don't want to _run_ this image by itself. It is used in the `radiant` and `rsm-msba` application (see below). To build a new container based on `r-bionic` add the following at the top of your Dockerfile

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

The second image builds on `r-bionic` and adds [radiant](https://github.com/radiant-rstats/radiant) and required R-packages. To build a new container based on `radiant` add the following at the top of your Dockerfile

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

Add the following to .Rprofile in your home directory

```r
options(radiant.ace_vim.keys = FALSE)
options(radiant.maxRequestSize = -1)
# options(radiant.maxRequestSize = 10 * 1024^2)
options(radiant.report = TRUE)
# options(radiant.ace_theme = "cobalt")
options(radiant.ace_theme = "tomorrow")
# options(radiant.ace_showInvisibles = TRUE)
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
docker-compose -f ./rsm-msba/docker-rsm-msba.yml up
```

## Installing R-packages

If you want to install an R-package, e.g., `fortune`, in a way that persists when using the container again, use the command below. This will install the package and create a personal directory for future package installs. You will only need to add the `lib = Sys.getenv("R_LIBS_USER")` argument once to generate the personal directory.

```
install.packages("fortunes", lib = Sys.getenv("R_LIBS_USER"))
```

## Installing Python packages

If you want to install a python package, e.g., `redis`, in a way that persists when using the container again, use the command below from the Jupyter (or Rstudio) terminal. This will install the package and create a personal directory for future package installs.

```
pip3 install -U "redis"
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

Add the following to .Rprofile in your home directory

```r
options(radiant.ace_vim.keys = FALSE)
options(radiant.maxRequestSize = -1)
# options(radiant.maxRequestSize = 10 * 1024^2)
options(radiant.report = TRUE)
# options(radiant.ace_theme = "cobalt")
options(radiant.ace_theme = "tomorrow")
# options(radiant.ace_showInvisibles = TRUE)
```

## Trademarks

Shiny and Shiny Server are registered trademarks of RStudio, Inc. The use of the trademarked terms Shiny and Shiny Server and the distribution of the Shiny Server through the images hosted on hub.docker.com has been granted by explicit permission of RStudio. Please review RStudio's trademark use policy and address inquiries about further distribution or other questions to permissions@rstudio.com.

Jupyter is distributed under the BSD 3-Clause license (Copyright (c) 2017, Project Jupyter Contributors)

## Acknowledgements

Thanks to Ajar Vashisth for helping me get started with Docker and Docker Compose 
