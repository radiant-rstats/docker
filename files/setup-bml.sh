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

R -e "install.packages(c('cmdstanr', 'posterior', 'bayesplot'), repo='${CRAN}', Ncpus=${NCPUS})" \

rm -rf /tmp/downloaded_packages