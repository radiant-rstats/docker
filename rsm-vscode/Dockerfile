# FROM ubuntu:focal
FROM rocker/r-ver
LABEL Vincent Nijs "radiant@rady.ucsd.edu"
USER root

ARG NB_USER="jovyan"
ARG NB_UID="1000"
ARG NB_GID="100"
ARG DOCKERHUB_VERSION_UPDATE
ARG PASSWORD=${PASSWORD:-rstudio}
ARG PGPASSWORD=${PGPASSWORD:-postgres}
ARG PYBASE=/home/${NB_USER}/.rsm-msba
ENV SPARK_VERSION=2.4 \
    BUILT_FOR_HADOOP_VERSION=2.7 \
    HADOOP_VERSION=2.7.7 \ 
    JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64 
ENV NB_USER=${NB_USER} \
    DEBIAN_FRONTEND=noninteractive \
    DOCKERHUB_VERSION=${DOCKERHUB_VERSION_UPDATE} \
    POSTGRES_VERSION=12 \
    PGPASSWORD=${PGPASSWORD} \
    SHELL=/bin/zsh 

ENV HADOOP_HOME="/opt/hadoop-${HADOOP_VERSION}"
ENV HADOOP_CONF_DIR="$HADOOP_HOME/etc/hadoop" \
    PATH=$PATH:"$HADOOP_HOME/bin" \
    SPARK_PACKAGE="spark-${SPARK_VERSION}-bin-hadoop${BUILT_FOR_HADOOP_VERSION}" \
    SPARK_DIST_CLASSPATH="$HADOOP_HOME/etc/hadoop/*:$HADOOP_HOME/share/hadoop/common/lib/*:$HADOOP_HOME/share/hadoop/common/*:$HADOOP_HOME/share/hadoop/hdfs/*:$HADOOP_HOME/share/hadoop/hdfs/lib/*:$HADOOP_HOME/share/hadoop/hdfs/*:$HADOOP_HOME/share/hadoop/yarn/lib/*:$HADOOP_HOME/share/hadoop/yarn/*:$HADOOP_HOME/share/hadoop/mapreduce/lib/*:$HADOOP_HOME/share/hadoop/mapreduce/*:$HADOOP_HOME/share/hadoop/tools/lib/*" 
ENV SPARK_HOME="/opt/spark-${SPARK_VERSION}-bin-hadoop${BUILT_FOR_HADOOP_VERSION}" \
    PYSPARK_PYTHON=/usr/bin/python3 \
    PYSPARK_DRIVER_PYTHON=jupyter \
    PYSPARK_DRIVER_PYTHON_OPTS=lab
ENV PATH=$PATH:${SPARK_HOME}/bin \
    PYTHONPATH="$SPARK_HOME/python:$SPARK_HOME/python/build:$SPARK_HOME/python/lib/py4j-0.10.7-src.zip:$PYTHONPATH"

RUN apt-get update \
    && apt-get -y upgrade \
    && apt-get install -y --no-install-recommends \
    bash-completion \
    ca-certificates \
    file \
    fonts-texgyre \
    g++ \
    gfortran \
    gsfonts \
    libblas-dev \
    libbz2-1.0 \
    libcurl4 \
    libopenblas-dev \
    libpangocairo-1.0-0 \
    libpcre3 \
    libpng16-16 \
    libreadline8 \
    libtiff5 \
    liblzma5 \
    locales \
    make \
    unzip \
    zip \
    zlib1g \
    wget \
    software-properties-common \
    && add-apt-repository --yes "ppa:jonathonf/vim" \
    && apt-get update

# Configure default locale, see https://github.com/rocker-org/rocker/issues/19
RUN echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen \
    && locale-gen en_US.utf8 \
    && /usr/sbin/update-locale LANG=en_US.UTF-8

ENV LC_ALL en_US.UTF-8
ENV LANG en_US.UTF-8

# TeX for the rmarkdown package in RStudio, and pandoc is also useful
RUN apt-get install -y \
    texlive \
    texlive-base \
    texlive-latex-extra \
    texlive-pstricks \
    texlive-xetex \
    && apt-get -y autoremove \
    && apt-get clean \
    && apt-get update

RUN apt-get -y install --no-install-recommends\
    apt-transport-https \
    gdebi-core \
    libcurl4-openssl-dev \
    libopenmpi-dev \
    libpq-dev \
    libssh2-1-dev \
    libssl-dev \
    libxml2 \
    libxml2-dev \
    libicu-dev \
    libgdal-dev \
    libproj-dev \
    libgsl-dev \
    cmake \
    cargo \
    libudunits2-dev \
    r-base \
    r-base-dev \
    r-cran-pbdzmq \
    r-cran-catools \
    r-cran-bitops \
    unixodbc \
    unixodbc-dev \
    odbc-postgresql \
    libsqliteodbc \
    vim \
    net-tools \
    inetutils-ping \
    curl \
    git \
    nmap \
    socat \
    sudo \
    libcairo2-dev \
    libxt-dev \
    xclip \
    xsel \
    bzip2 \
    python3-dev \
    python3-pip \
    python3-venv \
    python3-virtualenv \
    supervisor \
    libc6 \
    libzmq5 \
    libmagick++-dev \
    ed \
    rsync \
    vifm \
    pandoc \
    libzmq3-dev \
    gpg-agent \
    graphviz \
    openjdk-8-jre-headless \
    openjdk-8-jdk-headless \
    ca-certificates-java \
    postgresql-${POSTGRES_VERSION} \
    postgresql-client-${POSTGRES_VERSION} \
    postgresql-contrib-${POSTGRES_VERSION} \
    openssh-server \
    && apt-get -y autoremove \
    && apt-get update \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    && R CMD javareconf

RUN useradd -m -s /bin/bash -N -u $NB_UID $NB_USER \
    && echo "${NB_USER}:${PASSWORD}" | chpasswd \
    && addgroup ${NB_USER} staff \
    && adduser ${NB_USER} sudo && echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers \
    && mkdir -p /var/run/sshd

RUN mkdir $HADOOP_HOME \
    && cd $HADOOP_HOME \
    && wget -qO- "http://archive.apache.org/dist/hadoop/common/hadoop-$HADOOP_VERSION/hadoop-$HADOOP_VERSION.tar.gz" | tar zxvf - --strip-components=1 \
    && rm -rf $HADOOP_HOME/share/doc \
    && chown -R root:root $HADOOP_HOME  \
    && rm -rf *.tar.gz

# Run the rest of the commands as the postgres user
USER postgres

# create a postgres role for ${NB_USER} with "postgres" as the password
# create a database "rsm-docker" owned by the ${NB_USER} role.
RUN /etc/init.d/postgresql start \
    && psql --command "CREATE USER ${NB_USER} WITH SUPERUSER PASSWORD '${PGPASSWORD}';" \
    && createdb -O ${NB_USER} rsm-docker

COPY postgresql.conf /etc/postgresql/${POSTGRES_VERSION}/main/postgresql.conf
COPY pg_hba.conf /etc/postgresql/${POSTGRES_VERSION}/main/pg_hba.conf

USER root

# install google chrome
RUN wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - \
    && sh -c 'echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google-chrome.list' \
    && apt-get -y update \
    && apt-get install -y google-chrome-stable \
    && wget -O /tmp/chromedriver.zip http://chromedriver.storage.googleapis.com/`curl -sS chromedriver.storage.googleapis.com/LATEST_RELEASE`/chromedriver_linux64.zip \
    && unzip /tmp/chromedriver.zip chromedriver -d /usr/local/bin/ \
    && chmod 777 /usr/local/bin/chromedriver \
    && rm -rf /tmp/* 

# installing some basic r-packages
RUN R -e 'install.packages("igraph", repos = "https://cran.rstudio.com")' \
    -e 'options(HTTPUserAgent = sprintf("R/%s R (%s)", getRversion(), paste(getRversion(), R.version$platform, R.version$arch, R.version$os)))' \
    -e 'source("https://raw.githubusercontent.com/radiant-rstats/minicran/gh-pages/rsm-msba.R")' \
    -e 'remotes::install_github("rstudio/renv")' \
    -e 'remotes::install_github("vnijs/Diagrammer", upgrade = "never")' \ 
    -e 'remotes::install_github("bmschmidt/wordVectors", upgrade = "never")' \
    -e 'source("https://install-github.me/REditorSupport/languageserver")' \ 
    -e 'options(spark.install.dir = "/opt")' \
    -e 'sparklyr::spark_install(version = Sys.getenv("SPARK_VERSION"), hadoop_version = Sys.getenv("BUILT_FOR_HADOOP_VERSION"))'

# install lightGBM
# RUN git clone --recursive https://github.com/Microsoft/LightGBM \
#     && cd LightGBM \
#     && Rscript build_r.R \
#     && cd .. \
#     && rm -rf LightGBM

COPY clean.sh /usr/local/bin/clean
COPY userconf.sh /usr/local/bin/userconf.sh
COPY launch.sh /usr/local/bin/launch
RUN mkdir -p /var/log/supervisor \
    && chown ${NB_USER} /var/log/supervisor \
    && chmod +x /usr/local/bin/clean \
    && chmod +x /usr/local/bin/launch \ 
    && chmod +x /usr/local/bin/userconf.sh

# install python packages
COPY requirements.txt /home/${NB_USER}/requirements.txt
COPY requirements_spark.txt /home/${NB_USER}/requirements_spark.txt
RUN pip3 install -r /home/${NB_USER}/requirements.txt \
    && pip3 install -r /home/${NB_USER}/requirements_spark.txt \
    && rm /home/${NB_USER}/requirements.txt \
    && rm /home/${NB_USER}/requirements_spark.txt

ENV PYBASE=${PYBASE} \ 
    PYTHONUSERBASE=${PYBASE} \
    JUPYTER_PATH=${PYBASE}/share/jupyter \
    JUPYTER_RUNTIME_DIR=/tmp/jupyter/runtime \
    JUPYTER_CONFIG_DIR=${PYBASE}/jupyter

RUN echo "PYTHONUSERBASE=${PYBASE}" >> /etc/R/Renviron.site \
    && echo "WORKON_HOME=${PYBASE}" >> /etc/R/Renviron.site \
    && echo "NB_USER=${NB_USER}" >> /etc/R/Renviron.site \
    && echo "SPARK_HOME=${SPARK_HOME}" >> /etc/R/Renviron.site \
    && sed -i -e 's/~\/R\/x86_64/~\/.rsm-msba\/R\/x86_64/' /etc/R/Renviron

EXPOSE 8765 22

# required in rsm-vscode image
RUN chown -R postgres:postgres /var/lib/postgresql/${POSTGRES_VERSION}/ \
    && chmod -R 0700 /var/lib/postgresql/${POSTGRES_VERSION}/

# Configure Hadoop 
COPY ./hadoop-config/core-site.xml $HADOOP_HOME/etc/hadoop/core-site.xml
COPY ./hadoop-config/hdfs-site.xml $HADOOP_HOME/etc/hadoop/hdfs-site.xml
RUN chmod 777 -R $HADOOP_HOME
RUN echo "SPARK_HOME=${SPARK_HOME}" >> /etc/R/Renviron.site

# requires seperate install for some reason
RUN pip3 install 'pyrsm>=0.3.0'

RUN addgroup ${NB_USER} postgres

EXPOSE 8765 22

COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]

USER ${NB_USER}
WORKDIR /home/${NB_USER}
ENV HOME /home/${NB_USER}
