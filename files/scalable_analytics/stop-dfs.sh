#!/bin/bash

echo "Stopping HDFS ..."

hdfs --daemon stop namenode
hdfs --daemon stop datanode
hdfs --daemon stop secondarynamenode


