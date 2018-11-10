## based mainly on https://github.com/mccahill/docker-rstudio
FROM ubuntu:bionic

MAINTAINER Vincent Nijs "radiant@rady.ucsd.edu"
ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update \
  && apt-get -y upgrade \
  && apt-get install -y --no-install-recommends \
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
    software-properties-common \
  && add-apt-repository --enable-source --yes "ppa:marutter/rrutter3.5" \
  && add-apt-repository --enable-source --yes "ppa:marutter/c2d4u3.5" \
  && apt-get update

RUN apt-get -y install --no-install-recommends\
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
  libgdal-dev \
  libproj-dev \
  r-base \
  r-base-dev \
  r-cran-rcpp \
  r-cran-pbdzmq \
  r-cran-r6 \
  r-cran-catools \
  r-cran-bitops

## Utilities
RUN apt-get  install -y \
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
  ed \
  rsync \
  vifm

## TeX for the rmarkdown package in RStudio, and pandoc is also useful
RUN apt-get install -y \
  texlive \
  texlive-base \
  texlive-latex-extra \
  texlive-pstricks \
  texlive-xetex \
  && apt-get -y autoremove \
  && apt-get clean

## Configure default locale, see https://github.com/rocker-org/rocker/issues/19
RUN echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen \
	&& locale-gen en_US.utf8 \
	&& /usr/sbin/update-locale LANG=en_US.UTF-8

ENV LC_ALL en_US.UTF-8
ENV LANG en_US.UTF-8

## Install newer pandoc version
RUN wget https://github.com/jgm/pandoc/releases/download/2.3.1/pandoc-2.3.1-linux.tar.gz \
  && tar xvzf pandoc-2.3.1-linux.tar.gz --strip-components=1 -C /usr/local \
  && rm pandoc-*

## R-Studio Preview
ENV RSTUDIO_VERSION 1.2.1091

RUN wget https://s3.amazonaws.com/rstudio-ide-build/server/trusty/amd64/rstudio-server-${RSTUDIO_VERSION}-amd64.deb \
  && gdebi -n rstudio-server-${RSTUDIO_VERSION}-amd64.deb \
  && rm rstudio-server-*-amd64.deb

## link to Rstudio's pandoc
# RUN ln -s /usr/lib/rstudio-server/bin/pandoc/pandoc /usr/local/bin

RUN useradd rstudio \
  && echo "rstudio:rstudio" | chpasswd \
  && mkdir /home/rstudio \
  && chown rstudio:rstudio /home/rstudio \
  && addgroup rstudio staff \
  && adduser rstudio sudo && echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

## Shiny
ENV SHINY_VERSION 1.5.9.923

RUN wget https://download3.rstudio.org/ubuntu-14.04/x86_64/shiny-server-${SHINY_VERSION}-amd64.deb \
  && gdebi -n shiny-server-${SHINY_VERSION}-amd64.deb \
  && rm shiny-server-*-amd64.deb

WORKDIR /home/rstudio
COPY .Rprofile /home/rstudio/.Rprofile
RUN ln -sf /home/rstudio/.Rprofile /home/shiny/.Rprofile \
  && mkdir -p /var/log/shiny-server \
  && mkdir -p /srv/shiny-server/apps \
  && chown shiny:shiny /var/log/shiny-server \
  && chmod -R ug+s /var/log/shiny-server \
  && chown -R shiny:shiny /srv/shiny-server \
  && chmod -R ug+s /srv/shiny-server \
  && chown shiny:shiny /home/shiny/.Rprofile \
  && chown rstudio:rstudio /home/rstudio/.Rprofile \
  && adduser rstudio shiny \
  && mkdir -p /var/log/supervisor \
  && chown rstudio:rstudio /var/log/supervisor

## set path to user directory to install packages
RUN sed -i -e 's/~\/R\/x86_64/~\/.rsm-msba\/R\/x86_64/' /etc/R/Renviron

