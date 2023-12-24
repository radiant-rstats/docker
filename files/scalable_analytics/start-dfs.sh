#!/bin/bash

echo "Starting HDFS ..."

hdfs --daemon start namenode
hdfs --daemon start datanode
hdfs --daemon start secondarynamenode