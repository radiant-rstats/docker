FROM vnijs/radiant:latest
LABEL Vincent Nijs "radiant@rady.ucsd.edu"
USER root

ARG DOCKERHUB_VERSION_UPDATE
ENV DOCKERHUB_VERSION=${DOCKERHUB_VERSION_UPDATE}

ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update \
  && apt-get -y upgrade \
  && apt-get -y install --no-install-recommends \
  python3-venv \
  python3-virtualenv \
  libzmq3-dev \
  graphviz \
  fonts-firacode \
  libleptonica-dev \ 
  libtesseract-dev \ 
  tesseract-ocr

# install python packages
COPY requirements-base.txt /home/${NB_USER}/requirements.txt
# COPY requirements.txt /home/${NB_USER}/requirements.txt
RUN pip3 install -r /home/${NB_USER}/requirements.txt \
  && rm /home/${NB_USER}/requirements.txt \
  && python3 -m bash_kernel.install \
  && python3 -m spacy download en_core_web_sm

# requires seperate install for some reason
RUN pip3 install "pyrsm>=0.5.0" twine keyring
# RUN pip3 install -vvv git+git://github.com/vnijs/pyrsm@master

# RUN pip install jupyter-rsession-proxy
RUN pip3 install -vvv git+git://github.com/jupyterhub/jupyter-rsession-proxy@master
# RUN jupyter labextension install @jupyterlab/server-proxy
ENV RSESSION_PROXY_RSTUDIO_1_4=yes
ENV PATH="${PATH}:/usr/lib/rstudio-server/bin"

RUN curl -sL https://deb.nodesource.com/setup_12.x | bash \
  && apt-get install -y nodejs \
  && npm install -g npm

RUN jupyter labextension install \
  @jupyter-widgets/jupyterlab-manager \
  @jupyterlab/git \
  jupyterlab-jupytext@1.2.2 \
  @ryantam626/jupyterlab_code_formatter \
  @jupyterlab/server-proxy \
  qgrid2 \
  @jupyterlab/shortcutui \
  @lckr/jupyterlab_variableinspector \
  jupyterlab-skip-traceback 

RUN git clone https://github.com/vnijs/jupyterlab_spellchecker /opt/jupyter/jupyterlab_spellchecker \
  && cd /opt/jupyter/jupyterlab_spellchecker \   
  && npm install \
  && npm run build \
  && jupyter labextension link . 

  # maybe not quite ready for prime-time?
  # @krassowski/jupyterlab-lsp \
  # adding wavy lines to the spell checker extension
  # @ijmbarr/jupyterlab_spellchecker

# RUN pip3 install git+https://github.com/jseabold/jupyterlab-sql.git@support-v2
RUN pip3 install git+https://github.com/joequant/jupyterlab-sql.git@support-v2

RUN jupyter serverextension enable \
  --py jupyterlab_code_formatter --system \
  && jupyter serverextension enable \
  --py jupyterlab_git --system \
  && jupyter serverextension enable \
  --py --sys-prefix jupyter_server_proxy --system \
  && jupyter serverextension enable \
  --py --sys-prefix jupyterlab_sql --system \
  && jupyter lab build \
  && chown ${NB_USER}:shiny -R /var/lib/shiny-server 

# just for nbgrader
RUN jupyter nbextension install --sys-prefix --py nbgrader --overwrite \
  && jupyter nbextension enable --sys-prefix --py nbgrader \ 
  && jupyter serverextension enable --sys-prefix --py nbgrader

# install the R kernel for Jupyter Lab
RUN R -e 'install.packages("IRkernel"); IRkernel::installspec(user = FALSE)'

# install google chrome
RUN wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - \
  && sh -c 'echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google-chrome.list' \
  && apt-get -y update \
  && apt-get install -y google-chrome-stable \
  && wget -O /tmp/chromedriver.zip http://chromedriver.storage.googleapis.com/`curl -sS chromedriver.storage.googleapis.com/LATEST_RELEASE`/chromedriver_linux64.zip \
  && unzip /tmp/chromedriver.zip chromedriver -d /usr/local/bin/ \
  && chmod 777 /usr/local/bin/chromedriver \
  && rm -rf /tmp/* 

# copy logo for use with jupyterlab
COPY images/logo200.svg /opt/radiant/logo.svg

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

# codeserver version
# ENV CODE_SERVER="3.4.1"
# ENV CODE_SERVER="3.9.3" # keeps throwing reconnect
ENV CODE_SERVER="3.9.0"

RUN cd /opt \
  && mkdir /opt/code-server \
  && cd /opt/code-server \
  && wget -qO- https://github.com/cdr/code-server/releases/download/v${CODE_SERVER}/code-server-${CODE_SERVER}-linux-amd64.tar.gz | tar zxvf - --strip-components=1

# locations to store vscode / code-server settings
ARG CODE_WORKINGDIR="/home/$NB_USER/git" 
ENV CODE_WORKINGDIR="${CODE_WORKINGDIR}" \
  CODE_USER_DATA_DIR="/home/$NB_USER/.rsm-msba/share/code-server" \
  CODE_EXTENSIONS_DIR="/home/$NB_USER/.rsm-msba/share/code-server/extensions" \
  CODE_BUILTIN_EXTENSIONS_DIR="/opt/code-server/extensions" \
  PATH=/opt/code-server:$PATH

# make environment variable available from Rstudio
RUN echo "CODE_EXTENSIONS_DIR=${CODE_EXTENSIONS_DIR}" >> /etc/R/Renviron.site

# setup for code-server (aka vscode)
COPY images/vscode.svg /opt/code-server/vscode.svg
COPY settings.json /opt/code-server/settings.json
COPY setup.sh /usr/local/bin/setup
RUN chmod +x /usr/local/bin/setup

# update R-packages
RUN R -e 'remotes::install_github("vnijs/Diagrammer", upgrade = "never")' \
  -e 'remotes::install_github("bmschmidt/wordVectors", upgrade = "never")' \
  -e 'install.packages("igraph", repos = "https://cran.rstudio.com")' \
  -e 'options(HTTPUserAgent = sprintf("R/%s R (%s)", getRversion(), paste(getRversion(), R.version$platform, R.version$arch, R.version$os)))' \
  -e 'options(repos = c(RSM = "https://rsm-compute-01.ucsd.edu:4242/rsm-msba/__linux__/focal/latest", RSPM = "https://packagemanager.rstudio.com/all/__linux__/focal/latest", CRAN = "https://cloud.r-project.org"))' \
  -e 'install.packages("rWishart")' \ 
  -e 'radiant.update::radiant.update()'

ENV CMDSTAN_VERSION="2.26.1"

RUN install_cmdstan -d /opt/cmdstan -v $CMDSTAN_VERSION

# settings for local install of python packages 
ENV PYTHONUSERBASE=${PYBASE} \
  JUPYTER_PATH=${PYBASE}/share/jupyter \
  JUPYTER_RUNTIME_DIR=/tmp/jupyter/runtime \
  JUPYTER_CONFIG_DIR=${PYBASE}/jupyter \
  SHELL=/bin/zsh \
  CMDSTAN="/opt/cmdstan/cmdstan-${CMDSTAN_VERSION}"

# updating the supervisord.conf file for Jupyter
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Copy the launch script into the image
ADD https://raw.githubusercontent.com/radiant-rstats/docker/master/launch-rsm-msba.sh /opt/launch.sh
RUN chmod 777 /opt/launch.sh

# adding a ligature font
# from https://www.jetbrains.com/lp/mono/
RUN mkdir -p /usr/share/fonts/truetype/ligature
COPY ./fonts/*.ttf /usr/share/fonts/truetype/ligature
RUN chmod 644 /usr/share/fonts/truetype/ligature/*
RUN wget https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Regular.ttf
RUN fc-cache -fv

EXPOSE 8989 8765 22

RUN addgroup ${NB_USER} postgres
COPY jupyter_notebook_config.py /etc/jupyter/

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]

RUN git clone https://github.com/vnijs/gitgadget.git /srv/shiny-server/gitgadget/ \
  && chown shiny:shiny -R /srv/shiny-server

COPY images/gitgadget.svg /opt/gitgadget/gitgadget.svg

# oh-my-zsh
RUN sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" \
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
RUN apt-get install -y libnode-dev

USER ${NB_USER}
ENV HOME /home/${NB_USER}
