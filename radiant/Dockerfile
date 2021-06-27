FROM vnijs/r-focal:latest
LABEL Vincent Nijs "radiant@rady.ucsd.edu"
USER root

ARG DOCKERHUB_VERSION_UPDATE
ENV DOCKERHUB_VERSION=${DOCKERHUB_VERSION_UPDATE}

# installing R-packages from miniCRAN repo
RUN git clone https://github.com/radiant-rstats/radiant.git /srv/shiny-server/radiant/ \
  && chown shiny:shiny -R /srv/shiny-server \
  && R -e 'install.packages("igraph", repos = "https://cran.rstudio.com")' \
  -e 'options(HTTPUserAgent = sprintf("R/%s R (%s)", getRversion(), paste(getRversion(), R.version$platform, R.version$arch, R.version$os)))' \
  -e 'options(repos = c(RSM = "https://rsm-compute-01.ucsd.edu:4242/rsm-msba/__linux__/focal/latest", RSPM = "https://packagemanager.rstudio.com/all/__linux__/focal/latest", CRAN = "https://cloud.r-project.org"))' \
  -e 'source("https://raw.githubusercontent.com/radiant-rstats/minicran/gh-pages/rsm-msba.R")'

# path for local install of python packages from Rstudio or Jupyter Lab
ARG PYBASE=/home/${NB_USER}/.rsm-msba
ENV PYBASE=${PYBASE}
RUN echo "PYTHONUSERBASE=${PYBASE}" >> /etc/R/Renviron.site \
  && echo "WORKON_HOME=${PYBASE}" >> /etc/R/Renviron.site \
  && echo "NB_USER=${NB_USER}" >> /etc/R/Renviron.site

## needed for gert
RUN apt-get install -y libgit2-dev

## update R-packages
RUN R -e 'options(HTTPUserAgent = sprintf("R/%s R (%s)", getRversion(), paste(getRversion(), R.version$platform, R.version$arch, R.version$os)))' \
  -e 'options(repos = c(RSM = "https://rsm-compute-01.ucsd.edu:4242/rsm-msba/__linux__/focal/latest", RSPM = "https://packagemanager.rstudio.com/all/__linux__/focal/latest", CRAN = "https://cloud.r-project.org"))' \
  -e 'install.packages(c("gert", "usethis"))' \
  -e 'remotes::install_github("vnijs/Diagrammer", upgrade = "never")' \
  -e 'remotes::install_github("vnijs/gitgadget", upgrade = "never")' \
  -e 'remotes::install_github("radiant-rstats/radiant.update", upgrade = "never")' \
  -e 'radiant.update::radiant.update()'

COPY shiny-server.conf /etc/shiny-server/shiny-server.conf
RUN sed -i -e "s/\:HOME_USER\:/${NB_USER}/" /etc/shiny-server/shiny-server.conf

COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Copy the launch script into the image
ADD https://raw.githubusercontent.com/radiant-rstats/docker/master/launch-radiant.sh /opt/launch.sh
RUN chmod 777 /opt/launch.sh

EXPOSE 8181 8787 22

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]

USER ${NB_USER}
ENV HOME /home/${NB_USER}