FROM ubuntu:focal
LABEL Vincent Nijs "radiant@rady.ucsd.edu"
USER root

ARG NB_USER="jovyan"
ENV NB_USER=${NB_USER}
ARG NB_UID="1000"
ARG NB_GID="100"
ARG PASSWORD=${PASSWORD:-"jupyter"}

ARG DOCKERHUB_VERSION_UPDATE
ENV DOCKERHUB_VERSION=${DOCKERHUB_VERSION_UPDATE}

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
  && apt-get -y upgrade \
  && apt-get install -y --no-install-recommends \
  bash-completion \
  ca-certificates \
  file \
  fonts-texgyre \
  fonts-powerline \
  g++ \
  gfortran \
  gsfonts \
  libblas-dev \
  libbz2-1.0 \
  libcurl4 \
  libopenblas-openmp-dev \
  libpangocairo-1.0-0 \
  libpcre3 \
  libpng16-16 \
  libreadline8 \
  libtiff5 \
  liblzma5 \
  locales \
  make \
  unzip \
  zip \
  zlib1g \
  wget \
  software-properties-common \
  dirmngr \
  gpg-agent \
  openssh-server

RUN echo "deb http://cloud.r-project.org/bin/linux/ubuntu focal-cran40/" >> /etc/apt/sources.list \ 
  && gpg --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys E298A3A825C0D65DFD57CBB651716619E084DAB9 \
  && gpg -a --export E298A3A825C0D65DFD57CBB651716619E084DAB9 | apt-key add - \
  && add-apt-repository --yes "ppa:jonathonf/vim" \
  && apt-get update \
  && mkdir -p /var/run/sshd

RUN apt-get -y install --no-install-recommends \
  apt-transport-https \
  gdebi-core \
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
  libudunits2-dev \
  r-base \
  r-base-dev \
  libv8-dev

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
  vifm \
  zsh \
  python-is-python3 \
  tzdata \
  gnome-keyring \
  libsodium-dev \
  build-essential \
  acl

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

# R-Studio last know release to work with jupyter-rsession-proxy
# ENV RSTUDIO_VERSION 1.3.959
# R-Studio stable release
# ENV RSTUDIO_VERSION 1.3.1093
# R-Studio preview release
ENV RSTUDIO_VERSION 1.4.1106

RUN wget https://s3.amazonaws.com/rstudio-ide-build/server/bionic/amd64/rstudio-server-${RSTUDIO_VERSION}-amd64.deb \
  && gdebi -n rstudio-server-${RSTUDIO_VERSION}-amd64.deb \
  && rm rstudio-server-*-amd64.deb

# link to Rstudio's pandoc
RUN ln -s /usr/lib/rstudio-server/bin/pandoc/pandoc /usr/local/bin/pandoc

RUN useradd -m -s /bin/bash -N -u $NB_UID $NB_USER \
  && echo "${NB_USER}:${PASSWORD}" | chpasswd \
  && addgroup ${NB_USER} staff \
  && adduser ${NB_USER} sudo && echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

# download shiny-server
ENV SHINY_VERSION 1.5.16.958

RUN wget https://download3.rstudio.org/ubuntu-14.04/x86_64/shiny-server-${SHINY_VERSION}-amd64.deb \
  && gdebi -n shiny-server-${SHINY_VERSION}-amd64.deb \
  && rm shiny-server-*-amd64.deb

WORKDIR /home/${NB_USER}
COPY .Rprofile /home/${NB_USER}/.Rprofile
RUN ln -sf /home/${NB_USER}/.Rprofile /home/shiny/.Rprofile \
  && mkdir -p /var/log/shiny-server \
  && mkdir -p /srv/shiny-server/apps \
  && chown shiny:shiny /var/log/shiny-server \
  && chmod -R ug+ws /var/log/shiny-server \
  && chown -R shiny:shiny /srv/shiny-server \
  && chmod -R ug+s /srv/shiny-server \
  && chown shiny:shiny /home/shiny/.Rprofile \
  && chown ${NB_USER} /home/${NB_USER}/.Rprofile \
  && adduser ${NB_USER} shiny \
  && mkdir -p /var/log/supervisor \
  && chown ${NB_USER} /var/log/supervisor

# set path to user directory to install packages
# fix bug in Rstudio 1.3 that omits /usr/local/lib/R from .libPaths()
RUN sed -i -e 's/~\/R\/x86_64/~\/.rsm-msba\/R\/x86_64/' /etc/R/Renviron \
  && sed -i -e 's/R_LIBS_SITE-/R_LIBS_SITE:-/' /etc/R/Renviron

# installing some basic r-packages
RUN R -e  'options(repos = c(RSM = "https://rsm-compute-01.ucsd.edu:4242/rsm-msba/__linux__/focal/latest", RSPM = "https://packagemanager.rstudio.com/all/__linux__/focal/latest", CRAN = "https://cloud.r-project.org"))' \
  -e 'install.packages(c("Rcpp", "R6", "digest", "shiny", "rmarkdown", "DBI", "RPostgreSQL", "odbc", "remotes", "rprojroot", "renv", "languageserver"))' \
  -e 'install.packages(c("pbdZMQ", "caTools", "bitops"))'

# installing the radian terminal application
RUN pip3 install radian jupyterhub==1.3.0

COPY shiny-server.conf /etc/shiny-server/shiny-server.conf
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY userconf.sh /usr/local/bin/userconf.sh
RUN chmod +x /usr/local/bin/userconf.sh

# Copy the launch script into the image
ADD https://raw.githubusercontent.com/radiant-rstats/docker/master/launch-r-focal.sh /opt/launch.sh
RUN chmod 777 /opt/launch.sh

# Adding a script to copy the launch file to the Desktop
COPY launch.sh /usr/local/bin/launch
RUN chmod +x /usr/local/bin/launch

# copy dbase connections
COPY connections/ /etc/${NB_USER}/connections

# install oh-my-zsh
RUN sh -c "$(wget https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh -O -)" \
  && mv /root/.oh-my-zsh /usr/share/oh-my-zsh \ 
  && cd /usr/share/oh-my-zsh/ \
  && cp templates/zshrc.zsh-template zshrc \
  && wget https://aur.archlinux.org/cgit/aur.git/plain/0001-zshrc.patch\?h\=oh-my-zsh-git -O zshrc.patch && patch -p1 < zshrc.patch \
  && sudo ln /usr/share/oh-my-zsh/zshrc /etc/skel/.zshrc  \
  && sed -i 's/DSHELL=\/bin\/bash/DSHELL=\/bin\/zsh/g' /etc/adduser.conf

# adding a ligature font
# from https://www.jetbrains.com/lp/mono/
RUN mkdir -p /usr/share/fonts/truetype/meslo/
COPY ./fonts/*.ttf /usr/share/fonts/truetype/meslo/
RUN chmod 644 /usr/share/fonts/truetype/meslo/* \
  && fc-cache -fv

ENV SHELL=/bin/zsh

EXPOSE 8181 8787 22

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]

USER ${NB_USER}
ENV HOME /home/${NB_USER}
