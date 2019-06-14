FROM vnijs/radiant:latest

LABEL Vincent Nijs "radiant@rady.ucsd.edu"

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

# install python packages
COPY requirements.txt /home/${NB_USER}/requirements.txt
RUN pip3 install -r /home/${NB_USER}/requirements.txt \
  && rm /home/${NB_USER}/requirements.txt \
  && python3 -m bash_kernel.install

ENV APT_KEY_DONT_WARN_ON_DANGEROUS_USAGE=DontWarn
RUN curl -sL https://deb.nodesource.com/setup_10.x | bash \
  && apt-get install -y nodejs \
  && npm install -g npm \
  && jupyter labextension install @jupyter-widgets/jupyterlab-manager @ryantam626/jupyterlab_code_formatter \
  && jupyter serverextension enable --py jupyterlab_code_formatter --system

# install the R kernel for Jupyter Lab
RUN R -e 'install.packages("IRkernel")' \
  && R -e 'IRkernel::installspec(user = FALSE)'

# install google chrome
RUN wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - \
  && sh -c 'echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google-chrome.list' \
  && apt-get -y update \
  && apt-get install -y google-chrome-stable \
  && wget -O /tmp/chromedriver.zip http://chromedriver.storage.googleapis.com/`curl -sS chromedriver.storage.googleapis.com/LATEST_RELEASE`/chromedriver_linux64.zip \
  && unzip /tmp/chromedriver.zip chromedriver -d /usr/local/bin/ \
  && rm -rf /tmp/*

# copy logo for use with jupyterlab
COPY images/logo200.svg /opt/radiant/logo.svg

# update R-packages
RUN R -e 'radiant.update::radiant.update()'

RUN pip3 install jupyter-rsession-proxy \
  && jupyter labextension install jupyterlab-server-proxy \
  && chown ${NB_USER}:shiny -R /var/lib/shiny-server \
  && chown ${NB_USER}:shiny -R /var/log/shiny-server

COPY jupyter_notebook_config.py /etc/jupyter/

# set jupyterlab password based on docker run argument
# ARG only leads to conflict with rstudio on alternate port
ARG JPASSWORD=${JPASSWORD:-jupyter}
ENV JPASSWORD=${JPASSWORD}

# adding postgres
# mostly from https://docs.docker.com/engine/examples/postgresql_service/
ENV POSTGRES_VERSION=10

RUN apt-get update && apt-get install -y \
  postgresql-${POSTGRES_VERSION} \
  postgresql-client-${POSTGRES_VERSION} \
  postgresql-contrib-${POSTGRES_VERSION}

# Run the rest of the commands as the postgres user
USER postgres

# create a postgres role for ${NB_USER} with "postgres" as the password
# create a database "rsm-docker" owned by the ${NB_USER} role.
RUN /etc/init.d/postgresql start \
  && psql --command "CREATE USER ${NB_USER} WITH SUPERUSER PASSWORD 'postgres';" \
  && createdb -O ${NB_USER} rsm-docker

COPY postgresql.conf /etc/postgresql/${POSTGRES_VERSION}/main/postgresql.conf
COPY pg_hba.conf /etc/postgresql/${POSTGRES_VERSION}/main/pg_hba.conf

USER root

# settings for local install of python packages 
ENV PYTHONUSERBASE=${PYBASE} \
  JUPYTER_PATH=${PYBASE}/share/jupyter \
  JUPYTER_RUNTIME_DIR=${PYBASE}/share/jupyter/runtime \
  JUPYTER_CONFIG_DIR=${PYBASE}/jupyter \
  SHELL=/bin/bash

# Adding a "clean up" script
COPY clean.sh /usr/local/bin/clean
RUN chmod +x /usr/local/bin/clean

# install script for spacevim
COPY spacevim/spacevim.sh /usr/local/bin/svim
RUN chmod +x /usr/local/bin/svim

# latest pre-release version
ENV CODE_SERVER="1.1156-vsc1.33.1"

RUN cd /opt \
  && mkdir /opt/code-server \
  && cd /opt/code-server \
  && wget -qO- https://github.com/cdr/code-server/releases/download/${CODE_SERVER}/code-server${CODE_SERVER}-linux-x64.tar.gz | tar zxvf - --strip-components=1

# locations to store vscode / code-server settings
ARG CODE_WORKINGDIR="/home/$NB_USER/git" 
ENV CODE_WORKINGDIR="${CODE_WORKINGDIR}" \
  CODE_USER_DATA_DIR="/home/$NB_USER/.rsm-msba/share/code-server" \
  CODE_EXTENSIONS_DIR="/home/$NB_USER/.rsm-msba/share/code-server/extensions" \
  CODE_BUILTIN_EXTENSIONS_DIR="/opt/code-server/extensions" \
  PATH=/opt/code-server:$PATH

# setup for code-server (aka vscode)
COPY images/vscode.svg /opt/code-server/vscode.svg
COPY settings.json /opt/code-server/settings.json
COPY vsix/*.vsix /opt/code-server/extensions/
COPY vscode-setup.sh /usr/local/bin/vscode
RUN chmod +x /usr/local/bin/vscode

# required for coenraads.bracket-pair-colorizer
# RUN npm i -g prismjs vscode vscode-uri escape-html

# updating the supervisord.conf file for Jupyter
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

EXPOSE 8080 8787 8989 8765

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]

# Does not work with Rstudio server authentication
# USER ${NB_USER}
# ENV HOME /home/${NB_USER}
