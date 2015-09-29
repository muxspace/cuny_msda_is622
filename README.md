# Overview
This script sets up a complete Hadoop and Spark environment for
a debian-based Linux system. It also installs the associated R bindings
to run these systems directly from R. Note that it assumes a new
environment, so if you have an existing Linux system, you should
review the script and comment out sections you do not want run.

If you don't have a Linux machine available, your options are to either
install Linux on a virtual machine or use a hosted cloud provider. I 
recommend installing the 
[Ubuntu 15.04 server](http://releases.ubuntu.com/15.04/ubuntu-15.04-server-amd64.iso).

# RHadoop
## Installation

### Step 1: Install Hadoop and Spark
The script `setup_reqs.sh installs a bunch of dependencies and`downloads Hadoop and 
Spark. If you have a pre-existing system, check the dependencies to ensure there are
no conflicts with your configuration.

```bash
./setup_reqs.sh
```

Installation follows the procedure for a single, local instance
described in this
[guide](http://www.alexjf.net/blog/distributed-systems/hadoop-yarn-installation-definitive-guide/).
That tutorial recommends `~/Programs` as the installation,
while the script uses `~/workspace/cuny_msda_is622`. Note this location.

The script now configures your environment with default environment variables.
If you go off script or have a different configuration, you may need to
update these.

Now configure HDFS and YARN as described in the guide. You will need to
change the paths in `hdfs-site.xml`. The other two can be used verbatim,
with the caveat that your machine has specs greater than or equal to 
the reference machine.

### Step 2: Start Hadoop and YARN
Be sure that your environment variables are properly set. This will normally
happen at log in, but if you are in the same shell as where `setup_reqs.sh`
was run, you'll need to manually load the `~/.bashrc` via
```bash
$HADOOP_HOME/bin/hdfs namenode -format
```

Initialize the name node. Only do this once.
```bash
$HADOOP_HOME/bin/hdfs namenode -format
```

Now start all daemons.
```bash
cd ~/workspace/cuny_msda_is622
./bin/start_all.sh
```

This will start the Hadoop daemons and the resource managers. Behind the
scenes this script is simply making the below commands.
```bash
# Start the namenode daemon
$HADOOP_HOME/sbin/hadoop-daemon.sh start namenode
# Start the datanode daemon
$HADOOP_HOME/sbin/hadoop-daemon.sh start datanode

# Start the resourcemanager daemon
$HADOOP_HOME/sbin/yarn-daemon.sh start resourcemanager
# Start the nodemanager daemon
$HADOOP_HOME/sbin/yarn-daemon.sh start nodemanager
```

### Step 3: Install RHadoop
At a minimum, the environment variables `HADOOP_CMD` and `HADOOP_STREAMING`
need to be exported. These point to the Hadoop installation directory
and streaming jar, respectively. The streaming jar is what enables Hadoop
to speak to R. These have already been appended to your `.bashrc` in
Step 1.


Run the bash script `setup_rhadoop.sh` to install the necessary R libraries.
You need `devtools` installed beforehand.
```bash
./setup_rhadoop.sh
```
This will install Revolution Analytics' packages for `rhdfs` and `rmr2`.
Support for `rhbase` requires additional dependencies,
and for the sake of simplicity, it is omitted.

## Verify RHadoop Integration
### Step 1: Sanity check
First, do a simple sanity check to verify that R can speak to Hadoop.
This process is described in more detail in 
[this tutorial](https://github.com/RevolutionAnalytics/rmr2/blob/master/docs/tutorial.md).

```R
library(rmr2)
library(rhdfs)
hdfs.init()

small.ints <- to.dfs(1:1000)
fs.ptr <- mapreduce(input=small.ints, map=function(k,v) cbind(v,v^2))
result <- from.dfs(fs.ptr)
head(result$val)
```

### Step 2: Read and process file
Download some data.

```bash
cd ~/workspace/cuny_msda_is622
mkdir data
cd data
wget http://download.bls.gov/pub/time.series/sm/sm.data.1.AllData
```

Now put it into Hadoop.
```bash
hadoop fs -mkdir -p /bls/employment
hadoop fs -copyFromLocal sm.data.1.AllData /bls/employment/state_metro.tsv
```

At this point, we have a raw TSV in HDFS. Before processing it, the TSV
needs to be in a format that RHadoop can work with.

```R
tsv.format <- make.input.format("csv", sep="\t")
csv.format <- make.output.format("csv", sep=",")
input <- '/bls/employment/state_metro.tsv'
output <- '/bls/employment/state_metro_1.csv'
out.ptr <- mapreduce(input, input.format=tsv.format, 
  output=output, output.format=csv.format,
  map=function(k,v) {
    keyval(v[[1]], 
      cbind(yearmonth=sprintf("%s.%s", v[[2]],v[[3]]), value=v[[4]]))
  },
  reduce=function(k,v) {
    keyval(k, length(v))
  })
result <- from.dfs(out.ptr, format="csv")
```
https://github.com/RevolutionAnalytics/rmr2/blob/master/docs/getting-data-in-and-out.md


### Another Example
Iris
Export as CSV

Read as CSV

## Other Commands
Here are some other commands that you will find useful.

### Stop Hadoop
$HADOOP_HOME/sbin/hadoop-daemon.sh stop datanode
$HADOOP_HOME/sbin/hadoop-daemon.sh stop namenode


# Troubleshooting

## java.io.IOException: Incompatible clusterIDs
Somehow your namenode and datanode got assigned different cluster IDs. You can
edit the Hadoop configuration to make the two IDs match. First look at the IDs:
```bash
cd $HADOOP_HOME
grep clusterID hdfs/*/current/VERSION
```
If these do not match, then:
+ stop the datanode and namenode;
+ copy the cluster ID from one file;
+ edit the other file and replace the cluster ID;
+ restart the namenode and datanode.

In the `$HADOOP_HOME/logs` directory, verify that the datanode and namenode log
files do not have any FATAL errors.

