FROM vnijs/rsm-msba-spark:latest

MAINTAINER Vincent Nijs "radiant@rady.ucsd.edu"

## install jupyterhub
RUN pip3 install jupyterhub

## update R-packages
RUN R -e 'radiant.update::radiant.update()'

# Add scripts from https://github.com/jupyter/docker-stacks/tree/master/base-notebook
COPY start.sh /usr/local/bin/
COPY start-notebook.sh /usr/local/bin/
COPY start-singleuser.sh /usr/local/bin/
COPY jupyter_notebook_config.py /etc/jupyter/

# EXPOSE 80 8787 8989

# CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]

