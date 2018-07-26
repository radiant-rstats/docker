FROM vnijs/radiant:latest

MAINTAINER Vincent Nijs "radiant@rady.ucsd.edu"

## Installing python packages
RUN pip3 install jupyter \
  jupyterlab \
  ipywidgets \
  pandas \
  numexpr \
  matplotlib \
  scipy \
  seaborn \
  scikit-learn \
  sympy \
  cython \
  patsy \
  statsmodels \
  cloudpickle \
  dill \
  numba \
  bokeh \
  sqlalchemy \
  vincent \
  beautifulsoup4 \
  protobuf \
  xlrd \
  tensorflow \
  keras \
  rpy2 \
  plotly \
  dash \
  dash-renderer \
  dash-html-components \
  dash-core-components \
  pystan \
  selenium \
  tweepy \
  nltk


RUN DEBIAN_FRONTEND=noninteractive \
  apt-get -y install --no-install-recommends\
    libzmq3-dev \
    gpg-agent

ENV APT_KEY_DONT_WARN_ON_DANGEROUS_USAGE=DontWarn

## don't use nodejs 10 until this issue is resolved
## https://github.com/jupyter-widgets/ipywidgets/issues/2061
# RUN curl -sL https://deb.nodesource.com/setup_10.x | bash
RUN curl -sL https://deb.nodesource.com/setup_9.x | bash
# RUN apt-get install -y nodejs-legacy
RUN apt-get install -y nodejs
RUN npm install -g npm
RUN jupyter labextension install @jupyter-widgets/jupyterlab-manager

RUN R -e 'install.packages(c("repr", "IRdisplay", "crayon", "pbdZMQ", "uuid"))' -e 'devtools::install_github("IRkernel/IRkernel")'
RUN R -e 'IRkernel::installspec(user = FALSE)'

# install google chrome
RUN wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add -
RUN sh -c 'echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google-chrome.list'
RUN apt-get -y update
RUN apt-get install -y google-chrome-stable

## chromedriver
RUN wget -O /tmp/chromedriver.zip http://chromedriver.storage.googleapis.com/`curl -sS chromedriver.storage.googleapis.com/LATEST_RELEASE`/chromedriver_linux64.zip
RUN unzip /tmp/chromedriver.zip chromedriver -d /usr/local/bin/

ENV PYTHONUSERBASE=/home/rstudio/.rsm-msba
# ENV PYTHONPATH=/home/rstudio/.rsm-msba/site-packages:$PYTHONPATH:
ENV JUPYTER_PATH=/home/rstudio/.rsm-msba/share/jupyter
ENV JUPYTER_RUNTIME_DIR=/home/rstudio/.rsm-msba/share/jupyter/runtime
ENV JUPYTER_CONFIG_DIR=/home/rstudio/.rsm-msba/jupyter

## copy reticulate and python examples to home directory
COPY python/ /home/rstudio/python
RUN chown -R rstudio:rstudio /home/rstudio/python/

## copy dbase connections
COPY connections/ /etc/rstudio/connections

## currently needed for cache and jupyter kernels
RUN chown -R rstudio:rstudio /root

## updating the supervisord.conf file for Jupyter
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

EXPOSE 80 8787 8888

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
