#!/bin/bash
set -e

## adapted from
# https://github.com/rocker-org/rocker-versioned2/blob/master/scripts/install_tidyverse.sh

## base R-repo
# CRAN=${CRAN:-https://cran.r-project.org}

# ##  mechanism to force source installs if we're using RSPM
# UBUNTU_VERSION=${UBUNTU_VERSION:-$(lsb_release -sc)}
# CRAN_SOURCE=${CRAN/"__linux__/$UBUNTU_VERSION/"/""}

# ## source install if using RSPM and arm64 image
# if [ "$(uname -m)" = "aarch64" ]; then
#     CRAN=$CRAN_SOURCE
# fi

# ## Set some environment variables
# R_HOME=${R_HOME:-/opt/conda/lib/R}

## Set HTTPUserAgent for RSPM (https://github.com/rocker-org/rocker/issues/400)
# echo  'options(HTTPUserAgent = sprintf("R/%s R (%s)", getRversion(),
#                  paste(getRversion(), R.version$platform,
#                  R.version$arch, R.version$os)))' >> ${R_HOME}/etc/Rprofile.site

## Fix library path
echo "R_LIBS_USER='~/.rsm-msba/R/'" >> ${R_HOME}/etc/Renviron.site
# echo "R_LIBS=\${R_LIBS-'${R_HOME}/site-library:${R_HOME}/library'}" >> ${R_HOME}/etc/Renviron.site
# echo ".First <- function() {.libPaths(c('${R_LIBS_USER}, .libPaths()))}" >> ${R_HOME}/etc/Rprofile.site

## dplyr database backends
# NCPUS=${NCPUS:--1}
# Rscript -e "install.packages(c('RPostgres', 'RSQLite'), repos='${CRAN}', Ncpus=${NCPUS})"
# Rscript -e "install.packages(c('gert', 'usethis'), repos='${CRAN}', Ncpus=${NCPUS})"
# RUN Rscript -e "install.packages('RSQLite', type='source', repos='${RSPM}', Ncpus=4)"
# RUN Rscript -e "install.packages('gert', type='source', repos='${RSPM}', Ncpus=4)"
# RUN Rscript -e "install.packages('usethis', type='source', repos='${RSPM}', Ncpus=4)"
# RUN Rscript -e "install.packages('renv', type='source', repos='${RSPM}', Ncpus=4)"
# RUN Rscript -e "install.packages('usethis', Ncpus=4)"
        # 'RSQLite', 'gert', 'usethis', remotes', 'renv', 'languageserver', 'formatR'), Ncpus=4)" \
        # -e "remotes::install_github('radiant-rstats/radiant.update', upgrade = 'never')" 

# RUN echo "R_LIBS_USER='${R_LIBS_USER}'" >> ${R_HOME}/etc/Renviron.site
# RUN Rscript -e "install.packages(c('RPostgres', 'RSQLite', 'gert', 'usethis', remotes', 'renv', 'languageserver', 'formatR'), Ncpus=4)" \

# rm -rf /tmp/downloaded_packages

#!/bin/bash

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