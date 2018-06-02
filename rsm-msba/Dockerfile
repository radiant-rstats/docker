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
  rpy2

## copy reticulate and python examples to home directory
COPY python/ /home/rstudio/python
RUN chown -R rstudio:rstudio /home/rstudio/python/

## updating the supervisord.conf file for Jupyter
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

EXPOSE 80 8787 8888

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
