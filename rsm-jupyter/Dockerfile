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

# fixes the issue where sudo requires terminal for password when starting postgres
RUN echo "${NB_USER} ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

# This installs toolchain 
RUN apt-get update -qq && apt-get -y --no-install-recommends install \
    build-essential \
    supervisor \
    openssh-server \
    zsh \
    vim \
    vifm

ENV CMDSTAN_VERSION="2.29.0"

RUN mamba install -y -c conda-forge \
    cmdstan=${CMDSTAN_VERSION} \
    sqlalchemy \
    psycopg2 \
    ipython-sql \
    altair \
    beautifulsoup4 \
    xgboost \
    lime \
    networkx \
    seaborn \
    selenium \
    shap \
    spacy \
    sqlalchemy \
    pyLDAvis \
    python-dotenv \
    linearmodels \
    jupyterlab_widgets \
    jupytext \
    jupyterlab_code_formatter \
    black \
    jupyterlab-git \
    jupyterlab-spellchecker \
    jupyter-rsession-proxy \
    jupyter-server-proxy \
    bash_kernel \
    && python -m bash_kernel.install

RUN mamba install -y -c suhas_goutham pyrsm

# ML framework that are not (yet) available
    # 'pytorch' \
    # 'pyro-ppl' \
    # 'numpyro' \
    # 'jax' \
    # 'jaxlib' \

RUN mamba install -y -c \
    tensorflow \
    keras \
    && mamba clean --all -f -y && \
    fix-permissions "${CONDA_DIR}" && \
    fix-permissions "/home/${NB_USER}"

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
RUN chmod +x /usr/local/bin/clean

ENV R_VERSION=4.1.2
ENV TERM=xterm
ENV R_HOME=/usr/local/lib/R
ENV CRAN=https://packagemanager.rstudio.com/cran/__linux__/focal/latest
ENV TZ=Etc/UTC

RUN wget https://github.com/unicode-org/icu/releases/download/release-69-1/icu4c-69_1-src.tgz \
    && tar -xf icu4c-69_1-src.tgz \
    && cd icu/source \
    && chmod +x runConfigureICU configure install-sh \
    && ./runConfigureICU Linux/gcc --prefix=/usr/local \
    && make \
    && make install \
    && cd \
    && rm icu4c-69_1-src.tgz

RUN wget https://ftp.gnu.org/pub/gnu/libiconv/libiconv-1.16.tar.gz \
    && tar -xf libiconv-1.16.tar.gz \
    && cd libiconv-1.16 \
    && chmod +x configure \
    && ./configure --prefix /usr/local \
    && make \
    && make install \
    && cd \
    && rm libiconv-1.16.tar.gz

RUN wget https://raw.githubusercontent.com/rocker-org/rocker-versioned2/master/scripts/install_R.sh \
  && chmod 755 install_R.sh \ 
  && ./install_R.sh \
  && rm install_R.sh

RUN apt-get update -qq && apt-get -y --no-install-recommends install wget
RUN wget -O /usr/local/bin/install2.r https://raw.githubusercontent.com/rocker-org/rocker-versioned2/master/scripts/bin/install2.r \
  && chmod 755 /usr/local/bin/install2.r 

COPY files/setup-tidyverse.sh setup.sh
RUN chmod +x setup.sh \
  && ./setup.sh \
  && rm setup.sh

ENV R_HOME=${R_HOME:-/usr/local/lib/R}
RUN echo "R_LIBS_USER='~/.rsm-msba/R/'" >> ${R_HOME}/etc/Renviron.site
RUN echo '.libPaths(unique(c(Sys.getenv("R_LIBS_USER"), .libPaths())))' >> ${R_HOME}/etc/Rprofile.site

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

# settings for local install of python packages 
ARG PYBASE=/home/${NB_USER}/.rsm-msba
ENV PYBASE=${PYBASE}
ENV PYTHONUSERBASE=${PYBASE} \
  JUPYTER_PATH=${PYBASE}/share/jupyter \
  JUPYTER_RUNTIME_DIR=/tmp/jupyter/runtime \
  JUPYTER_CONFIG_DIR=${PYBASE}/jupyter \
  SHELL=/bin/zsh \
  CMDSTAN="/opt/cmdstan/cmdstan-${CMDSTAN_VERSION}" \
  R_LIBS_USER="~/.rsm-msba/R/"

# updating the supervisord.conf file for Jupyter
COPY files/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Copy the launch script into the image
ADD https://raw.githubusercontent.com/radiant-rstats/docker/master/launch-rsm-jupyter.sh /opt/launch.sh
RUN chmod 755 /opt/launch.sh

RUN addgroup ${NB_USER} postgres \
  mkdir -p /var/log/supervisor \
  && chown ${NB_USER} /var/log/supervisor

EXPOSE 8989 8765 8181
ENTRYPOINT ["/usr/bin/supervisord"]
CMD ["-c", "/etc/supervisor/conf.d/supervisord.conf"]

# Switch back to jovyan to avoid accidental container runs as root
USER ${NB_UID}
ENV HOME /home/${NB_USER}
WORKDIR "${HOME}"
