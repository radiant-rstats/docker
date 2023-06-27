#!/bin/bash
set -e

## adapted from
# https://github.com/rocker-org/rocker-versioned2/blob/master/scripts/install_tidyverse.sh

UBUNTU_VERSION=${UBUNTU_VERSION:-`lsb_release -sc`}
CRAN=${CRAN:-https://cran.r-project.org}

##  mechanism to force source installs if we're using RSPM
CRAN_SOURCE=${CRAN/"__linux__/$UBUNTU_VERSION/"/""}

## source install if using RSPM and arm64 image
if [ "$(uname -m)" = "aarch64" ]; then
  CRAN=$CRAN_SOURCE
fi

NCPUS=${NCPUS:--1}

# if [ -f "/opt/conda/bin/R" ]; then
#   export DEBIAN_FRONTEND=noninteractive
#   apt-get update -qq \
#       && apt-get -y --no-install-recommends install \
#       libxml2-dev \
#       libcairo2-dev \
#       libgit2-dev \
#       libpq-dev \
#       libsasl2-dev \
#       libsqlite3-dev \
#       libssh2-1-dev \
#       libxtst6 \
#       libcurl4-openssl-dev \
#       libssl-dev \
#       unixodbc-dev \
#       libharfbuzz-dev \
#       libfribidi-dev \
#       libfreetype6-dev \
#       libpng-dev \
#       libtiff5-dev \
#       libjpeg-dev \
#       && rm -rf /var/lib/apt/lists/*
# fi

R -e "install.packages(c('ragg', 'rlist'), repo='${CRAN}', Ncpus=${NCPUS})" \
  -e "install.packages(c('tidyverse', 'rmarkdown', 'gert', 'usethis'), repo='${CRAN}', Ncpus=${NCPUS})" \
  -e "install.packages(c('dbplyr', 'DBI', 'dtplyr', 'RPostgres', 'RSQLite'), repo='${CRAN}', Ncpus=${NCPUS})"

rm -rf /tmp/downloaded_packages