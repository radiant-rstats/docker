Dockerized Business Analytics
==================================

This repo contains information to setup a docker image with R, Rstudio, Shiny, [Radiant](https://radiant-rstats/radiant), Python, Postgres, JupyterLab, and Spark

## Install Docker

To use the docker images you first need to install Docker

* For Mac (M1): https://desktop.docker.com/mac/stable/arm64/Docker.dmg
* For Mac (Intel): https://desktop.docker.com/mac/stable/amd64/Docker.dmg
* For Windows: https://desktop.docker.com/win/main/amd64/Docker%20Desktop%20Installer.exe

After installing Docker, check that it is running by typing `docker --version` in a terminal. This should return something like the below:

```bash
docker --version
Docker version 20.10.13, build a224086
```

* For detailed install instructions on Windows see [install/rsm-msba-windows.md](install/rsm-msba-windows.md)
* For detailed install instructions on macOS (M1) see [install/rsm-msba-macos-m1.md](install/rsm-msba-macos-m1.md)
* For detailed install instructions on macOS (Intel) see [install/rsm-msba-macos.md](install/rsm-msba-macos.md)
* For detailed install instructions on Linux see [install/rsm-msba-linux.md](install/rsm-msba-linux.md)
* For detailed install instructions on ChromeOS see [install/rsm-msba-chromeos.md](install/rsm-msba-chromeos.md)

## rsm-msba-arm and rsm-msba-intel

`rsm-msba-arm` is built for M1, ARM based macOS computers. `rsm-msba-intel` is built for AMD based computers and includes Rstudio Server. To build a new image based on `rsm-jupter-rs` add the following at the top of your Dockerfile

```
FROM vnijs/rsm-msba-intel:latest
```

## rsm-msba-intel-jupyterhub

This image builds on rsm-msba-intel and is set up to be accessible from a server running jupyter hub.

## Trouble shooting

To stop (all) running containers use:

```bash
docker kill $(docker ps -q)
```

If the build fails for some reason you can access the container through the bash shell using to investigate what went wrong:

```sh
docker run -t -i $USER/rsm-upyter-rs /bin/bash
```

To remove an existing image use:

```sh
docker rmi --force $USER/rsm-msba-spark
```

To remove stop all running containers, remove unused images, and errand docker processes use the `dclean.sh` script

```sh
./scripts/dclean.sh
```

## General docker related commands

Check the disk space used by docker images

```bash
docker ps -s
```

```bash
docker system df
```

## Previous versions of the RSM computing environment

To see the documentation and configuration files for versions prior to 2.0 see <a href="https://github.com/radiant-rstats/docker/tree/docker1.0" target="_blank">docker1.0</a>

<!--
## Future development

1.  Each docker image should have its own Github repository
2.  Each of those repositories should be linked to a corresponding Dockerhub repository (these Dockerhub repositories can be part of an _organization_) which will run automated builds every time a change is pushed to the Dockerfile in the Github repository
3.  Each repository will have different branches, and the branch names will correspond to the docker image tags. Automated build rules in Dockerhub can be specified to use the Github repository branch names for the corresponding image tags.
-->

## Trademarks

Shiny is registered trademarks of RStudio, Inc. The use of the trademarked terms Shiny through the images hosted on hub.docker.com has been granted by explicit permission of RStudio. Please review RStudio's trademark use policy and address inquiries about further distribution or other questions to permissions@rstudio.com.

Jupyter is distributed under the BSD 3-Clause license (Copyright (c) 2017, Project Jupyter Contributors)

## Acknowledgements

Thanks to Ajar Vashisth for helping me get started with Docker and Docker Compose. Thanks also to Raghav Prasad for setting up the > 2.0.0 versions of the docker images to start from <a href="https://github.com/jupyter/docker-stacks" target="_blank">Jupyter</a> docker images.
