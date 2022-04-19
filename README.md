Dockerized Business Analytics
==================================

This repo contains information to setup a docker image with R, Rstudio, Shiny, [Radiant](https://radiant-rstats/radiant), Python, Postgres, JupyterLab, and Code-Server (aka VSCode)

## Install Docker

To use the docker images you first need to install Docker

* For Mac: https://docs.docker.com/docker-for-mac/
* For Windows: https://docs.docker.com/docker-for-windows/
* For Linux: https://docs.docker.com/engine/installation/

After installing Docker, check that it is running by typing `docker --version` in a terminal. This should return something like the below:

```bash
docker --version
Docker version 18.09.2, build 6247962
```

On windows please install Git Bash:

http://www.techoism.com/how-to-install-git-bash-on-windows/

For detailed install instructions on Windows see [install/rsm-msba-windows.md](install/rsm-msba-windows.md)

For detailed install instructions on macOS see [install/rsm-msba-macos.md](install/rsm-msba-macos.md)

## r-focal

You probably don't want to _run_ this image by itself. It is used in the `radiant`, `rsm-msba-spark`, and `rsm-jupyterhub`, application (see below). To build a new container based on `r-focal` add the following at the top of your Dockerfile

```
FROM vnijs/r-focal:latest
```

To build r-focal yourself use:

```sh
docker build -t $USER/r-focal ./r-focal
```

To push to docker hub use:

```bash
sudo docker login 
docker push $USER/r-focal
```

## radiant

The second image builds on `r-focal` and adds [radiant](https://github.com/radiant-rstats/radiant) and required R-packages. To build a new container based on `radiant` add the following at the top of your Dockerfile

```
FROM vnijs/radiant:latest
```

To allow execution of R-code in _Report > Rmd_ and _Report > R_ in Radiant add the following to .Rprofile in your home directory

```r
options(radiant.ace_vim.keys = FALSE)
options(radiant.maxRequestSize = -1)
# options(radiant.maxRequestSize = 10 * 1024^2)
options(radiant.report = TRUE)
# options(radiant.shinyFiles = TRUE)
# options(radiant.ace_theme = "cobalt")
options(radiant.ace_theme = "tomorrow")
# options(radiant.ace_showInvisibles = TRUE)
```

## rsm-msba and rsm-msba-spark

The third and forth images build on the radiant image and adds python, jupyter lab, postgresql, spark, and Code-Server (aka VSCode). To build a new container based on `rsm-msba-spark` add the following at the top of your Dockerfile

```
FROM vnijs/rsm-msba-spark:latest
```

## rsm-jupyterlab

This image builds on rsm-msba-spark and is set up to be accessible from a server running jupyter hub.

## rsm-vscode

This image contains all R and Python libraries found in `rsm-msba-spark` and `rsm-jupterlab` but does not include Jupyter Lab, Shiny server, Rstudio server, or VSCode (codeserver). It is intended to be used with a local install of [VSCode](https://code.visualstudio.com/download). Once you start the container using `launch-rsm-vscode` you can use "Remote-Containers: Attach to Running Container" from VSCode to connect. Recommended extensions to use with the container are shown in the screenshot below:

![vscode extension](rsm-vscode/images/vscode-extensions.png)

## Trouble shooting

To stop (all) running containers use:

```bash
docker kill $(docker ps -q)
```

If the build fails for some reason you can access the container through the bash shell using to investigate what went wrong:

```sh
docker run -t -i $USER/rsm-msba-spark /bin/bash
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

## Future development

1.  Each docker image should have its own Github repository
2.  Each of those repositories should be linked to a corresponding Dockerhub repository (these Dockerhub repositories can be part of an _organization_) which will run automated builds every time a change is pushed to the Dockerfile in the Github repository
3.  Each repository will have different branches, and the branch names will correspond to the docker image tags. Automated build rules in Dockerhub can be specified to use the Github repository branch names for the corresponding image tags.

## Trademarks

Shiny and Shiny Server are registered trademarks of RStudio, Inc. The use of the trademarked terms Shiny and Shiny Server and the distribution of the Shiny Server through the images hosted on hub.docker.com has been granted by explicit permission of RStudio. Please review RStudio's trademark use policy and address inquiries about further distribution or other questions to permissions@rstudio.com.

Jupyter is distributed under the BSD 3-Clause license (Copyright (c) 2017, Project Jupyter Contributors)

## Acknowledgements

Thanks to Ajar Vashisth for helping me get started with Docker and Docker Compose
