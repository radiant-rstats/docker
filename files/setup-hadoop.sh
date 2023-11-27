#!/bin/bash
set -e

if [ ! -d "${HADOOP_HOME}" ]; then
  mkdir $HADOOP_HOME
fi

curl -sL --retry 3 \
  "http://archive.apache.org/dist/hadoop/common/hadoop-$HADOOP_VERSION/hadoop-$HADOOP_VERSION.tar.gz" \
  | gunzip \
  | tar -x --strip-components=1 -C $HADOOP_HOME \
  && rm -rf $HADOOP_HOME/share/doc \
  && chown -R ${NB_USER} $HADOOP_HOME \
  && mkdir "${HADOOP_HOME}/logs"
