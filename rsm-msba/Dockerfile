FROM vnijs/radiant:latest

MAINTAINER Vincent Nijs "radiant@rady.ucsd.edu"

ARG DOCKERHUB_VERSION_UPDATE
ENV DOCKERHUB_VERSION=${DOCKERHUB_VERSION_UPDATE}

ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update \
  && apt-get -y upgrade \
  && apt-get -y install --no-install-recommends \
    python3-venv \
    python3-virtualenv \
    libzmq3-dev \
    gpg-agent

## install python packages
COPY requirements.txt /home/${NB_USER}/requirements.txt
RUN pip3 install -r /home/${NB_USER}/requirements.txt \
  && rm /home/${NB_USER}/requirements.txt

ENV APT_KEY_DONT_WARN_ON_DANGEROUS_USAGE=DontWarn
RUN curl -sL https://deb.nodesource.com/setup_10.x | bash \
  && apt-get install -y nodejs \
  && npm install -g npm \
  && jupyter labextension install @jupyter-widgets/jupyterlab-manager @jupyterlab/git @ryantam626/jupyterlab_code_formatter \
  ## extension not supported in jupyterlab >= 0.35
  # && jupyter labextension install @jupyterlab/shortcutui \
  && jupyter serverextension enable --py jupyterlab_git --system \
  && jupyter serverextension enable --py jupyterlab_code_formatter --system

## install the R kernel for Jupyter Lab
RUN R -e 'install.packages(c("repr", "IRdisplay", "crayon", "pbdZMQ", "uuid"))' -e 'devtools::install_github("IRkernel/IRkernel")' \
  && R -e 'IRkernel::installspec(user = FALSE)'

## install google chrome
RUN wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - \
  && sh -c 'echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google-chrome.list' \
  && apt-get -y update \
  && apt-get install -y google-chrome-stable \
  && wget -O /tmp/chromedriver.zip http://chromedriver.storage.googleapis.com/`curl -sS chromedriver.storage.googleapis.com/LATEST_RELEASE`/chromedriver_linux64.zip \
  && unzip /tmp/chromedriver.zip chromedriver -d /usr/local/bin/ \
  && rm -rf /tmp/*

## copy logo for use with jupyterlab
COPY images/logo200.svg /opt/radiant/logo.svg

## update R-packages
RUN R -e 'radiant.update::radiant.update()'

## update radiant to development version
#RUN R -e 'remotes::install_github("radiant-rstats/radiant.data", upgrade = "never")' \
#  -e 'remotes::install_github("radiant-rstats/radiant.basics", upgrade = "never")' \
#  -e 'remotes::install_github("radiant-rstats/radiant.design", upgrade = "never")' \
#  -e 'remotes::install_github("radiant-rstats/radiant.model", upgrade = "never")' \
#  -e 'remotes::install_github("radiant-rstats/radiant.multivariate", upgrade = "never")'

RUN pip3 install jupyter-rsession-proxy \
  && jupyter labextension install jupyterlab-server-proxy \
  && chown ${NB_USER}:shiny -R /var/lib/shiny-server \
  && chown ${NB_USER}:shiny -R /var/log/shiny-server

COPY jupyter_notebook_config.py /etc/jupyter/

## set jupyterlab password based on docker run argument
## ARG only leads to conflict with rstudio on alternate port
ARG JPASSWORD=${JPASSWORD:-jupyter}
ENV JPASSWORD=${JPASSWORD}

## adding postgres
## mostly from https://docs.docker.com/engine/examples/postgresql_service/

ENV POSTGRES_VERSION=10

RUN apt-get update && apt-get install -y \
  postgresql-${POSTGRES_VERSION} \
  postgresql-client-${POSTGRES_VERSION} \
  postgresql-contrib-${POSTGRES_VERSION}

## Run the rest of the commands as the postgres user
USER postgres

## create a postgres role for ${NB_USER} with "postgres" as the password
## create a database "rsm-docker" owned by the ${NB_USER} role.
RUN /etc/init.d/postgresql start \
    && psql --command "CREATE USER ${NB_USER} WITH SUPERUSER PASSWORD 'postgres';" \
    && createdb -O ${NB_USER} rsm-docker

## reject remote connections to the database
# RUN echo "host all  all    0.0.0.0/0  reject" >> /etc/postgresql/${POSTGRES_VERSION}/main/pg_hba.conf

## allow (remote) access
RUN echo "host all  all    0.0.0.0/0  md5" >> /etc/postgresql/${POSTGRES_VERSION}/main/pg_hba.conf
RUN echo "listen_addresses='*'" >> /etc/postgresql/${POSTGRES_VERSION}/main/postgresql.conf

VOLUME  ["/etc/postgresql", "/var/log/postgresql", "/var/lib/postgresql"]

USER root

## updating the supervisord.conf file for Jupyter
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

EXPOSE 80 8787 8989 5432

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
