Dockerized Business Analytics for RSM MSBA with SPARK
======================================================

This repo contains information to setup a dockerized instance of R, Rstudio, Shiny, [Radiant](https://radiant-rstats/radiant), Python, JupyterLab, Postgres, Spark, Bash, and VS Code (code-server)

## Install docker

* For Mac: https://docs.docker.com/docker-for-mac/
* For Windows: https://docs.docker.com/docker-for-windows/
* For Linux: https://docs.docker.com/engine/installation/

After installing Docker check that it is running by typing `docker --version` in a terminal which should return something like the below:

```bash
docker --version
Docker version 18.06.0-ce, build 0ffa825
```

## Run from the Docker Hub image

To start all applications in a temporary container use the command below. To map local drives to Rstudio use the `-v` option. For example, the command below would map your home directory the home directory used for Rstudio

```bash
docker run --rm -p 8080:80 -p 8787:8787 -p 8989:8888 -p 8765:8765 \
  -v ~:/home/jovyan vnijs/rsm-msba-spark
```

An alternative approach is to use `docker-compose` and the command below after cloning this repo:

```bash
docker-compose -f ./rsm-msba-spark/docker-rsm-msba-spark.yml up
```

The radiant app will be available at <a href="http://127.0.0.1:8080" target="_blank">http://127.0.0.1:8080</a>,  Rstudio will be available at <a href="http://127.0.0.1:8787" target="_blank">http://127.0.0.1:8787</a>, and JupyterLab will be available at 
<a href="http://127.0.0.1:8989" target="_blank">http://127.0.0.1:8989</a>

The user id is `jovyan` and password for Rstudio is `rstudio`. For JupyterLab use `jupyter`.

To stop a running container use `CTRL+C`. In a real deployment scenario, you will probably want to run the container in detached mode (`-d`):

```bash
docker run -d -p 8080:80 -p 8787:8787 -p 8989:8888 -p 8765:8765 \
  -v ~:/home/jovyan vnijs/rsm-msba-spark
```

The rsm-msba directory also contains a docker-compose file that pulls in a postgres image and database admin tool adminer. To run the full application use the command below. 

```sh
docker-compose -f ./rsm-msba-spark/docker-rsm-msba-spark.yml up
```

Information on how to connect to postgres is available in the install instructions for the rsm-msba-spark image:

* https://github.com/radiant-rstats/docker/blob/master/install/rsm-msba-macos.md
* https://github.com/radiant-rstats/docker/blob/master/install/rsm-msba-windows.md
* https://github.com/radiant-rstats/docker/blob/master/install/rsm-msba-linux.md

For a more extensive example using R see: https://github.com/radiant-rstats/docker/blob/master/postgres/postgres-connect.md

For a more extensive example using Python see: https://github.com/radiant-rstats/docker/blob/master/postgres/postgres-connect.ipynb

## Installing R-packages

If you want to install an R-package, e.g., `fortune`, in a way that persists when using the container again, use the command below. This will install the package and create a personal directory for future package installs. You will only need to add the `lib = Sys.getenv("R_LIBS_USER")` argument once to generate the personal directory.

```
install.packages("fortunes", lib = Sys.getenv("R_LIBS_USER"))
```

## Building the container

Use the terminal to change the working directory to the location where you cloned the repo. Then build the docker image using:

```sh
docker build -t $USER/rsm-msba-spark .
```

Note that creating the container may take some time if it has to pull an updated version of vnijs/rsm-msba-spark. If the build fails for some reason you can access the container through the bash shell using to investigate what went wrong:

```sh
docker run -t -i $USER/rsm-msba-spark /bin/bash
```

## Trademarks

Shiny and Shiny Server are registered trademarks of RStudio, Inc. The use of the trademarked terms Shiny and Shiny Server and the distribution of the Shiny Server through the images hosted on hub.docker.com has been granted by explicit permission of RStudio. Please review RStudio's trademark use policy and address inquiries about further distribution or other questions to permissions@rstudio.com.

Jupyter is distributed under the BSD 3-Clause license (Copyright (c) 2017, Project Jupyter Contributors)
