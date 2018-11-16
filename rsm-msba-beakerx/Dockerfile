FROM vnijs/rsm-msba-spark:latest

MAINTAINER Vincent Nijs "radiant@rady.ucsd.edu"

## install python packages
COPY py_requirements.txt /home/rstudio/py_requirements.txt
RUN pip3 install --upgrade -r /home/rstudio/py_requirements.txt
RUN jupyter labextension install beakerx-jupyterlab

EXPOSE 80 8787 8888

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
