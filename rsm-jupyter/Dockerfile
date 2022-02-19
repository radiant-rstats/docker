# Copyright (c) Jupyter Development Team.
# Distributed under the terms of the Modified BSD License.
ARG OWNER=jupyter
ARG BASE_CONTAINER=$OWNER/pyspark-notebook
FROM $BASE_CONTAINER

LABEL Vincent Nijs "radiant@rady.ucsd.edu"

ARG DOCKERHUB_VERSION_UPDATE
ENV DOCKERHUB_VERSION=${DOCKERHUB_VERSION_UPDATE}

# Fix DL4006
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

USER root

# This installs toolchain to build icu4c and libiconv later
RUN sudo apt-get update \
    && sudo apt-get install -y build-essential supervisor openssh-server

ENV CMDSTAN_VERSION="2.29.0"

RUN mamba install -y -c conda-forge \
    r-base \ 
    r-irkernel \
    cmdstan=${CMDSTAN_VERSION} \
    bash_kernel \
    jupyterlab_widgets \
    jupytext \
    jupyterlab_code_formatter \
    jupyterlab-git \
    jupyterlab-spellchecker \
    && python -m bash_kernel.install

RUN mamba install -y -c suhas_goutham pyrsm

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

COPY zshrc /etc/skel/.zshrc
COPY p10k.zsh /etc/skel/.p10k.zsh
COPY usethis /usr/local/bin/usethis

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

# create a postgres role for ${NB_USER} with "postgres" as the password
# create a database "rsm-docker" owned by the ${NB_USER} role.
RUN /etc/init.d/postgresql start \
  && psql --command "CREATE USER ${NB_USER} WITH SUPERUSER PASSWORD '${PGPASSWORD}';" \
  && createdb -O ${NB_USER} rsm-docker

COPY postgresql.conf /etc/postgresql/${POSTGRES_VERSION}/main/postgresql.conf
COPY pg_hba.conf /etc/postgresql/${POSTGRES_VERSION}/main/pg_hba.conf

USER root

# Adding a "clean up" script
COPY clean.sh /usr/local/bin/clean
RUN chmod +x /usr/local/bin/clean
# settings for local install of python packages 
ARG PYBASE=/home/${NB_USER}/.rsm-msba
ENV PYBASE=${PYBASE}
ENV PYTHONUSERBASE=${PYBASE} \
  SHELL=/bin/zsh \
  CMDSTAN="/opt/cmdstan/cmdstan-${CMDSTAN_VERSION}"

# updating the supervisord.conf file for Jupyter
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Copy the launch script into the image
# ADD https://raw.githubusercontent.com/radiant-rstats/docker/master/launch-rsm-msba.sh /opt/launch.sh
# RUN chmod 777 /opt/launch.sh

RUN addgroup ${NB_USER} postgres \
    && mkdir -p /var/log/supervisor \
    && chown ${NB_USER} /var/log/supervisor

EXPOSE 8989 8765

ENTRYPOINT ["/usr/bin/supervisord"]

CMD ["-c", "/etc/supervisor/conf.d/supervisord.conf"]

USER ${NB_USER}
ENV HOME /home/${NB_USER}
