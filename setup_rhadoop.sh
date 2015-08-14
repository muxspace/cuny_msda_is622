#!/bin/bash
PROJECT_HOME=~/workspace/cuny_msda_is622

do_error() {
  [ -n "$2" ] && echo $2
  exit $1
}

# HADOOP_CMD must be set prior to installing
[ -z "$HADOOP_CMD" ] && do_error 1 "Missing HADOOP_CMD"
[ -z "$HADOOP_STREAMING" ] && do_error 1 "Missing HADOOP_STREAMING"

# Install RHadoop packages
Rscript --vanilla -e "library(devtools)" \
  -e "install_github('RevolutionAnalytics/quickcheck/pkg')" \
  -e "install_github('RevolutionAnalytics/rhdfs/pkg')" \
  -e "install_github('RevolutionAnalytics/rmr2/pkg')"
#install_github('RevolutionAnalytics/rhbase/pkg')

