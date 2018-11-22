FROM vnijs/rsm-msba:latest

MAINTAINER Vincent Nijs "radiant@rady.ucsd.edu"
ENV DEBIAN_FRONTEND noninteractive

## installing java
RUN apt-get -y update \
  && apt-get install --no-install-recommends -y openjdk-8-jre-headless openjdk-8-jdk-headless ca-certificates-java \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/* \
  && R CMD javareconf

## don't upgrade to 2.4.0 yet as it requires mesos and there is no repo for ubuntu 18.04 yet
ENV SPARK_VERSION=2.3.2
ENV HADOOP_VERSION=2.7

## install the R kernel for Jupyter Lab
RUN R -e 'options(spark.install.dir = "/opt")' \
      -e 'sparklyr::spark_install(version = Sys.getenv("SPARK_VERSION"), hadoop_version = Sys.getenv("HADOOP_VERSION"))'

## setting environment variables for pyspark
ENV PYSPARK_PYTHON=/usr/bin/python3
ENV PYSPARK_DRIVER_PYTHON=jupyter
ENV PYSPARK_DRIVER_PYTHON_OPTS=lab
ENV SPARK_HOME=/opt/spark-${SPARK_VERSION}-bin-hadoop${HADOOP_VERSION}
RUN echo "SPARK_HOME=${SPARK_HOME}" >> /etc/R/Renviron.site

## install python packages
COPY py_requirements.txt /home/rstudio/py_requirements.txt
RUN pip3 install --upgrade -r /home/rstudio/py_requirements.txt

## update R-packages
RUN R -e 'radiant.update::radiant.update()'

EXPOSE 80 8787 8989

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
