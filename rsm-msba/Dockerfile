FROM vnijs/radiant:latest

MAINTAINER Vincent Nijs "radiant@rady.ucsd.edu"
ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update \
  && apt-get -y upgrade \
  && apt-get -y install --no-install-recommends \
    python3-venv \
    python3-virtualenv \
    libzmq3-dev \
    gpg-agent

## install python packages
COPY py_requirements.txt /home/${NB_USER}/py_requirements.txt
RUN pip3 install --upgrade -r /home/${NB_USER}/py_requirements.txt

ENV APT_KEY_DONT_WARN_ON_DANGEROUS_USAGE=DontWarn
RUN curl -sL https://deb.nodesource.com/setup_10.x | bash \
  && apt-get install -y nodejs \
  && npm install -g npm \
  && jupyter labextension install @jupyter-widgets/jupyterlab-manager \
  ## extension does not yet support current version of jupyterlab
  # && jupyter labextension install @jupyterlab/shortcutui \
  && jupyter labextension install @jupyterlab/git \
  && jupyter serverextension enable --py jupyterlab_git --system

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

## copy dbase connections for use with rsm-msba/docker-rsm-msba-pg.yml
COPY connections/ /etc/rstudio/connections

## update R-packages
RUN R -e 'radiant.update::radiant.update()'

## updating the supervisord.conf file for Jupyter
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

EXPOSE 80 8787 8989

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
