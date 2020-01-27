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

ENV JAVA_HOME /usr/lib/jvm/java-8-openjdk-amd64/

# Install Hadoop
ENV HADOOP_VERSION 2.7.7
ENV HADOOP_HOME /usr/hadoop-$HADOOP_VERSION
ENV HADOOP_CONF_DIR=$HADOOP_HOME/etc/hadoop
ENV PATH $PATH:$HADOOP_HOME/bin
RUN curl -sL --retry 3 \
  "http://archive.apache.org/dist/hadoop/common/hadoop-$HADOOP_VERSION/hadoop-$HADOOP_VERSION.tar.gz" \
  | gunzip \
  | tar -x -C /usr/ \
  && rm -rf $HADOOP_HOME/share/doc \
  && chown -R root:root $HADOOP_HOME

# Spark
ENV SPARK_VERSION=2.4.0 \
  BUILT_FOR_HADOOP_VERSION=2.7
ENV SPARK_PACKAGE spark-${SPARK_VERSION}-bin-hadoop${BUILT_FOR_HADOOP_VERSION}
ENV SPARK_HOME /usr/spark-${SPARK_VERSION}
ENV SPARK_DIST_CLASSPATH="$HADOOP_HOME/etc/hadoop/*:$HADOOP_HOME/share/hadoop/common/lib/*:$HADOOP_HOME/share/hadoop/common/*:$HADOOP_HOME/share/hadoop/hdfs/*:$HADOOP_HOME/share/hadoop/hdfs/lib/*:$HADOOP_HOME/share/hadoop/hdfs/*:$HADOOP_HOME/share/hadoop/yarn/lib/*:$HADOOP_HOME/share/hadoop/yarn/*:$HADOOP_HOME/share/hadoop/mapreduce/lib/*:$HADOOP_HOME/share/hadoop/mapreduce/*:$HADOOP_HOME/share/hadoop/tools/lib/*"
ENV PATH $PATH:${SPARK_HOME}/bin
RUN curl -sL --retry 3 \
  "https://archive.apache.org/dist/spark/spark-${SPARK_VERSION}/spark-${SPARK_VERSION}-bin-hadoop${BUILT_FOR_HADOOP_VERSION}.tgz" \
  | gunzip \
  | tar x -C /usr/ \
  && mv /usr/$SPARK_PACKAGE $SPARK_HOME \
  && chown -R root:root $SPARK_HOME
ENV PYTHONPATH="$SPARK_HOME/python:$SPARK_HOME/python/build:$PYTHONPATH"
ENV PYTHONPATH="$SPARK_HOME/python/lib/py4j-0.10.4-src.zip:$PYTHONPATH"

# install the R kernel for Jupyter Lab
RUN R -e 'options(spark.install.dir = "/opt")' \
  -e 'sparklyr::spark_install(version = Sys.getenv("SPARK_VERSION"), hadoop_version = Sys.getenv("BUILT_FOR_HADOOP_VERSION"))'

# setting environment variables for pyspark
ENV PYSPARK_PYTHON=/usr/bin/python3 \
  PYSPARK_DRIVER_PYTHON=jupyter \
  PYSPARK_DRIVER_PYTHON_OPTS=lab \
  SPARK_HOME=/opt/spark-${SPARK_VERSION}-bin-hadoop${BUILT_FOR_HADOOP_VERSION}
RUN echo "SPARK_HOME=${SPARK_HOME}" >> /etc/R/Renviron.site

# install python packages
COPY requirements.txt /home/${NB_USER}/requirements.txt
RUN pip3 install -r /home/${NB_USER}/requirements.txt \
  && rm /home/${NB_USER}/requirements.txt

# update R-packages
RUN R -e 'options(HTTPUserAgent = sprintf("R/%s R (%s)", getRversion(), paste(getRversion(), R.version$platform, R.version$arch, R.version$os)))' \
  -e 'radiant.update::radiant.update(repos = "https://rsm-compute-01.ucsd.edu:4242/rsm-msba/__linux__/bionic/latest")'

# Copy the launch script into the image
ADD https://raw.githubusercontent.com/radiant-rstats/docker/master/launch-rsm-msba-spark.sh /opt/launch.sh
RUN chmod 777 /opt/launch.sh

# Configure Hadoop 
COPY core-site.xml $HADOOP_HOME/etc/hadoop/core-site.xml
COPY hdfs-site.xml $HADOOP_HOME/etc/hadoop/hdfs-site.xml
RUN chmod 777 -R $HADOOP_HOME

# install iframe
# RUN jupyter labextension install --debug jupyterlab_iframe
# RUN jupyter serverextension enable --debug --py jupyterlab_iframe

EXPOSE 8080 8787 8989 8765

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]

USER ${NB_USER}
ENV HOME /home/${NB_USER}
