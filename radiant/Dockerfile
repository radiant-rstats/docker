FROM vnijs/r-bionic

MAINTAINER Vincent Nijs "radiant@rady.ucsd.edu"

## Installing R-packages from miniCRAN repo
RUN R -e 'source("https://raw.githubusercontent.com/radiant-rstats/minicran/gh-pages/docker-rsm.R")'

RUN git clone https://github.com/radiant-rstats/radiant.git /srv/shiny-server/radiant/
RUN chown shiny:shiny -R /srv/shiny-server
COPY shiny-server.conf  /etc/shiny-server/shiny-server.conf
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

EXPOSE 80 8787

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
