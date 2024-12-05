# find all here: https://quay.io/repository/jupyter/pyspark-notebook?tab=tags
# x86_64-10.22.2024 problems running dpkg for some reason
# impacts installs that need to find OS stuff but gets blocked by conda paths
# FROM quay.io/jupyter/pyspark-notebook@sha256:a16447608f176d372e1e84893dbd489a1a524c0b35c509ca8c341a80715affc7

# x86_64-ubuntu-22.04	7/25/2024
FROM quay.io/jupyter/pyspark-notebook@sha256:fb5e83562d196ead71f31e4ae1e37c6fe13e1c13c3cbf55d64ffc6166f0aedb7

LABEL Vincent Nijs "radiant@rady.ucsd.edu"

ARG DOCKERHUB_VERSION_UPDATE
ENV DOCKERHUB_VERSION=${DOCKERHUB_VERSION_UPDATE}
ENV DOCKERHUB_NAME=rsm-msba-intel
# ENV PANDAS_VERSION="2.0.3" # pyspark image still using 2.0.3
ENV PANDAS_VERSION="2.2.2"
ENV PYARROW_VERSION="16.1.0"
# needed to install gensim
ENV SCIPY_VERSION="1.12.0"

# Fix DL4006
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

USER root
ENV POSTGRES_VERSION=14

# fixes the issue where sudo requires terminal for password when starting postgres
RUN echo "${NB_USER} ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

RUN apt-get update -qq && apt-get -y --no-install-recommends install \
  supervisor \
  openssh-server \
  libcurl4-openssl-dev \
  zsh \
  vim \
  vifm \
  wget \
  rsync \
  lsb-release \
  git \
  netcat-traditional \
  htop \
  openjdk-17-jdk-headless \
  ant \
  ca-certificates-java \
  lsof \
  rename \
  pipx \
  liblzma* \
  liblzma-dev \
  gnupg* \
  gpgv \
  dirmngr && \
  sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list' && \
  wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add - && \
  apt -y update && \
  apt-get install -y \
  postgresql-${POSTGRES_VERSION} \
  postgresql-client-${POSTGRES_VERSION} \
  postgresql-contrib-${POSTGRES_VERSION} \
  && apt-get clean \
  && update-ca-certificates -f;

# all the ipy and jupter versions are fixed below due to various errors
# related to async
RUN mamba install --quiet --yes -c conda-forge \
  scipy=${SCIPY_VERSION} \
  pandas=${PANDAS_VERSION} \
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
  nltk \
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
  IPython=8.18.1 \
  ipykernel=6.26.0 \
  ipywidgets=8.1.1 \
  jupyter_client=8.6.0 \
  jupyter_core=5.5.1\
  jupyter_server=2.12.1 \
  jupyterlab=4.0.9 \
  jupytext=1.16.0 \
  jupyterlab_widgets \
  jupyter-server-proxy \
  jupyter-rsession-proxy \
  black \
  isort \
  streamlit \
  xlrd \
  openpyxl \
  pyarrow=${PYARROW_VERSION} \
  python-duckdb \
  duckdb-engine \
  bash_kernel \
  sympy \
  simpy \
  awscli \
  bokeh \
  dask-kubernetes \
  dask-ml \
  findspark \
  pyspark \
  plotly \
  && python -m bash_kernel.install

# causing issues with 1/12/2023 update
# snowflake-connector-python

COPY files/setup-ml-frameworks.sh setup.sh
RUN chmod 755 setup.sh \
  && ./setup.sh \
  && rm setup.sh

# make system (conda) R the first choice
ENV R_VERSION=4.4.2
ENV TERM=xterm
ENV R_HOME=/opt/conda/lib/R
ENV LD_LIBRARY_PATH="/opt/conda/lib:/usr/local/lib:${LD_LIBRARY_PATH}"
ENV PATH="/usr/local/bin:$PATH"

RUN mamba install --quiet --yes -c conda-forge \
  c-compiler \
  "r-base>=${R_VERSION}" \
  r-curl \
  r-matrix \
  r-systemfonts \
  binutils \
  libgit2 \
  freetype \
  libpng \
  libtiff \
  libjpeg-turbo \
  libxml2 \
  unixodbc \
  jupyterlab-variableinspector \
  jupyterlab_code_formatter \
  openssh \
  git \
  && ln -s /opt/conda/bin/R /usr/local/bin/R \
  && ln -s /opt/conda/bin/Rscript /usr/local/bin/Rscript

# not available through conda-forge for both arm and amd
# or the conda version is causing issues
RUN pip install \
  jupyterlab-skip-traceback \
  radian \
  fastexcel \
  polars \
  connectorx \
  xlsx2csv \
  jupysql \
  shiny \
  shinywidgets \
  pyrsm \
  textblob \
  transformers \
  gensim \
  alpaca-trade-api \
  vadersentiment


RUN echo "R_LIBS_USER='~/.rsm-msba/R/${R_VERSION}'" >> ${R_HOME}/etc/Renviron.site
RUN echo '.libPaths(unique(c(Sys.getenv("R_LIBS_USER"), .libPaths())))' >> ${R_HOME}/etc/Rprofile.site

# packages need for radiant a reproducible analysis
COPY files/setup-radiant.sh setup.sh
RUN chmod +x setup.sh \
  && ./setup.sh \
  && rm setup.sh

# Run the rest of the commands as the postgres user
RUN usermod -aG postgres ${NB_USER} \
  && usermod -aG users postgres \
  && chown -R postgres:postgres /etc/postgresql/${POSTGRES_VERSION}/ \
  && chown -R postgres:postgres /var/lib/postgresql/${POSTGRES_VERSION}/ \
  && chmod -R u=rwX,go= /var/lib/postgresql/${POSTGRES_VERSION}/ \
  && mkdir -p /var/run/postgresql \
  && chown postgres:postgres /var/run/postgresql \
  && chmod 2777 /var/run/postgresql \
  && mkdir -p /var/log/postgresql \
  && chown postgres:postgres /var/log/postgresql

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
RUN chown -R postgres:postgres /etc/postgresql/${POSTGRES_VERSION}/main/ \
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
  ZDOTDIR=/home/${NB_USER}/.rsm-msba/zsh

COPY files/install-rstudio.sh setup.sh
RUN chmod 755 setup.sh \
  && ./setup.sh \
  && rm setup.sh

# setup quarto - can be used with Rstudio
# and when connecting to running container
# from VSCode
ENV QUARTO_VERSION="1.5.55"
COPY files/setup-quarto.sh setup.sh
RUN chmod +x setup.sh \
  && ./setup.sh \
  && rm setup.sh

ENV POETRY_VERSION="1.8.3"

# updating the supervisord.conf file for Jupyter and the notebook_config file
COPY files/supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY files/condarc /opt/conda/.condarc
RUN mkdir -p /var/log/supervisor \
  && fix-permissions /var/log/supervisor \
  && fix-permissions /etc/supervisor/conf.d/ \
  && fix-permissions "${CONDA_DIR}"

# copy base conda environment management script
COPY files/ccenv.sh /usr/local/bin/ccenv
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

# setup hadoop
ENV JAVA_HOME "/usr/lib/jvm/java-17-openjdk-amd64/"
ENV HADOOP_VERSION 3.3.4
ENV HADOOP_HOME /opt/hadoop
ENV HADOOP_CONF_DIR=$HADOOP_HOME/etc/hadoop
COPY files/setup-hadoop.sh setup.sh
RUN chmod +x setup.sh \
  && ./setup.sh \
  && rm setup.sh

# hadoop configuration
ADD files/scalable_analytics/core-site.xml $HADOOP_HOME/etc/hadoop/
ADD files/scalable_analytics/hdfs-site.xml $HADOOP_HOME/etc/hadoop/
ADD files/scalable_analytics/init-dfs.sh /opt/hadoop/
ADD files/scalable_analytics/start-dfs.sh /opt/hadoop/
ADD files/scalable_analytics/stop-dfs.sh /opt/hadoop/
RUN chown -R ${NB_USER} ${HADOOP_HOME} \
  && chmod 755 ${HADOOP_HOME}/*.sh \
  && chmod 755 /usr/bin/hadoop
ENV PATH $PATH:$HADOOP_HOME/bin

# setting up ssh connection
RUN mkdir -p /var/run/sshd \
  && ssh-keygen -A \
  && echo 'PasswordAuthentication no' >> /etc/ssh/sshd_config \
  && echo 'PermitRootLogin no' >> /etc/ssh/sshd_config \
  && echo 'PubkeyAuthentication yes' >> /etc/ssh/sshd_config \
  && echo "AllowUsers ${NB_USER}" >> /etc/ssh/sshd_config \
  && chmod 0755 /var/run/sshd \
  && chsh -s $(which zsh) ${NB_USER}

# cleanup
RUN rm -rf ~/work/ \
  && rm -f ~/*.*

EXPOSE 22 4040 4041 8181 8282 8765 8989 8501 8000
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]

# Switch back to jovyan to avoid accidental container runs as root
USER ${NB_UID}
ENV HOME /home/${NB_USER}
WORKDIR "${HOME}"
