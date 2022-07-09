FROM vnijs/rsm-jupyter-rs:latest

# Fix DL4006
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

RUN npm install -g configurable-http-proxy

COPY files/start.sh /usr/local/bin/
COPY files/start-notebook.sh /usr/local/bin/
COPY files/start-singleuser.sh /usr/local/bin/

## CUDA
# COPY files/cuda.sh /opt/cuda/cuda.sh
# RUN sh /opt/cuda/cuda.sh

# we probably also need something like the below
# https://github.com/rocker-org/rocker-versioned2/blob/95a84fa90a107026eea69090e8b03dd21f731e7f/scripts/config_R_cuda.sh

# add jupyterhub_config.py. It could even reside in /srv/jupyterhub, not sure at the moment
COPY files/jupyterhub_config.py /etc/jupyter

# create NB_USER user with UID=1000 and in the 'users' group
# and make sure these dirs are writable by the `users` group.
USER root

RUN groupadd wheel -g 11 && \
    echo "auth required pam_wheel.so use_uid" >> /etc/pam.d/su && \
    chmod g+w /etc/passwd && \
    fix-permissions $HOME && \
    fix-permissions /opt && \
    mkdir /var/log/rstudio-server && \
    fix-permissions /var/log/rstudio-server && \
    fix-permissions /var/lib/rstudio-server

ENV JUPYTER_ENABLE_LAB=1

#NOTE: check env setting in jupyterhub_config()

# The below sets up Rstudio to use the host username and not NB_USER
# ARG OPENBLAS_NUM_THREADS=${OPENBLAS_NUM_THREADS:-8}
# ENV OPENBLAS_NUM_THREADS=$OPENBLAS_NUM_THREADS
# ARG OMP_NUM_THREADS=${OMP_NUM_THREADS:-8}
# ENV OMP_NUM_THREADS=$OMP_NUM_THREADS

# RUN sudo echo "HOME=/home/${NB_USER}" >> /usr/local/lib/R/etc/Renviron.site \
#     && echo "USER=${NB_USER}" >> /usr/local/lib/R/etc/Renviron.site \
#     && echo "OPENBLAS_NUM_THREADS=$OPENBLAS_NUM_THREADS" >> /usr/local/lib/R/etc/Renviron.site \
#     && echo "OMP_NUM_THREADS=$OMP_NUM_THREADS" >> /usr/local/lib/R/etc/Renviron.site \
#     && echo 'RhpcBLASctl::blas_set_num_threads(Sys.getenv("OPENBLAS_NUM_THREADS"))' >> /usr/local/lib/R/etc/Renviron.site \
#     && echo 'RhpcBLASctl::omp_set_num_threads(Sys.getenv("OMP_NUM_THREADS"))' >> /usr/local/lib/R/etc/Renviron.site

RUN conda remove -y --force jupyterlab_code_formatter 
# \ && pip install jupyterlab_code_formatter

# Copy the launch script into the image
COPY launch-rsm-jupyterhub.sh /opt/launch.sh
COPY files/setup-jupyterhub.sh /usr/local/bin/setup
RUN fix-permissions /usr/local/bin \
    && chmod 755 /usr/local/bin/* \
    && chmod 755 /opt/launch.sh

ENV TINI_VERSION v0.18.0
ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini /tini
RUN sudo chmod +x /tini

ENTRYPOINT ["/tini", "-g", "--"]
CMD ["start-notebook.sh"]

USER ${NB_UID}
ENV HOME /home/${NB_USER}
WORKDIR "${HOME}"
