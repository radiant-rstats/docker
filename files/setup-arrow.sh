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

R -e "Sys.setenv(ARROW_PARQUET = 'ON', ARROW_WITH_SNAPPY = 'ON', ARROW_R_DEV = TRUE); install.packages('arrow', repo='${CRAN}', Ncpus=${NCPUS})"

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

# Sys.setenv(ARROW_PARQUET='ON', ARROW_WITH_SNAPPY='ON', ARROW_R_DEV=TRUE); install.packages('arrow')
# library(arrow)
# arrow_info()