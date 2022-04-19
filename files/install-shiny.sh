#!/bin/bash

## adapted from 
## https://raw.githubusercontent.com/rocker-org/rocker-versioned2/master/scripts/install_shiny_server.sh

set -e

SHINY_SERVER_VERSION=${1:-${SHINY_SERVER_VERSION:-latest}}

## build ARGs
NCPUS=${NCPUS:--1}

# Run dependency scripts
# . /rocker_scripts/install_s6init.sh
# . /rocker_scripts/install_pandoc.sh

if [ "$SHINY_SERVER_VERSION" = "latest" ]; then
  SHINY_SERVER_VERSION=$(wget -qO- https://download3.rstudio.org/ubuntu-14.04/x86_64/VERSION)
fi

# Get apt packages
apt-get update
apt-get install -y --no-install-recommends \
    sudo \
    gdebi-core \
    libcurl4-openssl-dev \
    libcairo2-dev \
    libxt-dev \
    xtail \
    wget

# Install Shiny server
wget --no-verbose "https://download3.rstudio.org/ubuntu-14.04/x86_64/shiny-server-${SHINY_SERVER_VERSION}-amd64.deb" -O ss-latest.deb
gdebi -n ss-latest.deb
rm ss-latest.deb

# Get R packages
/usr/local/bin/R -e "install.packages(c('shiny', 'digest'), repo='${CRAN}', Ncpus=${NCPUS})" \

# Set up directories and permissions
if [ -x "$(command -v rstudio-server)" ]; then
  DEFAULT_USER=${DEFAULT_USER:-jovyan}
  adduser ${DEFAULT_USER} shiny
fi

cp -R /usr/local/lib/R/site-library/shiny/examples/* /srv/shiny-server/
chown shiny:shiny /var/lib/shiny-server
mkdir -p /var/log/shiny-server
chown shiny:shiny /var/log/shiny-server

# create init scripts
mkdir -p /etc/services.d/shiny-server
cat > /etc/services.d/shiny-server/run << 'EOF'
#!/usr/bin/with-contenv bash
## load /etc/environment vars first:
for line in $( cat /etc/environment ) ; do export $line > /dev/null; done
if [ "$APPLICATION_LOGS_TO_STDOUT" != "false" ]; then
    exec xtail /var/log/shiny-server/ &
fi
exec shiny-server 2>&1
EOF
chmod +x /etc/services.d/shiny-server/run

# install init script
# cp /rocker_scripts/init_set_env.sh /etc/cont-init.d/01_set_env

# Clean up
rm -rf /var/lib/apt/lists/*
rm -rf /tmp/downloaded_packages