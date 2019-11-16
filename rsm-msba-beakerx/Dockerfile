FROM vnijs/rsm-msba-spark:latest

LABEL Vincent Nijs "radiant@rady.ucsd.edu"

ARG DOCKERHUB_VERSION_UPDATE
ENV DOCKERHUB_VERSION=${DOCKERHUB_VERSION_UPDATE}

# install beakerx
RUN pip3 install beakerx==1.4.1 \
  && beakerx install \
  && jupyter labextension install beakerx-jupyterlab 

# removing kernels as suggested by JD Long (@CMastication)
RUN rm -rf /usr/share/jupyter/kernels/clojure \
  && rm -rf /usr/share/jupyter/kernels/groovy \
  && rm -rf /usr/share/jupyter/kernels/java \
  && rm -rf /usr/share/jupyter/kernels/kotlin \
  && rm -rf /usr/share/jupyter/kernels/scala

# update R-packages
RUN R -e 'radiant.update::radiant.update(repos = "https://rsm-compute-01.ucsd.edu:4242/rsm-msba/__linux__/bionic/latest")'

EXPOSE 8080 8787 8989 8765

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
