FROM vnijs/r-bionic:latest

MAINTAINER Vincent Nijs "radiant@rady.ucsd.edu"

## installing R-packages from miniCRAN repo
RUN R -e 'source("https://raw.githubusercontent.com/radiant-rstats/minicran/gh-pages/rsm-msba.R")'
RUN git clone https://github.com/radiant-rstats/radiant.git /srv/shiny-server/radiant/ \
  && chown shiny:shiny -R /srv/shiny-server
COPY shiny-server.conf /etc/shiny-server/shiny-server.conf

## temp for updates
RUN R -e 'install.packages("radiant.data", repos = "https://radiant-rstats.github.io/minicran/")'
RUN R -e 'install.packages("radiant.model", repos = "https://radiant-rstats.github.io/minicran/")'
RUN R -e 'remotes::install_github("PMassicotte/gtrendsR@da29cf4e427b6bf33d5925ce82596d9c33f9656c", upgrade = "never")'

## path for local install of python packages from Rstudio or Jupyter Lab
ARG PYBASE=/home/rstudio/.rsm-msba
RUN echo "PYTHONUSERBASE=${PYBASE}" >> /etc/R/Renviron.site \
  && echo "WORKON_HOME=${PYBASE}" >> /etc/R/Renviron.site

COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

EXPOSE 80 8787

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
