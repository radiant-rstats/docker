FROM vnijs/rsm-msba:latest
LABEL Vincent Nijs "radiant@rady.ucsd.edu"
USER root

ARG DOCKERHUB_VERSION_UPDATE
ENV DOCKERHUB_VERSION=${DOCKERHUB_VERSION_UPDATE}

ENV DEBIAN_FRONTEND=noninteractive
# installing java
RUN apt-get -y update \
  && mkdir -p /etc/ssl/certs/java \
  && apt-get install --no-install-recommends -y openjdk-8-jre-headless openjdk-8-jdk-headless ca-certificates-java \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/* \
  && R CMD javareconf

# install nodejs so as to include npm as well
RUN curl -sL https://deb.nodesource.com/setup_12.x | sudo -E bash - \
  && sudo apt install -y nodejs

RUN sudo mkdir /srv/shiny-server/radiant/inst/app/app_cache \
    && sudo chmod 777 /srv/shiny-server/radiant/inst/app/app_cache

ENV SPARK_VERSION=3.0.1 \
  BUILT_FOR_HADOOP_VERSION=2.7 \
  HADOOP_VERSION=2.7.7 \ 
  JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64 
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
  PYTHONPATH="$SPARK_HOME/python:$SPARK_HOME/python/build:$SPARK_HOME/python/lib/py4j-0.10.9-src.zip:$PYTHONPATH"

RUN echo "SPARK_HOME=${SPARK_HOME}" >> /etc/R/Renviron.site

RUN mkdir $HADOOP_HOME \
  && cd $HADOOP_HOME \
  && wget -qO- "http://archive.apache.org/dist/hadoop/common/hadoop-$HADOOP_VERSION/hadoop-$HADOOP_VERSION.tar.gz" | tar zxvf - --strip-components=1 \
  && rm -rf $HADOOP_HOME/share/doc \
  && chown -R root:root $HADOOP_HOME  \
  && rm -rf *.tar.gz


ENV TZ="America/Los_Angeles"

# link to Rstudio's pandoc
RUN ln -sf /usr/lib/rstudio-server/bin/pandoc/pandoc /usr/local/bin/pandoc

# install the R kernel for Jupyter Lab
RUN R -e 'options(spark.install.dir = "/opt"); sparklyr::spark_install(version = Sys.getenv("SPARK_VERSION"), hadoop_version = Sys.getenv("BUILT_FOR_HADOOP_VERSION"))'

# install python packages
COPY requirements.txt /home/${NB_USER}/requirements.txt
RUN pip3 install -r /home/${NB_USER}/requirements.txt \
  && rm /home/${NB_USER}/requirements.txt

# update R-packages
RUN R -e 'options(HTTPUserAgent = sprintf("R/%s R (%s)", getRversion(), paste(getRversion(), R.version$platform, R.version$arch, R.version$os)))' \
  -e 'options(repos = c(RSM = "https://rsm-compute-01.ucsd.edu:4242/rsm-msba/__linux__/focal/latest", RSPM = "https://packagemanager.rstudio.com/all/__linux__/focal/latest", CRAN = "https://cloud.r-project.org"))' \
  -e 'radiant.update::radiant.update()'

# Copy the launch script into the image
ADD https://raw.githubusercontent.com/radiant-rstats/docker/master/launch-rsm-msba-spark.sh /opt/launch.sh
RUN sudo chmod 777 /opt/launch.sh

# Configure Hadoop 
COPY ./hadoop-config/core-site.xml $HADOOP_HOME/etc/hadoop/core-site.xml
COPY ./hadoop-config/hdfs-site.xml $HADOOP_HOME/etc/hadoop/hdfs-site.xml
RUN sudo chmod 777 -R $HADOOP_HOME

# Add Jingbo's AutoPhrase
# ADD https://github.com/shangjingbo1226/AutoPhrase/archive/master.zip /opt/AutoPhrase-master.zip
# ENV PATH="${PATH}:/opt/autophrase"
# RUN cd /opt \
#   && unzip /opt/AutoPhrase-master.zip \
#   && rm /opt/AutoPhrase-master.zip \
#   && mv /opt/AutoPhrase-master /opt/autophrase
# RUN echo "===> compile" \
#   && cd /opt/autophrase && bash compile.sh \
#   && chmod -R 755 tools/treetagger/bin/tree-tagger \
#   && setfacl -Rm u:${NB_USER}:rwX /opt/autophrase \
#   && mv data default_data \
#   && mv models default_models
# RUN echo "===> clean up..."  \
#   && rm -rf /var/cache/oracle-jdk8-installer  \
#   && apt-get clean \
#   && rm -rf /var/lib/apt/lists/*

# Uninstall tensorflow to avoid qemu error
RUN pip3 uninstall -y tensorflow tensorflow-estimator \
  && pip3 install -U https://tf.novaal.de/barcelona/tensorflow-2.6.0-cp38-cp38-linux_x86_64.whl

# usethis script
COPY usethis /usr/local/bin/usethis

# to get rid of jupyterlab_spellchecker error
RUN jupyter lab build

EXPOSE 8989 8765 22

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]

USER ${NB_USER}
ENV HOME /home/${NB_USER}
