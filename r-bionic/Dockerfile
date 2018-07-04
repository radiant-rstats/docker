## Based mainly on https://github.com/mccahill/docker-rstudio
FROM ubuntu:bionic

MAINTAINER Vincent Nijs "radiant@rady.ucsd.edu"

RUN set -e && ln -sf /bin/bash /bin/sh

RUN DEBIAN_FRONTEND=noninteractive apt-get update \
  && apt-get -y upgrade \
  && apt-get install -y --no-install-recommends \
    software-properties-common \
    ed \
    less \
    locales \
    wget \
    ca-certificates \
    build-essential \
    clang \
  && add-apt-repository --enable-source --yes "ppa:marutter/rrutter3.5" \
  && add-apt-repository --enable-source --yes "ppa:marutter/c2d4u3.5"

RUN DEBIAN_FRONTEND=noninteractive apt-get -y install --no-install-recommends\
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

## OpenBLAS for faster linear algebra: http://brettklamer.com/diversions/statistical/faster-blas-in-r/
RUN DEBIAN_FRONTEND=noninteractive apt-get install  -y \
  apt-utils \
  libopenblas-base

## Utilities
RUN DEBIAN_FRONTEND=noninteractive apt-get  install -y \
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
  libmagick++-dev

## TeX for the rmarkdown package in RStudio, and pandoc is also useful
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y \
  texlive \
  texlive-base \
  texlive-latex-extra \
  texlive-pstricks \
  pandoc \
  && apt-get -y autoremove \
  && apt-get clean

## R-Studio Preview
ENV rstudio_version 1.2.747

RUN wget https://s3.amazonaws.com/rstudio-ide-build/server/trusty/amd64/rstudio-server-${rstudio_version}-amd64.deb
RUN DEBIAN_FRONTEND=noninteractive gdebi --n rstudio-server-${rstudio_version}-amd64.deb
RUN rm rstudio-server-${rstudio_version}-amd64.deb

## Set the locale so RStudio doesn't complain about UTF-8
RUN locale-gen en_US en_US.UTF-8
RUN DEBIAN_FRONTEND=noninteractive dpkg-reconfigure locales

RUN useradd rstudio \
  && echo "rstudio:rstudio" | chpasswd \
  && mkdir /home/rstudio \
  && chown rstudio:rstudio /home/rstudio \
  && addgroup rstudio staff

## Shiny

ENV shiny_version 1.5.7.907

RUN wget https://download3.rstudio.org/ubuntu-14.04/x86_64/shiny-server-${shiny_version}-amd64.deb
RUN DEBIAN_FRONTEND=noninteractive gdebi -n shiny-server-${shiny_version}-amd64.deb
RUN rm shiny-server-${shiny_version}-amd64.deb

WORKDIR /home/rstudio

COPY .Rprofile /home/rstudio/.Rprofile
RUN ln -sf /home/rstudio/.Rprofile /home/shiny/.Rprofile

RUN mkdir -p /var/log/shiny-server \
  && mkdir -p /srv/shiny-server/apps \
  && chown shiny:shiny /var/log/shiny-server \
  && chmod -R ug+s /var/log/shiny-server \
  && chown -R shiny:shiny /srv/shiny-server \
  && chmod -R ug+s /srv/shiny-server \
  && chown shiny:shiny /home/shiny/.Rprofile \
  && chown rstudio:rstudio /home/rstudio/.Rprofile \
  && adduser rstudio shiny

RUN mkdir -p /var/log/supervisor \
  && chown rstudio:rstudio /var/log/supervisor
