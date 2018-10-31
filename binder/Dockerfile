## based on https://github.com/rocker-org/binder/blob/master/Dockerfile
FROM vnijs/rsm-msba:latest

# The `rsession` binary that is called by nbrsessionproxy to start R doesn't seem to start
# without this being explicitly set
ENV LD_LIBRARY_PATH /usr/local/lib/R/lib

RUN apt-get update && \
    apt-get -y install python3-dev && \
    apt-get purge && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN git clone https://github.com/jupyterhub/nbserverproxy /opt/nbrsessionproxy
RUN pip3 install -e /opt/nbrsessionproxy && \
    jupyter serverextension enable --py nbrsessionproxy && \
    jupyter labextension link /opt/nbrsessionproxy/jupyterlab-rsessionproxy

CMD jupyter --ip 0.0.0.0

## If extending this image, remember to switch back to USER root to apt-get

