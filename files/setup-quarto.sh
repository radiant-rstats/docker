#!/bin/bash

## Adapted from https://github.com/rocker-org/rocker-versioned2/blob/master/scripts/install_quarto.sh

set -e

## build ARGs
NCPUS=${NCPUS:--1}

##  mechanism to force source installs if we're using RSPM
CRAN=${CRAN:-https://cran.r-project.org}
CRAN_SOURCE=${CRAN/"__linux__/$UBUNTU_VERSION/"/""}

if [ "$(uname -m)" != "aarch64" ]; then
    ln -fs /usr/lib/rstudio-server/bin/quarto/bin/quarto /usr/local/bin
else
    CRAN=$CRAN_SOURCE
    git clone https://github.com/quarto-dev/quarto-cli
    cd quarto-cli
    git checkout b064bec1efe7af4e3332c74f699686480baead12
    ./configure-linux.sh
fi

quarto check install

# Get R packages
/usr/local/bin/R -e "install.packages('quarto'), repo='${CRAN}', Ncpus=${NCPUS})" \

# Clean up
rm -rf /var/lib/apt/lists/*
rm -rf /tmp/downloaded_packages