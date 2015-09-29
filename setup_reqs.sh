#!/bin/bash
# Run this once to install Hadoop and Spark.

PROJECT_HOME=~/workspace/cuny_msda_is622

echo "Installing dependencies..."
sudo apt-get -y install libreadline5-dev
sudo apt-get -y install libcurl4-openssl-dev libzip-dev libbz2-dev libxml2-dev libpq-dev
sudo apt-get -y install curl
sudo apt-get -y install openjdk-7-jdk default-jdk

sudo apt-add-repository -y 'deb http://cran.rstudio.com/bin/linux/ubuntu vivid/'
sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E084DAB9
sudo apt-add-repository -y ppa:marutter/c2d4u
sudo apt-get update
sudo apt-get install -y --no-install-recommends \
  r-base-dev r-cran-xml r-cran-rcurl r-cran-mass r-cran-codetools \
  r-cran-lattice r-cran-matrix r-cran-nlme r-cran-survival \
  r-cran-boot r-cran-cluster r-cran-foreign r-cran-kernsmooth \
  r-cran-rpart r-cran-class r-cran-nnet r-cran-spatial r-cran-mgcv


echo "Configuring environment..."
cat >> ~/.bashrc <<EOT
export JAVA_HOME=/usr/lib/jvm/java-7-openjdk-amd64/jre
export LD_LIBRARY_PATH=/usr/lib/jvm/java-7-openjdk-amd64/jre/lib/amd64/server:$LD_LIBRARY_PATH
export HADOOP_HOME=$PROJECT_HOME/hadoop-2.7.1
export HADOOP_CMD=$HADOOP_HOME/bin/hadoop
export HADOOP_STREAMING=$HADOOP_HOME/share/hadoop/tools/lib/hadoop-streaming-2.7.1.jar
EOT

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

