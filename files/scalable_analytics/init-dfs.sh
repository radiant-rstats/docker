#!/bin/bash

$HADOOP_HOME/bin/hdfs namenode -format
echo `${HADOOP_HOME}/bin/hdfs getconf -confKey dfs.datanode.data.dir` | cut -c8- | xargs rm -r
