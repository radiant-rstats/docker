FROM vnijs/radiant

MAINTAINER Vincent Nijs "radiant@rady.ucsd.edu"

## Installing python packages
RUN pip3 install -U jupyter \
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
  pystan

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

## copy reticulate and python examples to home directory
COPY python/ /home/rstudio/python
RUN chown -R rstudio:rstudio /home/rstudio/python/

## updating the supervisord.conf file for Jupyter
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

EXPOSE 80 8787 8888

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
