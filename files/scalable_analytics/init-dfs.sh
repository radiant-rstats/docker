#!/bin/bash

mkdir -p /tmp/hadoop-root/dfs/name
mkdir -p /tmp/hadoop-jovyan/dfs/data
sed -i '$a\# Add the line for suppressing the NativeCodeLoader warning \nlog4j.logger.org.apache.hadoop.util.NativeCodeLoader=ERROR,console' /$HADOOP_HOME/etc/hadoop/log4j.properties
$HADOOP_HOME/bin/hdfs namenode -format -force
echo `${HADOOP_HOME}/bin/hdfs getconf -confKey dfs.datanode.data.dir` | cut -c8- | xargs rm -r