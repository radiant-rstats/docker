FROM vnijs/rsm-msba-spark:latest

LABEL Vincent Nijs "radiant@rady.ucsd.edu"

ARG DOCKERHUB_VERSION_UPDATE
ENV DOCKERHUB_VERSION=${DOCKERHUB_VERSION_UPDATE}
ENV DEBIAN_FRONTEND=noninteractive

# install the variable inspector
# RUN git clone https://github.com/lckr/jupyterlab-variableInspector \
#  && cd jupyterlab-variableInspector \
#  && npm install \
#  && npm run build  \
#  && jupyter labextension install . \
#  && cd ../ \
#  && rm -rf jupyterlab-variableInspector

# install the typescript kernel
RUN npm --unsafe-perm install -g itypescript \
  && its --install=global

# install the javascript kernel
RUN npm --unsafe-perm install -g ijavascript \
  && ijsinstall --install=global

# update R-packages
RUN R -e 'radiant.update::radiant.update()'

# update radiant to development version
# RUN R -e 'remotes::install_github("radiant-rstats/radiant.data", upgrade = "never")' \
#  -e 'remotes::install_github("radiant-rstats/radiant.basics", upgrade = "never")' \
#  -e 'remotes::install_github("radiant-rstats/radiant.design", upgrade = "never")' \
#  -e 'remotes::install_github("radiant-rstats/radiant.model", upgrade = "never")' \
#  -e 'remotes::install_github("radiant-rstats/radiant.multivariate", upgrade = "never")'

EXPOSE 8080 8787 8989 8765

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
