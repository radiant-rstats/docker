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
    libharfbuzz-dev \
    libfribidi-dev \
    libfreetype6-dev \
    libpng-dev \
    libtiff5-dev \
    libjpeg-dev \
    libsnappy-dev \
    libre2-dev \
    && rm -rf /var/lib/apt/lists/*

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
  -e "if (is.null(webshot:::find_phantom())) webshot::install_phantomjs()"

# arrow install from source is not currently working on aarch64
# https://issues.apache.org/jira/projects/ARROW/issues/ARROW-17374?filter=allopenissues

if [ "$(uname -m)" != "aarch64" ]; then
  R -e "install.packages(c('duckdb', 'arrow'), repo='${CRAN}', Ncpus=${NCPUS})"
else
  # based on https://github.com/duckdb/duckdb/issues/3049#issuecomment-1096671708
  cp -a /usr/local/lib/R/etc/Makeconf /usr/local/lib/R/etc/Makeconf.bak;
  sed -i 's/fpic/fPIC/g' /usr/local/lib/R/etc/Makeconf;
  R -e "options(HTTPUserAgent = sprintf('R/%s R (%s)', getRversion(), paste(getRversion(), R.version['platform'], R.version['arch'], R.version['os']))); Sys.setenv('ARROW_R_DEV' = TRUE); install.packages(c('duckdb', 'arrow'), repo='${CRAN}', Ncpus=${NCPUS})"
  mv /usr/local/lib/R/etc/Makeconf.bak /usr/local/lib/R/etc/Makeconf;
fi

rm -rf /tmp/downloaded_packages