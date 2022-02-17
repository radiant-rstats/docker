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
    && sudo apt-get install -y build-essential

RUN pip3 install bash_kernel \
  "pyrsm>=0.5.1" \
  jupyterlab_widgets \
  jupytext \ 
  jupyterlab_code_formatter \
  jupyterlab-git \
  jupyterlab-skip-traceback \
  lckr-jupyterlab-variableinspector \
  && python -m bash_kernel.install 

RUN jupyter labextension install \
  @jupyter-widgets/jupyterlab-manager \ 
  @jupyterlab/git \
  jupyterlab-jupytext \
  @ryantam626/jupyterlab_code_formatter
  # @lckr/jupyterlab_variableinspector  # this has been shifted up to be installed using pip

RUN jupyter serverextension enable \
  --py jupyterlab_code_formatter --system \
  && jupyter server extension enable \
  --py jupyterlab_git --system \
  && jupyter lab build

# Removing this because it is incompatible with jupyterlab 3.x
# RUN git clone https://github.com/vnijs/jupyterlab_spellchecker /opt/jupyter/jupyterlab_spellchecker \
#   && cd /opt/jupyter/jupyterlab_spellchecker \   
#   && npm install \
#   && npm run build \
#   && jupyter labextension link . 

ENV R_VERSION=4.1.2
ENV TERM=xterm
ENV R_HOME=/usr/local/lib/R
ENV CRAN=https://packagemanager.rstudio.com/cran/__linux__/focal/latest
ENV TZ=Etc/UTC

# Build icu4c and libiconv first to prevent issues in install_R.sh later
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
  && ./install_R.sh

# set path to user directory to install packages
# fix bug in Rstudio 1.3 that omits /usr/local/lib/R from .libPaths()
# commenting this out until we know more about the location of .Renviron file, otherwise it will throw a file not found error
# RUN sed -i -e 's/~\/R\/x86_64/~\/.rsm-msba\/R\/x86_64/' /etc/R/.Renviron \
#     && sed -i -e 's/R_LIBS_SITE-/R_LIBS_SITE:-/' /etc/R/.Renviron

# install the R kernel for Jupyter Lab
RUN R -e 'install.packages(c("IRkernel", "remotes")); IRkernel::installspec(user = FALSE)'

# install google chrome
# RUN wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - \
#   && sh -c 'echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google-chrome.list' \
#   && apt-get -y update \
#   && apt-get install -y google-chrome-stable \
#   && wget -O /tmp/chromedriver.zip http://chromedriver.storage.googleapis.com/`curl -sS chromedriver.storage.googleapis.com/LATEST_RELEASE`/chromedriver_linux64.zip \
#   && unzip /tmp/chromedriver.zip chromedriver -d /usr/local/bin/ \
#   && chmod 777 /usr/local/bin/chromedriver \
#   && rm -rf /tmp/* 

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

# update R-packages
RUN R -e 'remotes::install_github("vnijs/Diagrammer", upgrade = "never")' \
  -e 'remotes::install_github("bmschmidt/wordVectors", upgrade = "never")' \
  -e 'install.packages(c("igraph","rWishart"))'

ENV CMDSTAN_VERSION="2.26.1"

RUN conda install -c conda-forge cmdstan=${CMDSTAN_VERSION}

# settings for local install of python packages 
ARG PYBASE=/home/${NB_USER}/.rsm-msba
ENV PYBASE=${PYBASE}
ENV PYTHONUSERBASE=${PYBASE} \
  # JUPYTER_PATH=${PYBASE}/share/jupyter \
  # JUPYTER_RUNTIME_DIR=/tmp/jupyter/runtime \
  # JUPYTER_CONFIG_DIR=${PYBASE}/jupyter \
  SHELL=/bin/zsh \
  CMDSTAN="/opt/cmdstan/cmdstan-${CMDSTAN_VERSION}"

# updating the supervisord.conf file for Jupyter
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Copy the launch script into the image
# ADD https://raw.githubusercontent.com/radiant-rstats/docker/master/launch-rsm-msba.sh /opt/launch.sh
# RUN chmod 777 /opt/launch.sh

EXPOSE 8989 8765 22

RUN addgroup ${NB_USER} postgres

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]

# Weirdly it doesn't find wget and git commands at this point
RUN sudo apt-get install -y wget git

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

# weirdness with lib not being available for V8 and rstan
# although it works fine in the vnijs/radiant container
# RUN apt-get install -y libnode-dev

# USER ${NB_USER}
# ENV HOME /home/${NB_USER}
