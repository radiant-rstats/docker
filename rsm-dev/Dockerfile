FROM vnijs/rsm-msba:latest

MAINTAINER Vincent Nijs "radiant@rady.ucsd.edu"

ARG DOCKERHUB_VERSION_UPDATE
ENV DOCKERHUB_VERSION=${DOCKERHUB_VERSION_UPDATE}

## install the bash kernel
COPY requirements.txt /home/${NB_USER}/requirements.txt

## from https://github.com/takluyver/bash_kernel
RUN pip3 install -r /home/${NB_USER}/requirements.txt \
  && rm /home/${NB_USER}/requirements.txt \
  && python3 -m bash_kernel.install

## extension not supported in jupyterlab >= 0.35
# && jupyter labextension install @jupyterlab/shortcutui \
# Clone the repo to your local environment
#RUN git clone https://github.com/jupyterlab/jupyterlab-shortcutui.git \
#  && cd jupyterlab-shortcutui \
#  && npm install \
#  && npm run build \
#  && jupyter labextension link . \
#  && cd ../ \
#  && rm -rf jupyterlab-shortcutui

## install the variable inspector
# RUN git clone https://github.com/lckr/jupyterlab-variableInspector \
#  && cd jupyterlab-variableInspector \
#  && npm install \
#  && npm run build  \
#  && jupyter labextension install . \
#  && cd ../ \
#  && rm -rf jupyterlab-variableInspector

## install the typescript kernel
# RUN npm --unsafe-perm install -g itypescript \
#  && its --ts-install=global

## install the javascript kernel
RUN npm --unsafe-perm install -g ijavascript \
  && ijsinstall --install=global

## update radiant to development version
#RUN R -e 'remotes::install_github("radiant-rstats/radiant.data", upgrade = "never")' \
#  -e 'remotes::install_github("radiant-rstats/radiant.basics", upgrade = "never")' \
#  -e 'remotes::install_github("radiant-rstats/radiant.design", upgrade = "never")' \
#  -e 'remotes::install_github("radiant-rstats/radiant.model", upgrade = "never")' \
#  -e 'remotes::install_github("radiant-rstats/radiant.multivariate", upgrade = "never")'

EXPOSE 8080 8787 8989

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
