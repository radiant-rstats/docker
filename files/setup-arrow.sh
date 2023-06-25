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

# R -e "Sys.setenv(ARROW_PARQUET = 'ON', ARROW_WITH_SNAPPY = 'ON', ARROW_R_DEV = TRUE); devtools::install_version('arrow', version='9.0.0.2', repos='${CRAN}', Ncpus=${NCPUS})"
# R -e "Sys.setenv(ARROW_PARQUET = 'ON', ARROW_WITH_SNAPPY = 'ON', ARROW_R_DEV = TRUE, ARROW_USE_PKG_CONFIG=TRUE); install.packages('arrow', repo='${CRAN}', Ncpus=${NCPUS})"
R -e "Sys.setenv(ARROW_PARQUET = 'ON', ARROW_WITH_SNAPPY = 'ON', ARROW_R_DEV = TRUE); devtools::install_version('arrow', version='10.0.1', repos='${CRAN}', Ncpus=${NCPUS})"

# for some reason this part needs to be at the end and does not work when combined with setup-radiant
# library(arrow)
# arrow_info()