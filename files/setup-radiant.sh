#!/bin/bash
set -e

export DEBIAN_FRONTEND=noninteractive

## build ARGs
NCPUS=${NCPUS:--1}

apt-get update -qq && apt-get -y --no-install-recommends install \
    libicu-dev \
    pandoc \
    zlib1g-dev \
    libglpk-dev \
    libgmp3-dev \
    libxml2-dev \
    cmake \
    git \ 
    && rm -rf /var/lib/apt/lists/*

R -e "install.packages('radiant', 'gitgadget', 'miniUI', 'webshot', 'tinytex', 'svglite', 'remotes', 'formatR', 'reticulate', Ncpus=${NCPUS}))"
  -e 'remotes::install_github("radiant-rstats/radiant.update", upgrade = "never")' \
  -e 'remotes::install_github("vnijs/DiagrammeR", upgrade = "never")' \
  -e "remotes::install_github('vnijs/gitgadget')" \
  -e "devtools::install_github('IRkernel/IRkernel')"  \
  -e "devtools::install_github('IRkernel/IRdisplay')" \
  -e "IRkernel::installspec(user=FALSE)"

rm -rf /tmp/downloaded_packages