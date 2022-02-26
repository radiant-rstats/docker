#!/bin/bash
set -e

## adapted from
# https://github.com/rocker-org/rocker-versioned2/blob/master/scripts/install_tidyverse.sh

## Fix library path
echo "R_LIBS_USER='~/.rsm-msba/R/'" >> ${R_HOME}/etc/Renviron.site

## build ARGs
NCPUS=${NCPUS:--1}

apt-get update -qq && apt-get -y --no-install-recommends install \
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
    unixodbc-dev && \
  rm -rf /var/lib/apt/lists/*

install2.r --error --skipinstalled -n $NCPUS \
    tidyverse \
    devtools \
    rmarkdown \
    vroom \
    gert

## dplyr database backends
install2.r --error --skipmissing --skipinstalled -n $NCPUS \
    dbplyr \
    DBI \
    dtplyr \
    RPostgres \
    RSQLite \
    fst

## a bridge to far? -- brings in another 60 packages
# install2.r --error --skipinstalled -n $NCPUS tidymodels

 rm -rf /tmp/downloaded_packages