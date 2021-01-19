FROM vnijs/rsm-msba:latest
LABEL Vincent Nijs "radiant@rady.ucsd.edu"
USER root

ARG DOCKERHUB_VERSION_UPDATE
ENV DOCKERHUB_VERSION=${DOCKERHUB_VERSION_UPDATE}

ENV DEBIAN_FRONTEND=noninteractive
# installing java
RUN apt-get -y update \
  && apt-get install --no-install-recommends -y openjdk-8-jre-headless openjdk-8-jdk-headless ca-certificates-java \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/* \
  && R CMD javareconf

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
  PYTHONPATH="$SPARK_HOME/python:$SPARK_HOME/python/build:$SPARK_HOME/python/lib/py4j-0.10.7-src.zip:$PYTHONPATH"

RUN echo "SPARK_HOME=${SPARK_HOME}" >> /etc/R/Renviron.site

RUN mkdir $HADOOP_HOME \
  && cd $HADOOP_HOME \
  && wget -qO- "http://archive.apache.org/dist/hadoop/common/hadoop-$HADOOP_VERSION/hadoop-$HADOOP_VERSION.tar.gz" | tar zxvf - --strip-components=1 \
  && rm -rf $HADOOP_HOME/share/doc \
  && chown -R root:root $HADOOP_HOME  \
  && rm -rf *.tar.gz

# install the R kernel for Jupyter Lab
RUN R -e 'options(spark.install.dir = "/opt")' \
  -e 'sparklyr::spark_install(version = Sys.getenv("SPARK_VERSION"), hadoop_version = Sys.getenv("BUILT_FOR_HADOOP_VERSION"))'

# install python packages
COPY requirements.txt /home/${NB_USER}/requirements.txt
RUN pip3 install -r /home/${NB_USER}/requirements.txt \
  && rm /home/${NB_USER}/requirements.txt

# update R-packages
RUN R -e 'options(repos = c(RSM = "https://rsm-compute-01.ucsd.edu:4242/rsm-msba/__linux__/focal/latest", RSPM = "https://packagemanager.rstudio.com/all/__linux__/focal/latest", CRAN = "https://cloud.r-project.org"))' \
  -e 'radiant.update::radiant.update()'

# Copy the launch script into the image
ADD https://raw.githubusercontent.com/radiant-rstats/docker/master/launch-rsm-msba-spark.sh /opt/launch.sh
RUN chmod 777 /opt/launch.sh

# Configure Hadoop 
COPY ./hadoop-config/core-site.xml $HADOOP_HOME/etc/hadoop/core-site.xml
COPY ./hadoop-config/hdfs-site.xml $HADOOP_HOME/etc/hadoop/hdfs-site.xml
RUN chmod 777 -R $HADOOP_HOME

EXPOSE 8989 8765 22

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]

USER ${NB_USER}
ENV HOME /home/${NB_USER}
