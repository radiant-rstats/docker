# version latest posted on 8-17-2022
# FROM jupyter/pyspark-notebook:ubuntu-22.04
# FROM jupyter/pyspark-notebook@sha256:0c2635651aa3576e6870e8702c989b32dcc71bdcf0167812de55983e9d720316
# ubuntu-22.04 version latest posted on 10-12-2022 (amd64)
# FROM jupyter/pyspark-notebook@sha256:c02dfe9defdd9bc8f8329a0bb7361a5f76a58bf1c8f66eefb2e7f55ef9b4d068
# ubuntu-22.04 version latest posted on 11-21-2022 (amd64)
# FROM jupyter/pyspark-notebook@sha256:969d58e6dec81f2f2822987c7aee8437477a1e15057d5ca4787ec023fd561831
# ubuntu-22.04 version latest posted on 1-8-2023 (amd64)
# FROM jupyter/pyspark-notebook@sha256:216ee24a0adcc70f05740ecd7b2c5c7f8fcb7d4a662df4399f4d87f92c15e3be
# python 3.10.8 version posted on 1-8-2023 (amd64)
FROM jupyter/pyspark-notebook@sha256:216ee24a0adcc70f05740ecd7b2c5c7f8fcb7d4a662df4399f4d87f92c15e3be

LABEL Vincent Nijs "radiant@rady.ucsd.edu"

ARG DOCKERHUB_VERSION_UPDATE
ENV DOCKERHUB_VERSION=${DOCKERHUB_VERSION_UPDATE}
ENV DOCKERHUB_NAME=rsm-jupyter-rs

# Fix DL4006
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

USER root

# fixes the issue where sudo requires terminal for password when starting postgres
RUN echo "${NB_USER} ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

RUN apt-get update -qq && apt-get -y --no-install-recommends install \
  supervisor \
  openssh-server \
  zsh \
  vim \
  vifm \
  wget \
  rsync \
  lsb-release \
  libcurl4-openssl-dev \
  git

# libgit2-dev
# libfreetype6-dev \
# libpng-dev \
# libtiff5-dev \
# libjpeg-dev

ENV CMDSTAN_VERSION="2.30.0"
ENV PYRSM_VERSION="0.6.2"
RUN mamba install --quiet --yes -c vnijs -c conda-forge \
  cmdstan=${CMDSTAN_VERSION} \
  cmdstanpy \
  sqlalchemy \
  psycopg2 \
  ipython-sql \
  beautifulsoup4 \
  scikit-learn \
  mlxtend \
  xgboost \
  lightgbm \
  graphviz \
  lime \
  shap \
  spacy \
  pydotplus \
  networkx \
  seaborn \
  plotnine \
  selenium \
  sqlalchemy \
  pyLDAvis \
  python-dotenv \
  statsmodels \
  linearmodels \
  jupyterlab_widgets \
  jupytext \
  black \
  isort \
  nltk \
  jupyterlab-git \
  jupyterlab-spellchecker \
  jupyter-server-proxy \
  jupyter-rsession-proxy \
  jupyterlab-system-monitor \
  flask \
  streamlit \
  "pyrsm>=${PYRSM_VERSION}" \
  xlrd \
  openpyxl \
  pyarrow \
  python-duckdb \
  bash_kernel \
  && python -m bash_kernel.install

# causing issues with 1/12/2023 update
# snowflake-connector-python

COPY files/setup-ml-frameworks.sh setup.sh
RUN chmod 755 setup.sh \
  && ./setup.sh \
  && rm setup.sh

# make system (conda) R the first choice
ENV R_VERSION=4.2.2
ENV TERM=xterm
ENV R_HOME=/opt/conda/lib/R
ENV PATH="/usr/local/bin:$PATH"

RUN mamba install --quiet --yes -c conda-forge \
  "r-base>=${R_VERSION}" \
  r-curl \
  binutils \
  libgit2 \
  freetype \
  libpng \
  libtiff \
  libjpeg-turbo \
  c-compiler \
  rpy2 \
  jupyterlab-variableinspector \
  jupyterlab_code_formatter \
  shiny \
  && ln -s /opt/conda/bin/R /usr/local/bin/R

# not available through conda-forge for both arm and amd
# or the conda version is causing issues
RUN pip install \
  jupyterlab-skip-traceback \
  radian \
  polars \
  catboost

RUN echo "R_LIBS_USER='~/.rsm-msba/R/${R_VERSION}'" >> ${R_HOME}/etc/Renviron.site
RUN echo '.libPaths(unique(c(Sys.getenv("R_LIBS_USER"), .libPaths())))' >> ${R_HOME}/etc/Rprofile.site

COPY files/setup-tidyverse.sh setup.sh
RUN chmod +x setup.sh \
  && ./setup.sh \
  && rm setup.sh

# packages need for radiant a reproducible analysis
COPY files/setup-radiant.sh setup.sh
RUN chmod +x setup.sh \
  && ./setup.sh \
  && rm setup.sh

# tooling for Bayesian Machine Learning class
COPY files/setup-bml.sh setup.sh
RUN chmod +x setup.sh \
  && ./setup.sh \
  && rm setup.sh

# adding postgres
# mostly from https://docs.docker.com/engine/examples/postgresql_service/
ENV POSTGRES_VERSION=14

# upgrade to postgres 14
RUN apt -y update && \
  apt -y upgrade && \
  apt -y install gpgv dirmngr wget vim && \
  sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list' && \
  wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add - && \
  apt -y update && \
  apt-get install -y \
  postgresql-${POSTGRES_VERSION} \
  postgresql-client-${POSTGRES_VERSION} \
  postgresql-contrib-${POSTGRES_VERSION}

# Run the rest of the commands as the postgres user
RUN addgroup ${NB_USER} postgres \
  && addgroup postgres users \
  && chown -R postgres:postgres /etc/postgresql/${POSTGRES_VERSION}/ \
  && chown -R postgres:postgres /var/lib/postgresql/${POSTGRES_VERSION}/ \
  && chmod -R u=rwX,go= /var/lib/postgresql/${POSTGRES_VERSION}/

USER postgres

ARG PGPASSWORD=${PGPASSWORD:-postgres}
ENV PGPASSWORD=${PGPASSWORD}

# create a postgres role for ${NB_USER} with "postgres" as the password
# create a database "rsm-docker" owned by the ${NB_USER} role.
RUN /etc/init.d/postgresql start \
  && psql --command "CREATE USER ${NB_USER} WITH SUPERUSER PASSWORD '${PGPASSWORD}';" \
  && createdb -O ${NB_USER} rsm-docker

COPY files/postgresql.conf /etc/postgresql/${POSTGRES_VERSION}/main/postgresql.conf
COPY files/pg_hba.conf /etc/postgresql/${POSTGRES_VERSION}/main/pg_hba.conf

USER root

# populate version number in conf file
RUN sed -i 's/__version__/'"$POSTGRES_VERSION"'/g' /etc/postgresql/${POSTGRES_VERSION}/main/postgresql.conf

RUN addgroup ${NB_USER} postgres \
  && chown -R postgres:postgres /etc/postgresql/${POSTGRES_VERSION}/main/ \
  && fix-permissions /etc/postgresql/${POSTGRES_VERSION}/main/

# oh-my-zsh (need to install wget and curl again ...)
RUN apt-get update -qq && apt-get -y --no-install-recommends install wget curl \
  && sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" \
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

# settings for local install of python packages 
ARG PYBASE=/home/${NB_USER}/.rsm-msba
ENV PYBASE=${PYBASE}
ENV PYTHONUSERBASE=${PYBASE} \
  JUPYTER_PATH=${PYBASE}/share/jupyter \
  JUPYTER_DATA_DIR=${PYBASE}/share/jupyter \
  JUPYTER_CONFIG_DIR=${PYBASE}/jupyter \
  JUPYTER_RUNTIME_DIR=/tmp/jupyter/runtime \
  RSTUDIO_WHICH_R=/usr/local/bin/R \
  SHELL=/bin/zsh \
  ZDOTDIR=/home/${NB_USER}/.rsm-msba/zsh \
  CMDSTAN="/opt/cmdstan/cmdstan-${CMDSTAN_VERSION}"

COPY files/install-rstudio.sh setup.sh
RUN chmod 755 setup.sh \
  && ./setup.sh \
  && rm setup.sh

# setup quarto - can be used with Rstudio
# and when connecting to running container
# from VSCode
COPY files/setup-quarto.sh setup.sh
RUN chmod +x setup.sh \
  && ./setup.sh \
  && rm setup.sh

# updating the supervisord.conf file for Jupyter and the notebook_config file
COPY files/supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY files/condarc /opt/conda/.condarc
RUN mkdir -p /var/log/supervisor \
  && fix-permissions /var/log/supervisor \
  && fix-permissions /etc/supervisor/conf.d/ \
  && fix-permissions "${CONDA_DIR}"

# copy base conda environment management script
COPY files/ccenv.sh /usr/local/bin/ccenv
COPY files/clist.sh /usr/local/bin/clist
COPY files/crem.sh /usr/local/bin/crem
COPY files/cimp.sh /usr/local/bin/cimp
COPY files/cexp.sh /usr/local/bin/cexp

# Copy the launch script into the image
COPY launch-${DOCKERHUB_NAME}.sh /opt/launch.sh
COPY files/setup.sh /usr/local/bin/setup
RUN fix-permissions /etc/skel \
  && fix-permissions /usr/local/bin \
  && chmod 755 /usr/local/bin/*

# get pgweb
RUN wget -O pgweb.zip https://github.com/sosedoff/pgweb/releases/download/v0.11.11/pgweb_linux_amd64.zip \
  && unzip pgweb.zip -d pgweb_dir \
  && rm pgweb.zip \
  && mv pgweb_dir/* /usr/local/bin/pgweb \
  && rm -rf pgweb_dir

# setting up jupyter-server-proxy extensions pgweb, gitgadget, and radiant
RUN pip install git+https://github.com/vnijs/jupyter-pgweb-proxy.git \
  && pip install git+https://github.com/vnijs/jupyter-gitgadget-proxy.git \
  && pip install git+https://github.com/vnijs/jupyter-radiant-proxy.git

# packages need for radiant a reproducible analysis
COPY files/setup-extra.sh setup.sh
RUN chmod +x setup.sh \
  && ./setup.sh \
  && rm setup.sh

RUN mamba update --yes pandoc \
  && mamba clean --all -f -y \
  && fix-permissions "${CONDA_DIR}" \
  && fix-permissions "/home/${NB_USER}"

# packages need for arrow
COPY files/setup-arrow.sh setup.sh
RUN chmod +x setup.sh \
  && ./setup.sh \
  && rm setup.sh

EXPOSE 8181 8282 8765 8989 8501 8000 6006
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]

# Switch back to jovyan to avoid accidental container runs as root
USER ${NB_UID}
ENV HOME /home/${NB_USER}
WORKDIR "${HOME}"
