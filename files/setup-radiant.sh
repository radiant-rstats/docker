#!/bin/bash
set -e

UBUNTU_VERSION=${UBUNTU_VERSION:-`lsb_release -sc`}
CRAN=${CRAN:-https://cran.r-project.org}

##  mechanism to force source installs if we're using RSPM
CRAN_SOURCE=${CRAN/"__linux__/$UBUNTU_VERSION/"/""}

## source install if using RSPM and arm64 image
if [ "$(uname -m)" = "aarch64" ]; then
  CRAN=$CRAN_SOURCE
fi

NCPUS=${NCPUS:--1}

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

R -e "install.packages('igraph', repo='${CRAN}', Ncpus=${NCPUS})" \
  -e "install.packages(c('radiant', 'png', 'bslib', 'gitgadget', 'miniUI', 'webshot', 'tinytex', 'svglite'), repo='${CRAN}', Ncpus=${NCPUS})" \
  -e "install.packages(c('devtools', 'remotes', 'formatR', 'styler', 'reticulate', 'renv'), repo='${CRAN}', Ncpus=${NCPUS})" \
  -e "install.packages(c('arrow', 'duckdb', 'fs', 'janitor', 'palmerpenguins', 'stringr', 'tictoc'), repo='${CRAN}', Ncpus=${NCPUS})" \
  -e "install.packages(c('httpgd', 'languageserver'), repo='${CRAN}', Ncpus=${NCPUS})" \
  -e "remotes::install_github('radiant-rstats/radiant.update', upgrade = 'never')" \
  -e "remotes::install_github('vnijs/gitgadget', upgrade = 'never')" \
  -e "remotes::install_github('vnijs/DiagrammeR', upgrade = 'never')" \
  -e "remotes::install_github('IRkernel/IRkernel', upgrade = 'never')"  \
  -e "remotes::install_github('IRkernel/IRdisplay', upgrade = 'never')" \
  -e "IRkernel::installspec(user=FALSE)" \
  -e "remotes::install_github('radiant-rstats/radiant.data', upgrade = 'never')" \
  -e "remotes::install_github('radiant-rstats/radiant.design', upgrade = 'never')" \
  -e "remotes::install_github('radiant-rstats/radiant.basics', upgrade = 'never')" \
  -e "remotes::install_github('radiant-rstats/radiant.model', upgrade = 'never')" \
  -e "remotes::install_github('radiant-rstats/radiant.multivariate', upgrade = 'never')"

rm -rf /tmp/downloaded_packages