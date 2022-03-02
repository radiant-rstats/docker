#!/bin/bash
set -e

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
    git

rm -rf /var/lib/apt/lists/*

install2.r --error --skipinstalled -n $NCPUS \
    radiant \
    gitgadget \
    miniUI \
    webshot \
    tinytex \
    svglite \
    remotes \
    formatR \
    reticulate

R --quiet -e 'remotes::install_github("radiant-rstats/radiant.update", upgrade = "never")' \
  -e 'remotes::install_github("vnijs/DiagrammeR", upgrade = "never")' \
  -e "remotes::install_github('vnijs/gitgadget')" \
  -e "devtools::install_github('IRkernel/IRkernel')"  \
  -e "devtools::install_github('IRkernel/IRdisplay')" \
  -e "IRkernel::installspec(user=FALSE)"

rm -rf /tmp/downloaded_packages