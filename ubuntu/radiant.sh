#!/bin/bash

## Installing R-packages from miniCRAN repo
R -e 'source("https://raw.githubusercontent.com/radiant-rstats/minicran/gh-pages/rsm-msba.R")'

#git clone https://github.com/radiant-rstats/radiant.git /srv/shiny-server/radiant/
#RUN chown shiny:shiny -R /srv/shiny-server
#COPY shiny-server.conf  /etc/shiny-server/shiny-server.conf

