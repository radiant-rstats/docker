#!/bin/bash

# hdfs namenode -format
# echo `hdfs getconf -confKey dfs.datanode.data.dir` | cut -c8- | xargs rm -r
$HADOOP_HOME/sbin/hadoop-daemon.sh start namenode
$HADOOP_HOME/sbin/hadoop-daemon.sh start datanode
$HADOOP_HOME/sbin/hadoop-daemon.sh start secondarynamenode

