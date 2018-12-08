FROM vnijs/rsm-msba-spark:latest

MAINTAINER Vincent Nijs "radiant@rady.ucsd.edu"

ARG NB_USER="rstudio"
ARG NB_UID="1001"
ARG NB_GID="100"

RUN pip3 install jupyterlab --upgrade

# nbrsessionproxy (used for rserver integration)
RUN  pip3 install nbrsessionproxy \
  && jupyter serverextension enable  --py --sys-prefix nbrsessionproxy \
  && jupyter nbextension     install --py --sys-prefix nbrsessionproxy \
  && jupyter nbextension     enable  --py --sys-prefix nbrsessionproxy

RUN git clone https://github.com/jupyterhub/nbrsessionproxy /opt/nbrsessionproxy \
  && pip3 install -e /opt/nbrsessionproxy \
  && jupyter serverextension enable --py nbrsessionproxy \
  && jupyter labextension link /opt/nbrsessionproxy/jupyterlab-rsessionproxy

ENV PATH="${PATH}:/usr/lib/rstudio-server/bin"
ENV LD_LIBRARY_PATH="/usr/lib/R/lib:/lib:/usr/lib/x86_64-linux-gnu:/usr/lib/jvm/java-7-openjdk-amd64/jre/lib/amd64/server"

# Temp fix. There is a bug in one of the libraries being used. I updated one line and then overwrite the file with the fixed version.
COPY handlers.py /usr/local/lib/python3.6/dist-packages/nbserverproxy/handlers.py

ADD fix-permissions /usr/local/bin/fix-permissions

# Create jovyan user with UID=1000 and in the 'users' group
# and make sure these dirs are writable by the `users` group.
RUN groupadd wheel -g 11 \
  && echo "auth required pam_wheel.so use_uid" >> /etc/pam.d/su \
  && useradd -m -s /bin/bash -N -u $NB_UID $NB_USER \
  chmod g+w /etc/passwd \
  /usr/local/bin/fix-permissions $HOME

## install jupyterhub
RUN pip3 install jupyterhub

## update R-packages
RUN R -e 'radiant.update::radiant.update()'

# Add scripts from https://github.com/jupyter/docker-stacks/tree/master/base-notebook
COPY start.sh /usr/local/bin/
COPY start-notebook.sh /usr/local/bin/
COPY start-singleuser.sh /usr/local/bin/
COPY jupyter_notebook_config.py /etc/jupyter/

## path for local install of python packages from Rstudio or Jupyter Lab
ENV PYBASE=/home/${NB_USER}/.rsm-msba

## if user is rstudio R settings do not need to be updated
# RUN echo "PYTHONUSERBASE=${PYBASE}" >> /etc/R/Renviron.site \
#  && echo "WORKON_HOME=${PYBASE}" >> /etc/R/Renviron.site

## path for local install of python packages from Rstudio or Jupyter Lab
ENV PYTHONUSERBASE=${PYBASE} \
  JUPYTER_PATH=${PYBASE}/share/jupyter \
  JUPYTER_RUNTIME_DIR=${PYBASE}/share/jupyter/runtime \
  JUPYTER_CONFIG_DIR=${PYBASE}/jupyter

ENV SHELL=/bin/bash

# Add Tini
ENV TINI_VERSION v0.18.0
ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini /tini
RUN chmod +x /tini

ENTRYPOINT ["/tini", "-g", "--"]
CMD ["start-notebook.sh"]

USER $NB_UID
