# Copyright (c) Jupyter Development Team.
# Distributed under the terms of the Modified BSD License.
ARG OWNER=jupyter
ARG BASE_CONTAINER=$OWNER/pyspark-notebook
FROM $BASE_CONTAINER

LABEL Vincent Nijs "radiant@rady.ucsd.edu"

ARG DOCKERHUB_VERSION_UPDATE
ENV DOCKERHUB_VERSION=${DOCKERHUB_VERSION_UPDATE}
ENV DOCKERHUB_NAME=rsm-jupyter

# Fix DL4006
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

USER root

# fixes the issue where sudo requires terminal for password when starting postgres
RUN echo "${NB_USER} ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

# This installs toolchain 
RUN apt-get update -qq && apt-get -y --no-install-recommends install \
  supervisor \
  openssh-server \
  zsh \
  vim \
  vifm

# ML frameworks that are not (yet) available
# 'pytorch' \
# 'pyro-ppl' \
# 'numpyro' \
# 'jax' \
# 'jaxlib' \

ENV CMDSTAN_VERSION="2.29.0"

RUN mamba install -y -c conda-forge \
  cmdstan=${CMDSTAN_VERSION} \
  sqlalchemy \
  psycopg2 \
  ipython-sql \
  altair \
  beautifulsoup4 \
  scikit-learn \
  mlxtend \
  xgboost \
  graphviz \
  lime \
  shap \
  spacy \
  pydotplus \
  networkx \
  seaborn \
  selenium \
  sqlalchemy \
  pyLDAvis \
  python-dotenv \
  linearmodels \
  jupyterlab_widgets \
  jupytext \
  jupyterlab_code_formatter \
  black \
  isort \
  jupyterlab-git \
  jupyterlab-spellchecker \
  jupyter-server-proxy \
  mamba_gator \
  rpy2 \
  bash_kernel \
  && python -m bash_kernel.install

RUN mamba install -y -c suhas_goutham pyrsm

RUN mamba install -y -c \
  tensorflow \
  keras \
  && mamba clean --all -f -y \
  && fix-permissions "${CONDA_DIR}"

RUN pip3 install jupyterlab-skip-traceback \
  lckr-jupyterlab-variableinspector

# oh-my-zsh
RUN wget https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh \
  && git clone https://github.com/zsh-users/zsh-completions ${ZSH_CUSTOM:=~/.oh-my-zsh/custom}/plugins/zsh-completions \
  && git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions \
  && git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting \
  && git clone https://github.com/supercrabtree/k ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/k \
  && git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k \
  && cp -R /home/jovyan/.oh-my-zsh /etc/skel/.oh-my-zsh

COPY files/zshrc /etc/skel/.zshrc
COPY files/p10k.zsh /etc/skel/.p10k.zsh
COPY files/usethis /usr/local/bin/usethis
COPY files/clean.sh /usr/local/bin/clean     

ENV R_VERSION=4.1.2
ENV TERM=xterm
ENV R_HOME=/usr/local/lib/R
ENV CRAN=https://packagemanager.rstudio.com/cran/__linux__/focal/latest
ENV TZ=Etc/UTC

COPY files/install_R.sh install_R.sh
RUN chmod 755 install_R.sh \ 
  && ./install_R.sh \
  && rm install_R.sh

ENV R_HOME=${R_HOME:-/usr/local/lib/R}
RUN echo "R_LIBS_USER='~/.rsm-msba/R/'" >> ${R_HOME}/etc/Renviron.site
RUN echo '.libPaths(unique(c(Sys.getenv("R_LIBS_USER"), .libPaths())))' >> ${R_HOME}/etc/Rprofile.site

COPY files/setup-tidyverse.sh setup.sh
RUN chmod +x setup.sh \
  && ./setup.sh \
  && rm setup.sh

COPY files/setup-radiant.sh setup.sh
RUN chmod +x setup.sh \
  && ./setup.sh \
  && rm setup.sh

# adding postgres
# mostly from https://docs.docker.com/engine/examples/postgresql_service/
ENV POSTGRES_VERSION=12

RUN apt-get update && apt-get install -y \
  postgresql-${POSTGRES_VERSION} \
  postgresql-client-${POSTGRES_VERSION} \
  postgresql-contrib-${POSTGRES_VERSION}

# Run the rest of the commands as the postgres user
USER postgres

ARG PGPASSWORD=${PGPASSWORD:-postgres}
ENV PGPASSWORD=${PGPASSWORD}

# # create a postgres role for ${NB_USER} with "postgres" as the password
# # create a database "rsm-docker" owned by the ${NB_USER} role.
RUN /etc/init.d/postgresql start \
  && psql --command "CREATE USER ${NB_USER} WITH SUPERUSER PASSWORD '${PGPASSWORD}';" \
  && createdb -O ${NB_USER} rsm-docker

COPY files/postgresql.conf /etc/postgresql/${POSTGRES_VERSION}/main/postgresql.conf
COPY files/pg_hba.conf /etc/postgresql/${POSTGRES_VERSION}/main/pg_hba.conf

USER root

RUN addgroup ${NB_USER} postgres \
  && chown -R postgres:postgres /etc/postgresql/${POSTGRES_VERSION}/main/ \
  && fix-permissions /etc/postgresql/${POSTGRES_VERSION}/main/

# settings for local install of python packages 
ARG PYBASE=/home/${NB_USER}/.rsm-msba
ENV PYBASE=${PYBASE}
ENV PYTHONUSERBASE=${PYBASE} \
  JUPYTER_PATH=${PYBASE}/share/jupyter \
  JUPYTER_CONFIG_DIR=${PYBASE}/jupyter \
  JUPYTER_RUNTIME_DIR=/tmp/jupyter/runtime 

ENV SHELL=/bin/zsh \
  CMDSTAN="/opt/cmdstan/cmdstan-${CMDSTAN_VERSION}" \
  R_LIBS_USER="~/.rsm-msba/R/"

COPY images/gitgadget.svg /opt/shiny/gitgadget.svg
COPY images/logo200.svg /opt/shiny/logo.svg
RUN git clone https://github.com/vnijs/gitgadget.git /opt/shiny/gitgadget/ \ 
  && git clone https://github.com/radiant-rstats/radiant.git /opt/shiny/radiant/ 

# updating the supervisord.conf file for Jupyter and the notebook_config file
COPY files/supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY files/jupyter_notebook_config.py /etc/jupyter/
COPY files/condarc /opt/conda/.condarc
RUN mkdir -p /var/log/supervisor \
  && fix-permissions /var/log/supervisor \
  && fix-permissions /etc/supervisor/conf.d/ \
  && fix-permissions /etc/jupyter/ \
  && fix-permissions "${CONDA_DIR}" 

# Copy the launch script into the image
ADD https://raw.githubusercontent.com/radiant-rstats/docker/master/launch-${DOCKERHUB_NAME}.sh /opt/launch.sh
COPY files/setup.sh /usr/local/bin/setup
RUN fix-permissions /etc/skel \
  && fix-permissions /usr/local/bin \
  && chmod 755 /usr/local/bin/* 

EXPOSE 8989 8765 8181 8282
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]

# Switch back to jovyan to avoid accidental container runs as root
USER ${NB_UID}
ENV HOME /home/${NB_USER}
WORKDIR "${HOME}"
