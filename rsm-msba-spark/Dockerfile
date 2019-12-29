FROM vnijs/rsm-msba:latest
LABEL Vincent Nijs "radiant@rady.ucsd.edu"

ARG DOCKERHUB_VERSION_UPDATE
ENV DOCKERHUB_VERSION=${DOCKERHUB_VERSION_UPDATE}

ENV DEBIAN_FRONTEND=noninteractive
# installing java
RUN apt-get -y update \
  && apt-get install --no-install-recommends -y openjdk-8-jre-headless openjdk-8-jdk-headless ca-certificates-java \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/* \
  && R CMD javareconf

# don't upgrade to 2.4.0 yet as it requires mesos and there is no repo for ubuntu 18.04 yet
ENV SPARK_VERSION=2.3.2 \
  HADOOP_VERSION=2.7

# install the R kernel for Jupyter Lab
RUN R -e 'options(spark.install.dir = "/opt")' \
  -e 'sparklyr::spark_install(version = Sys.getenv("SPARK_VERSION"), hadoop_version = Sys.getenv("HADOOP_VERSION"))'

# setting environment variables for pyspark
ENV PYSPARK_PYTHON=/usr/bin/python3 \
  PYSPARK_DRIVER_PYTHON=jupyter \
  PYSPARK_DRIVER_PYTHON_OPTS=lab \
  SPARK_HOME=/opt/spark-${SPARK_VERSION}-bin-hadoop${HADOOP_VERSION}
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

EXPOSE 8080 8787 8989 8765

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]

# USER ${NB_USER}
ENV HOME /home/${NB_USER}
