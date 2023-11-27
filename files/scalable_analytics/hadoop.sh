#!/bin/bash
set -e

# cd /opt/hadoop/
# chmod +x init-dfs.sh
$HADOOP_HOME/init-dfs.sh
$HADOOP_HOME/bin/hdfs --daemon start namenode
$HADOOP_HOME/bin/hdfs --daemon start datanode
$HADOOP_HOME/bin/hdfs --daemon start secondarynamenode

# cd /home
# jupyter lab --ip="0.0.0.0" --port=8888 --no-browser --allow-root --NotebookApp.password_required='False'