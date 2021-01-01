FROM jupyter/minimal-notebook

USER root

RUN apt-get update -qq && \
    apt-get install -y --no-install-recommends \
	software-properties-common \
	gdebi-core \
	dirmngr \
	gpg-agent \
	strace \
	lsof \
	less

RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E298A3A825C0D65DFD57CBB651716619E084DAB9
RUN add-apt-repository -y 'deb https://cloud.r-project.org/bin/linux/ubuntu focal-cran40/'

RUN apt-get update -qq -y && \
    apt install -y r-base r-base-core r-recommended

# ENV RSTUDIO_VERSION 1.2.1335
# ENV RSTUDIO_VERSION 1.3.1056
ENV RSTUDIO_VERSION 1.3.1081

RUN wget --quiet https://download2.rstudio.org/server/bionic/amd64/rstudio-server-${RSTUDIO_VERSION}-amd64.deb
RUN gdebi -n rstudio-server-${RSTUDIO_VERSION}-amd64.deb

USER $NB_USER
RUN pip install jupyter-rsession-proxy
RUN jupyter labextension install @jupyterlab/server-proxy

USER jovyan
ENV PATH="${PATH}:/usr/lib/rstudio-server/bin"

CMD jupyter notebook --ip=0.0.0.0 --port=8888 --NotebookApp.token=