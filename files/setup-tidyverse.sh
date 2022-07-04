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

export DEBIAN_FRONTEND=noninteractive
apt-get update -qq \
    && apt-get -y --no-install-recommends install \
    libxml2-dev \
    libcairo2-dev \
    libgit2-dev \
    libpq-dev \
    libsasl2-dev \
    libsqlite3-dev \
    libssh2-1-dev \
    libxtst6 \
    libcurl4-openssl-dev \
    libssl-dev \
    unixodbc-dev \
    && rm -rf /var/lib/apt/lists/*

/usr/local/bin/R -e "install.packages(c('tidyverse', 'devtools', 'rmarkdown', 'vroom', 'gert', 'usethis'), repo='${CRAN}', Ncpus=${NCPUS})" \
  -e "install.packages(c('dbplyr', 'DBI', 'dtplyr', 'RPostgres', 'RSQLite', 'fst'), repo='${CRAN}', Ncpus=${NCPUS})"

## a bridge to far? -- brings in another 60 packages
# install2.r --error --skipinstalled -n $NCPUS tidymodels

 rm -rf /tmp/downloaded_packages