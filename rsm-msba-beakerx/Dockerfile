FROM vnijs/rsm-msba-spark:latest

LABEL Vincent Nijs "radiant@rady.ucsd.edu"

ARG DOCKERHUB_VERSION_UPDATE
ENV DOCKERHUB_VERSION=${DOCKERHUB_VERSION_UPDATE}

# install beakerx
COPY requirements.txt /home/${NB_USER}/requirements.txt
RUN pip3 install -r /home/${NB_USER}/requirements.txt \
  && beakerx install \
  && jupyter labextension install beakerx-jupyterlab \
  && rm /home/${NB_USER}/requirements.txt

# removing kernels as suggested by JD Long (@CMastication)
RUN rm -rf /usr/share/jupyter/kernels/clojure \
  && rm -rf /usr/share/jupyter/kernels/groovy \
  && rm -rf /usr/share/jupyter/kernels/java \
  && rm -rf /usr/share/jupyter/kernels/kotlin \
  && rm -rf /usr/share/jupyter/kernels/scala

# update R-packages
RUN R -e 'radiant.update::radiant.update()'

# update radiant to development version
# RUN R -e 'remotes::install_github("radiant-rstats/radiant.data", upgrade = "never")' \
#   -e 'remotes::install_github("radiant-rstats/radiant.basics", upgrade = "never")' \
#   -e 'remotes::install_github("radiant-rstats/radiant.design", upgrade = "never")' \
#   -e 'remotes::install_github("radiant-rstats/radiant.model", upgrade = "never")' \
#   -e 'remotes::install_github("radiant-rstats/radiant.multivariate", upgrade = "never")'

EXPOSE 8080 8787 8989 8765

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
