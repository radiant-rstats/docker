FROM vnijs/rsm-msba-spark:latest

MAINTAINER Vincent Nijs "radiant@rady.ucsd.edu"

ARG DOCKERHUB_VERSION_UPDATE
ENV DOCKERHUB_VERSION=${DOCKERHUB_VERSION_UPDATE}

ARG NB_USER="jovyan"
ARG NB_UID="1000"
ARG NB_GID="100"

## R-Studio Preview
ENV RSTUDIO_VERSION 1.2.1244

RUN apt-get remove -y --purge rstudio-server

RUN wget https://s3.amazonaws.com/rstudio-ide-build/server/trusty/amd64/rstudio-server-${RSTUDIO_VERSION}-amd64.deb \
  && gdebi -n rstudio-server-${RSTUDIO_VERSION}-amd64.deb \
  && rm rstudio-server-*-amd64.deb

RUN pip3 install jupyterhub==0.9.4

ENV PATH="${PATH}:/usr/lib/rstudio-server/bin"
ENV LD_LIBRARY_PATH="/usr/lib/R/lib:/lib:/usr/lib/x86_64-linux-gnu:/usr/lib/jvm/java-8-openjdk-amd64/jre/lib/amd64/server"

## add scripts from https://github.com/jupyter/docker-stacks/tree/master/base-notebook
COPY fix-permissions /usr/local/bin/
COPY start.sh /usr/local/bin/
COPY start-notebook.sh /usr/local/bin/
COPY start-singleuser.sh /usr/local/bin/

## updating the version added in rsm-msba
COPY jupyter_notebook_config.py /etc/jupyter/

RUN chmod +x /usr/local/bin/start.sh && \
  chmod +x /usr/local/bin/start-notebook.sh && \
  chmod +x /usr/local/bin/start-singleuser.sh && \
  chmod +x /usr/local/bin/fix-permissions

## Create NB_USER user with UID=1000 and in the 'users' group
## and make sure these dirs are writable by the `users` group.
RUN groupadd wheel -g 11 && \
  echo "auth required pam_wheel.so use_uid" >> /etc/pam.d/su && \
  chmod g+w /etc/passwd && \
  fix-permissions $HOME && \
  fix-permissions /opt && \
  fix-permissions /var/lib/shiny-server && \
  fix-permissions /var/log/shiny-server && \
  fix-permissions /var/lib/postgresql

## update R-packages
RUN R -e 'radiant.update::radiant.update()'

## update radiant to development version
# RUN R -e 'remotes::install_github("radiant-rstats/radiant.data", upgrade = "never")' \
#  -e 'remotes::install_github("radiant-rstats/radiant.basics", upgrade = "never")' \
#  -e 'remotes::install_github("radiant-rstats/radiant.design", upgrade = "never")' \
#  -e 'remotes::install_github("radiant-rstats/radiant.model", upgrade = "never")' \
#  -e 'remotes::install_github("radiant-rstats/radiant.multivariate", upgrade = "never")'

## path for local install of python packages from Rstudio or Jupyter Lab
ENV PYTHONUSERBASE=${PYBASE} \
  JUPYTER_PATH=${PYBASE}/share/jupyter \
  JUPYTER_RUNTIME_DIR=${PYBASE}/share/jupyter/runtime \
  JUPYTER_CONFIG_DIR=${PYBASE}/jupyter \
  SHELL=/bin/bash

## Add Tini
ENV TINI_VERSION v0.18.0
ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini /tini
RUN chmod +x /tini

## postgres will be started using start-notebook.sh
## reject remote connections to the database
RUN echo "host all  all    0.0.0.0/0  reject" >> /etc/postgresql/${POSTGRES_VERSION}/main/pg_hba.conf

ENTRYPOINT ["/tini", "-g", "--"]
CMD ["start-notebook.sh"]

USER ${NB_USER}
