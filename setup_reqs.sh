#!/bin/bash
# Run this once to install Hadoop and Spark.

PROJECT_HOME=~/workspace/cuny_msda_is622

# Prerequisites
#sudo apt-get install openjdk-7-jdk
mkdir -p $PROJECT_HOME
cd $PROJECT_HOME

echo "Installing Hadoop..."
wget http://apache.mirrors.spacedump.net/hadoop/common/stable/hadoop-2.7.1.tar.gz
tar zxf hadoop-2.7.1.tar.gz
rm hadoop-2.7.1.tar.gz

echo "Installing Spark..."
wget http://apache.mirrors.ionfish.org/spark/spark-1.4.1/spark-1.4.1-bin-hadoop2.6.tgz
tar zxf spark-1.4.1-bin-hadoop2.6.tgz
rm spark-1.4.1-bin-hadoop2.6.tgz


cat <<EOT

NOTE: To use this installation, you MUST configure Hadoop properly.
This includes:
* permanently set environment variables;
* configure HDFS;
* configure YARN;
* format namenode;
* start all daemons.

See this setup guide [1] for details. Note that RHadoop also requires
1. HADOOP_CMD set to the `hadoop` executable;
2. HADOOP_STREAMING set to the streaming library.


[1] http://www.alexjf.net/blog/distributed-systems/hadoop-yarn-installation-definitive-guide/
EOT

