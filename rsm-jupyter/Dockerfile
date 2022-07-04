# FROM jupyter/pyspark-notebook:2022-05-29
# version latest posted on 6-22-2022
FROM jupyter/pyspark-notebook@sha256:6e69d7d254cfdb3209ded27425315f45c9796b79fd5be99b3e98efc7dd5dfd36

LABEL Vincent Nijs "radiant@rady.ucsd.edu"

ARG DOCKERHUB_VERSION_UPDATE
ENV DOCKERHUB_VERSION=${DOCKERHUB_VERSION_UPDATE}
ENV DOCKERHUB_NAME=rsm-jupyter

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
  rsync

ENV CMDSTAN_VERSION="2.30.0"
RUN mamba install --quiet --yes -c conda-forge \
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
  # catboost \
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
  jupyterlab_code_formatter \
  black \
  isort \
  jupyterlab-git \
  jupyterlab-spellchecker \
  jupyter-server-proxy \
  jupyter-rsession-proxy \
  jupyterlab-system-monitor \
  flask \
  streamlit \
  pyrsm \
  xlrd \
  openpyxl \
  pyarrow \
  python-duckdb \
  bash_kernel \
  && python -m bash_kernel.install

COPY files/setup-ml-frameworks.sh setup.sh
RUN chmod 755 setup.sh \
  && ./setup.sh \
  && rm setup.sh \
  && mamba clean --all -f -y \
  && fix-permissions "${CONDA_DIR}" \
  && fix-permissions "/home/${NB_USER}"

# not available through conda-forge
RUN pip install jupyterlab-skip-traceback \
  lckr-jupyterlab-variableinspector \
  radian

ENV R_VERSION=4.2.0
ENV TERM=xterm
ENV R_HOME=/usr/local/lib/R
ENV CRAN=https://packagemanager.rstudio.com/cran/__linux__/focal/latest
ENV TZ=Etc/UTC

COPY files/install-R.sh install-R.sh
RUN chmod 755 install-R.sh \
  && ./install-R.sh \
  && rm install-R.sh

RUN echo "R_LIBS_USER='~/.rsm-msba/R/${R_VERSION}'" >> ${R_HOME}/etc/Renviron.site
RUN echo '.libPaths(unique(c(Sys.getenv("R_LIBS_USER"), .libPaths())))' >> ${R_HOME}/etc/Rprofile.site

RUN pip install rpy2

COPY files/setup-tidyverse.sh setup.sh
RUN chmod +x setup.sh \
  && ./setup.sh \
  && rm setup.sh

# packages need for radiant a reproducible analysis
COPY files/setup-radiant.sh setup.sh
COPY files/setup-radiant.sh setup.sh
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
  apt -y install gnupg2 wget vim && \
  sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list' && \
  wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add - && \
  apt -y update && \
  apt-get install -y \
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
  CMDSTAN="/opt/cmdstan/cmdstan-${CMDSTAN_VERSION}" \
  LD_LIBRARY_PATH=/usr/local/lib/R/lib:/usr/local/lib:/usr/lib/aarch64-linux-gnu:/usr/lib/jvm/java-11-openjdk-arm64/lib/server

COPY images/gitgadget.svg /opt/shiny/gitgadget.svg
COPY images/logo200.svg /opt/shiny/logo.svg
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
COPY files/jupyter_notebook_config.py /etc/jupyter/
COPY files/condarc /opt/conda/.condarc
RUN mkdir -p /var/log/supervisor \
  && fix-permissions /var/log/supervisor \
  && fix-permissions /etc/supervisor/conf.d/ \
  && fix-permissions /etc/jupyter/ \
  && fix-permissions /opt/shiny/ \
  && fix-permissions "${CONDA_DIR}"

# copy base conda environment management script
COPY files/cc.sh /usr/local/bin/cc
COPY files/cl.sh /usr/local/bin/cl
COPY files/cr.sh /usr/local/bin/cr
COPY files/ci.sh /usr/local/bin/ci
COPY files/ce.sh /usr/local/bin/ce

# Copy the launch script into the image
COPY launch-${DOCKERHUB_NAME}.sh /opt/launch.sh
COPY files/setup.sh /usr/local/bin/setup
RUN fix-permissions /etc/skel \
  && fix-permissions /usr/local/bin \
  && chmod 755 /usr/local/bin/*

# get pgweb
RUN wget -O pgweb.zip https://github.com/sosedoff/pgweb/releases/download/v0.11.11/pgweb_linux_arm64_v7.zip \
  && unzip pgweb.zip -d pgweb_dir \
  && rm pgweb.zip \
  && mv pgweb_dir/* /usr/local/bin/pgweb \
  && rm -rf pgweb_dir

# setting up pgweb
RUN pip install git+https://github.com/illumidesk/jupyter-pgweb-proxy.git

# make system R the first choice
ENV PATH="/usr/local/bin:$PATH"

EXPOSE 8181 8282 8765 8989 8501
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]

# Switch back to jovyan to avoid accidental container runs as root
USER ${NB_UID}
ENV HOME /home/${NB_USER}
WORKDIR "${HOME}"
