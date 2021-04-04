FROM vnijs/rsm-msba-spark:latest
LABEL Vincent Nijs "radiant@rady.ucsd.edu"
USER root

ARG DOCKERHUB_VERSION_UPDATE
ENV DOCKERHUB_VERSION=${DOCKERHUB_VERSION_UPDATE}

ARG NB_USER="jovyan"
ARG NB_UID="1000"
ARG NB_GID="100"

ENV PATH="${PATH}:/usr/lib/rstudio-server/bin"
ENV LD_LIBRARY_PATH="/usr/lib/R/lib:/lib:/usr/lib/x86_64-linux-gnu:/usr/lib/jvm/java-8-openjdk-amd64/jre/lib/amd64/server"

# add scripts from https://github.com/jupyter/docker-stacks/tree/master/base-notebook
COPY fix-permissions /usr/local/bin/
COPY start.sh /usr/local/bin/
COPY start-notebook.sh /usr/local/bin/
COPY start-singleuser.sh /usr/local/bin/

## CUDA
COPY cuda.sh /opt/cuda/cuda.sh
RUN sh /opt/cuda/cuda.sh

# we probably also need something like the below
# https://github.com/rocker-org/rocker-versioned2/blob/95a84fa90a107026eea69090e8b03dd21f731e7f/scripts/config_R_cuda.sh

# updating the version added in rsm-msba
COPY jupyter_notebook_config.py /etc/jupyter/

RUN chmod +x /usr/local/bin/start.sh && \
  chmod +x /usr/local/bin/start-notebook.sh && \
  chmod +x /usr/local/bin/start-singleuser.sh && \
  chmod +x /usr/local/bin/clean &&\
  chmod +x /usr/local/bin/fix-permissions

# Create NB_USER user with UID=1000 and in the 'users' group
# and make sure these dirs are writable by the `users` group.
RUN groupadd wheel -g 11 && \
  echo "auth required pam_wheel.so use_uid" >> /etc/pam.d/su && \
  chmod g+w /etc/passwd && \
  fix-permissions $HOME && \
  fix-permissions /opt && \
  fix-permissions /var/lib/shiny-server && \
  fix-permissions /var/log/shiny-server && \
  fix-permissions /var/log/rstudio-server && \
  fix-permissions /var/lib/rstudio-server

# update R-packages
RUN R -e 'options(repos = c(RSM = "https://rsm-compute-01.ucsd.edu:4242/rsm-msba/__linux__/focal/latest", RSPM = "https://packagemanager.rstudio.com/all/__linux__/focal/latest", CRAN = "https://cloud.r-project.org"))' \
  -e 'radiant.update::radiant.update()'

# Add Tini
ENV TINI_VERSION v0.18.0
ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini /tini
RUN chmod +x /tini

COPY postgresql.conf /etc/postgresql/${POSTGRES_VERSION}/main/postgresql.conf
COPY pg_hba.conf /etc/postgresql/${POSTGRES_VERSION}/main/pg_hba.conf
# COPY profiles /etc/rstudio/

ENV JUPYTER_ENABLE_LAB=1

ARG OPENBLAS_NUM_THREADS=${OPENBLAS_NUM_THREADS:-8}
ENV OPENBLAS_NUM_THREADS=$OPENBLAS_NUM_THREADS
ARG OMP_NUM_THREADS=${OMP_NUM_THREADS:-8}
ENV OMP_NUM_THREADS=$OMP_NUM_THREADS

RUN echo "HOME=/home/${NB_USER}" >> /etc/R/Renviron.site \
  && echo "USER=${NB_USER}" >> /etc/R/Renviron.site \ 
  && echo "OPENBLAS_NUM_THREADS=$OPENBLAS_NUM_THREADS" >> /etc/R/Renviron.site \
  && echo "OMP_NUM_THREADS=$OMP_NUM_THREADS" >> /etc/R/Renviron.site \
  && echo 'RhpcBLASctl::blas_set_num_threads(Sys.getenv("OPENBLAS_NUM_THREADS"))' >> /etc/R/Rprofile.site \
  && echo 'RhpcBLASctl::omp_set_num_threads(Sys.getenv("OMP_NUM_THREADS"))' >> /etc/R/Rprofile.site

# Copy the launch script into the image
ADD https://raw.githubusercontent.com/radiant-rstats/docker/master/launch-rsm-jupyterhub.sh /opt/launch.sh
RUN chmod 777 /opt/launch.sh

ENTRYPOINT ["/tini", "-g", "--"]
CMD ["start-notebook.sh"]

# weirdness with curl lib not being available in rsm-jupyterhub 
# although it works fine in the vnijs/rsm-msba-spark
RUN apt-get update \
  && apt-get install -y curl

# COPY images/help.svg /opt/help/help.svg

# remove sudo privileges for security 
# RUN passwd --delete ${NB_USER}
# RUN deluser ${NB_USER} sudo

# set user
USER ${NB_USER}
ENV HOME /home/${NB_USER}

