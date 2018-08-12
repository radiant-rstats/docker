FROM vnijs/radiant:latest

MAINTAINER Vincent Nijs "radiant@rady.ucsd.edu"
ENV DEBIAN_FRONTEND noninteractive

## install python packages
COPY py_requirements.txt /home/rstudio/py_requirements.txt
RUN pip3 install --upgrade -r /home/rstudio/py_requirements.txt

ENV APT_KEY_DONT_WARN_ON_DANGEROUS_USAGE=DontWarn
## don't use nodejs 10 until this issue is resolved https://github.com/jupyter-widgets/ipywidgets/issues/2061
# RUN curl -sL https://deb.nodesource.com/setup_10.x | bash
RUN apt-get -y install --no-install-recommends \
    python3-venv \
    python3-virtualenv \
    libzmq3-dev \
    gpg-agent \
  && curl -sL https://deb.nodesource.com/setup_9.x | bash \
  && apt-get install -y nodejs \
  && npm install -g npm \
  && jupyter labextension install @jupyter-widgets/jupyterlab-manager \
  && jupyter labextension install @jupyterlab/shortcutui \
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
  && unzip /tmp/chromedriver.zip chromedriver -d /usr/local/bin/

## path for local install of python packages from Rstudio or Jupyter Lab
ARG PYBASE=/home/rstudio/.rsm-msba
ENV PYTHONUSERBASE=${PYBASE}
## needed to keep jupyter --paths separate from local install
ENV JUPYTER_PATH=${PYBASE}/share/jupyter
ENV JUPYTER_RUNTIME_DIR=${PYBASE}/share/jupyter/runtime
ENV JUPYTER_CONFIG_DIR=${PYBASE}/jupyter
RUN echo "PYTHONUSERBASE=${PYBASE}" >> /etc/R/Renviron.site \
  && echo "WORKON_HOME=${PYBASE}" >> /etc/R/Renviron.site

## copy reticulate and python examples to home directory
# COPY python/ /home/rstudio/python
# RUN chown -R rstudio:rstudio /home/rstudio/python/

## copy dbase connections for use with rsm-msba/docker-rsm-msba-pg.yml
COPY connections/ /etc/rstudio/connections

## updating the supervisord.conf file for Jupyter
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

EXPOSE 80 8787 8888

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
