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
  mamba install --quiet --yes -c conda-forge snappy cmake
else
  export DEBIAN_FRONTEND=noninteractive
  apt-get update -qq && apt-get -y --no-install-recommends install \
      libicu-dev \
      zlib1g-dev \
      libglpk-dev \
      libgmp3-dev \
      libxml2-dev \
      cmake \
      git \
      libharfbuzz-dev \
      libfribidi-dev \
      libfreetype6-dev \
      libpng-dev \
      libtiff5-dev \
      libjpeg-dev \
      libcurl4-openssl-dev \
      && rm -rf /var/lib/apt/lists/*
fi

R -e "install.packages('igraph', repo='${CRAN}', Ncpus=${NCPUS})" \
  -e "install.packages(c('radiant', 'png', 'bslib', 'gitgadget', 'miniUI', 'webshot', 'tinytex', 'svglite'), repo='${CRAN}', Ncpus=${NCPUS})" \
  -e "install.packages(c('remotes', 'formatR', 'styler', 'reticulate', 'renv'), repo='${CRAN}', Ncpus=${NCPUS})" \
  -e "install.packages(c('fs', 'janitor', 'dm', 'palmerpenguins', 'stringr', 'tictoc'), repo='${CRAN}', Ncpus=${NCPUS})" \
  -e "install.packages(c('httpgd', 'languageserver'), repo='${CRAN}', Ncpus=${NCPUS})" \
  -e "remotes::install_github('radiant-rstats/radiant.update', upgrade = 'never')" \
  -e "remotes::install_github('vnijs/gitgadget', upgrade = 'never')" \
  -e "remotes::install_github('IRkernel/IRkernel', upgrade = 'never')"  \
  -e "remotes::install_github('IRkernel/IRdisplay', upgrade = 'never')" \
  -e "IRkernel::installspec(user=FALSE)" \
  -e "remotes::install_github('radiant-rstats/radiant.data', upgrade = 'never')" \
  -e "remotes::install_github('radiant-rstats/radiant.design', upgrade = 'never')" \
  -e "remotes::install_github('radiant-rstats/radiant.basics', upgrade = 'never')" \
  -e "remotes::install_github('radiant-rstats/radiant.model', upgrade = 'never')" \
  -e "remotes::install_github('radiant-rstats/radiant.multivariate', upgrade = 'never')" \
  -e "remotes::install_github('radiant-rstats/radiant', upgrade = 'never')" \
  -e "remotes::install_github('radiant-rstats/radiant.update', upgrade = 'never')" \
  -e "Sys.setenv(ARROW_PARQUET = 'ON', ARROW_R_DEV = TRUE); install.packages(c('arrow', 'duckdb'), repo='${CRAN}', Ncpus=${NCPUS})"

  # does not work when you ARROW_WITH_SNAPPY 
  # when installed as follows, all pieces seem to work: Sys.setenv(ARROW_PARQUET='ON', ARROW_R_DEV=TRUE); install.packages('arrow')
#   > arrow::arrow_info()
# Arrow package version: 9.0.0.2

# Capabilities:

# dataset    TRUE
# substrait  TRUE
# parquet    TRUE
# json       TRUE
# s3         TRUE
# gcs        TRUE
# utf8proc   TRUE
# re2        TRUE
# snappy     TRUE
# gzip       TRUE
# brotli     TRUE
# zstd       TRUE
# lz4        TRUE
# lz4_frame  TRUE
# lzo       FALSE
# bz2        TRUE
# jemalloc   TRUE
# mimalloc   TRUE

# Memory:

# Allocator jemalloc
# Current    0 bytes
# Max        0 bytes

# Runtime:

# SIMD Level          none
# Detected SIMD Level none

# Build:

# C++ Library Version                                     9.0.0
# C++ Compiler                                              GNU
# C++ Compiler Version                                   10.4.0
# Git ID               c507b095e4d39c8430da1c0e988bf49f49a13135
  # -e "Sys.setenv(ARROW_PARQUET = 'ON', ARROW_WITH_SNAPPY = 'ON', ARROW_R_DEV = TRUE); install.packages(c('arrow', 'duckdb'), repo='${CRAN}', Ncpus=${NCPUS})"

rm -rf /tmp/downloaded_packages

# Sys.setenv(ARROW_PARQUET='ON', ARROW_WITH_SNAPPY='ON', ARROW_R_DEV=TRUE); install.packages('arrow')
# library(arrow)
# arrow_info()