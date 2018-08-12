#!/bin/bash

apt-get update 
apt-get -y upgrade \
apt-get install -y --no-install-recommends \
    bash-completion \
    ca-certificates \
    file \
    fonts-texgyre \
    g++ \
    gfortran \
    gsfonts \
    libblas-dev \
    libbz2-1.0 \
    libcurl3 \
    libopenblas-dev \
    libpangocairo-1.0-0 \
    libpcre3 \
    libpng16-16 \
    libreadline7 \
    libtiff5 \
    liblzma5 \
    locales \
    make \
    unzip \
    zip \
    zlib1g \
    wget \
    software-properties-common
add-apt-repository --enable-source --yes "ppa:marutter/rrutter3.5" 
add-apt-repository --enable-source --yes "ppa:marutter/c2d4u3.5" 
apt-get update

apt-get -y install --no-install-recommends \
  apt-transport-https \
  gdebi-core \
  libapparmor1 \
  libcurl4-openssl-dev \
  libopenmpi-dev \
  libpq-dev \
  libssh2-1-dev \
  libssl-dev \
  libxml2 \
  libxml2-dev \
  unixodbc-dev \
  libicu-dev \
  r-base \
  r-base-dev \
  r-cran-rcpp \
  r-cran-pbdzmq \
  r-cran-r6 \
  r-cran-catools \
  r-cran-bitops

apt-get  install -y \
  vim \
  net-tools \
  inetutils-ping \
  curl \
  git \
  nmap \
  socat \
  sudo \
  libcairo2-dev \
  libxt-dev \
  xclip \
  xsel \
  bzip2 \
  python3-pip \
  python3-setuptools \
  python3-tk \
  supervisor \
  libc6 \
  libzmq5 \
  libmagick++-dev \
  ed

## TeX for the rmarkdown package in RStudio, and pandoc is also useful
apt-get install -y \
  texlive \
  texlive-base \
  texlive-latex-extra \
  texlive-pstricks \
  pandoc \
  
apt-get -y autoremove \
apt-get clean

## Configure default locale, see https://github.com/rocker-org/rocker/issues/19
# echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen 
# locale-gen en_US.utf8 \
# /usr/sbin/update-locale LANG=en_US.UTF-8

# ENV LC_ALL en_US.UTF-8
# ENV LANG en_US.UTF-8

## Set the locale so RStudio doesn't complain about UTF-8
# RUN locale-gen en_US en_US.UTF-8
# RUN DEBIAN_FRONTEND=noninteractive dpkg-reconfigure locales

## R-Studio Preview
rstudio_version=1.2.830

#wget https://s3.amazonaws.com/rstudio-ide-build/server/trusty/amd64/rstudio-server-${rstudio_version}-amd64.deb
#gdebi --n rstudio-server-${rstudio_version}-amd64.deb
#rm rstudio-server-${rstudio_version}-amd64.deb

wget https://s3.amazonaws.com/rstudio-ide-build/desktop/trusty/amd64/rstudio--${rstudio_version}-amd64.deb
gdebi --n rstudio-${rstudio_version}-amd64.deb
rm rstudio-${rstudio_version}-amd64.deb

shiny_version=1.5.7.907

wget https://download3.rstudio.org/ubuntu-14.04/x86_64/shiny-server-${shiny_version}-amd64.deb
DEBIAN_FRONTEND=noninteractive gdebi -n shiny-server-${shiny_version}-amd64.deb
rm shiny-server-${shiny_version}-amd64.deb

