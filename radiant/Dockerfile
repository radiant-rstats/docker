FROM vnijs/r-bionic:latest

LABEL Vincent Nijs "radiant@rady.ucsd.edu"

ARG DOCKERHUB_VERSION_UPDATE
ENV DOCKERHUB_VERSION=${DOCKERHUB_VERSION_UPDATE}

# installing R-packages from miniCRAN repo
RUN git clone https://github.com/radiant-rstats/radiant.git /srv/shiny-server/radiant/ \
  && chown shiny:shiny -R /srv/shiny-server \
  && R -e 'source("https://raw.githubusercontent.com/radiant-rstats/minicran/gh-pages/rsm-msba.R")'

# update radiant to development version
RUN R -e 'remotes::install_github("radiant-rstats/radiant.data", upgrade = "never")' \
  -e 'remotes::install_github("radiant-rstats/radiant.basics", upgrade = "never")' \
  -e 'remotes::install_github("radiant-rstats/radiant.design", upgrade = "never")' \
  -e 'remotes::install_github("radiant-rstats/radiant.model", upgrade = "never")' \
  -e 'remotes::install_github("radiant-rstats/radiant.multivariate", upgrade = "never")'

# install lightGBM
RUN git clone --recursive https://github.com/Microsoft/LightGBM \
  && cd LightGBM \
  && Rscript build_r.R \
  && cd .. \
  && rm -rf LightGBM

# path for local install of python packages from Rstudio or Jupyter Lab
ARG PYBASE=/home/${NB_USER}/.rsm-msba
ENV PYBASE=${PYBASE}
RUN echo "PYTHONUSERBASE=${PYBASE}" >> /etc/R/Renviron.site \
  && echo "WORKON_HOME=${PYBASE}" >> /etc/R/Renviron.site

## update R-packages
RUN R -e 'radiant.update::radiant.update()'

COPY shiny-server.conf /etc/shiny-server/shiny-server.conf
RUN sed -i -e "s/\:HOME_USER\:/${NB_USER}/" /etc/shiny-server/shiny-server.conf

COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

EXPOSE 8080 8787

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
