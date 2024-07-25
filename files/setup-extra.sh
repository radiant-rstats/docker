#!/bin/bash
set -e

UBUNTU_VERSION=${UBUNTU_VERSION:-`lsb_release -sc`}
CRAN=${CRAN:-https://cran.r-project.org}

##  mechanism to force source installs if we're using RSPM
CRAN_SOURCE=${CRAN/"__linux__/$UBUNTU_VERSION/"/""}

## source install if using RSPM and arm64 image
if [ "$(uname -m)" = "aarch64" ]; then
  CRAN=https://cran.r-project.org
  CRAN_SOURCE=${CRAN/"__linux__/$UBUNTU_VERSION/"/""}
  CRAN=$CRAN_SOURCE
fi

NCPUS=${NCPUS:--1}

if [ -f "/opt/conda/bin/R" ]; then
  if [ "$(uname -m)" == "aarch64" ]; then
    mamba install --quiet --yes -c conda-forge \
      r-raster \
      imagemagick \
      libgdal

      # R -e "install.packages('rgdal', repo='${CRAN}', Ncpus=${NCPUS})"
  else
    mamba install --quiet --yes -c conda-forge \
      r-raster \
      imagemagick \
      libgdal \
      r-rgdal
  fi
else
  export DEBIAN_FRONTEND=noninteractive
  apt-get update -qq && apt-get -y install \
    libcurl4-openssl-dev \
    libssl-dev \
    imagemagick \
    libmagick++-dev \
    gsfonts \
    libpng-dev \
    libgdal-dev \
    gdal-bin \
    libgeos-dev \
    libproj-dev \
    libicu-dev \
    && rm -rf /var/lib/apt/lists/*

  # R -e "install.packages('rgdal', repo='${CRAN}', Ncpus=${NCPUS})"
fi

# R -e "install.packages(c('magick', 'leaflet', 'stringi', 'profvis'), repo='${CRAN}', Ncpus=${NCPUS})"
R -e "install.packages('devtools', repo='${CRAN}', Ncpus=${NCPUS})" \
  -e "remotes::install_github('vnijs/webshot', upgrade = 'never')" \
  -e "webshot::install_phantomjs()"
  # -e "install.packages(c('tidytext', 'wordcloud'), repo='${CRAN}', Ncpus=${NCPUS})"

# for Machine Learning with PyTorch and Scikit-Learn
mamba install --quiet --yes -c conda-forge pytorch-lightning tensorboard zip

rm -rf /tmp/downloaded_packages