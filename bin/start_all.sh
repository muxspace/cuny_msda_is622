#!/bin/bash

do_error() {
  code=$2
  [ -z "$code" ] && code=1
  
  echo $1
  exit $code
}


[ -z "$HADOOP_HOME" ] && do_error "Abort. Environment variable HADOOP_HOME not set."

$HADOOP_HOME/sbin/hadoop-daemon.sh start namenode
# Start the datanode daemon
$HADOOP_HOME/sbin/hadoop-daemon.sh start datanode

# Start the resourcemanager daemon
$HADOOP_HOME/sbin/yarn-daemon.sh start resourcemanager
# Start the nodemanager daemon
$HADOOP_HOME/sbin/yarn-daemon.sh start nodemanager
