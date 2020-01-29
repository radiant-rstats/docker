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
RUN R -e 'options(HTTPUserAgent = sprintf("R/%s R (%s)", getRversion(), paste(getRversion(), R.version$platform, R.version$arch, R.version$os)))' \
  -e 'radiant.update::radiant.update(repos = "https://rsm-compute-01.ucsd.edu:4242/rsm-msba/__linux__/bionic/latest")'

EXPOSE 8181 8787 8989 8765

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
