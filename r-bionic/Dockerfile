FROM ubuntu:bionic

ARG NB_USER="jovyan"
ENV NB_USER=${NB_USER}
ARG NB_UID="1001"
ARG NB_GID="100"
ARG RPASSWORD=${RPASSWORD:-"rstudio"}

ARG DOCKERHUB_VERSION_UPDATE
ENV DOCKERHUB_VERSION=${DOCKERHUB_VERSION_UPDATE}

LABEL Vincent Nijs "radiant@rady.ucsd.edu"
ENV DEBIAN_FRONTEND=noninteractive

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
  && add-apt-repository --yes "ppa:jonathonf/vim" \
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
  libicu-dev \
  libgdal-dev \
  libproj-dev \
  libgsl-dev \
  cmake \
  cargo \
  r-base \
  r-base-dev \
  r-cran-pbdzmq \
  r-cran-catools \
  r-cran-bitops

# setting up odbc for connections
RUN apt-get -y install \
  unixodbc \
  unixodbc-dev \
  odbc-postgresql \
  libsqliteodbc

# Utilities
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
  supervisor \
  libc6 \
  libzmq5 \
  libmagick++-dev \
  ed \
  rsync \
  vifm

# TeX for the rmarkdown package in RStudio, and pandoc is also useful
RUN apt-get install -y \
  texlive \
  texlive-base \
  texlive-latex-extra \
  texlive-pstricks \
  texlive-xetex \
  && apt-get -y autoremove \
  && apt-get clean \
  && apt-get update

# Configure default locale, see https://github.com/rocker-org/rocker/issues/19
RUN echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen \
  && locale-gen en_US.utf8 \
  && /usr/sbin/update-locale LANG=en_US.UTF-8

ENV LC_ALL en_US.UTF-8
ENV LANG en_US.UTF-8

# Official R-Studio 1.2 release
ENV RSTUDIO_VERSION 1.2.1541
RUN wget https://s3.amazonaws.com/rstudio-ide-build/server/bionic/amd64/rstudio-server-${RSTUDIO_VERSION}-amd64.deb \
  && gdebi -n rstudio-server-${RSTUDIO_VERSION}-amd64.deb \
  && rm rstudio-server-*-amd64.deb

# link to Rstudio's pandoc
RUN ln -s /usr/lib/rstudio-server/bin/pandoc/pandoc /usr/local/bin/pandoc

RUN useradd -m -s /bin/bash -N -u $NB_UID $NB_USER \
  && echo "${NB_USER}:${RPASSWORD}" | chpasswd \
  && addgroup ${NB_USER} staff \
  && adduser ${NB_USER} sudo && echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

# Shiny
ENV SHINY_VERSION 1.5.9.923

RUN wget https://download3.rstudio.org/ubuntu-14.04/x86_64/shiny-server-${SHINY_VERSION}-amd64.deb \
  && gdebi -n shiny-server-${SHINY_VERSION}-amd64.deb \
  && rm shiny-server-*-amd64.deb

WORKDIR /home/${NB_USER}
COPY .Rprofile /home/${NB_USER}/.Rprofile
RUN ln -sf /home/${NB_USER}/.Rprofile /home/shiny/.Rprofile \
  && mkdir -p /var/log/shiny-server \
  && mkdir -p /srv/shiny-server/apps \
  && chown shiny:shiny /var/log/shiny-server \
  && chmod -R ug+s /var/log/shiny-server \
  && chown -R shiny:shiny /srv/shiny-server \
  && chmod -R ug+s /srv/shiny-server \
  && chown shiny:shiny /home/shiny/.Rprofile \
  && chown ${NB_USER} /home/${NB_USER}/.Rprofile \
  && adduser ${NB_USER} shiny \
  && mkdir -p /var/log/supervisor \
  && chown ${NB_USER} /var/log/supervisor

# set path to user directory to install packages
RUN sed -i -e 's/~\/R\/x86_64/~\/.rsm-msba\/R\/x86_64/' /etc/R/Renviron

# installing some basic r-packages
RUN R -e 'install.packages(c("Rcpp", "R6", "digest", "shiny", "rmarkdown", "DBI", "RPostgreSQL", "odbc", "remotes", "rprojroot"))'

# install renv for Docker creation
RUN R -e 'remotes::install_github("rstudio/renv")' 

COPY shiny-server.conf /etc/shiny-server/shiny-server.conf
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY userconf.sh /usr/local/bin/userconf.sh
RUN chmod +x /usr/local/bin/userconf.sh

# copy dbase connections
COPY connections/ /etc/${NB_USER}/connections

EXPOSE 8080 8787

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
