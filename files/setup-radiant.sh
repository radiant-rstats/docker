#!/bin/bash
set -e

## build ARGs
NCPUS=${NCPUS:--1}

UBUNTU_VERSION=${UBUNTU_VERSION:-`lsb_release -sc`}
CRAN=${CRAN:-https://cran.r-project.org}

##  mechanism to force source installs if we're using RSPM
CRAN_SOURCE=${CRAN/"__linux__/$UBUNTU_VERSION/"/""}

## source install if using RSPM and arm64 image
if [ "$(uname -m)" = "aarch64" ]; then
  CRAN=$CRAN_SOURCE
fi

export DEBIAN_FRONTEND=noninteractive
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

/usr/local/bin/R -e "install.packages(c('radiant', 'gitgadget', 'miniUI', 'webshot', 'tinytex', 'svglite', 'remotes', 'formatR', 'reticulate'), repo='${CRAN}', Ncpus=${NCPUS})" \
  -e 'remotes::install_github("radiant-rstats/radiant.update", upgrade = "never")' \
  -e 'remotes::install_github("vnijs/DiagrammeR", upgrade = "never")' \
  -e "remotes::install_github('vnijs/gitgadget')" \
  -e "devtools::install_github('IRkernel/IRkernel')"  \
  -e "devtools::install_github('IRkernel/IRdisplay')" \
  -e "IRkernel::installspec(user=FALSE)"

rm -rf /tmp/downloaded_packages