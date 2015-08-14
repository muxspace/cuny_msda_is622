# Overview

# RHadoop
## Installation
### Step 1: Install Hadoop and Spark
The script `setup_reqs.sh`downloads Hadoop and Spark.

```bash
./setup_reqs.sh
```

Installation follows the procedure for a single, local instance
described in this
[guide](http://www.alexjf.net/blog/distributed-systems/hadoop-yarn-installation-definitive-guide/).
That tutorial recommends `~/Programs` as the installation,
while the script uses `~/workspace/cuny_msda_is622`. Note this location.

### Step 2: Configure RHadoop
Hadoop needs to be configured to run properly. Add the following line to
your `.bashrc`. Also make sure you have `JAVA_HOME` exported.

```bash
export HADOOP_HOME=~/workspace/cuny_msda_is622/hadoop-2.7.1
```

Now configure HDFS and YARN as described in the guide. You will need to
change the paths in `hdfs-site.xml`. The other two can be used verbatim,
with the caveat that your machine has specs greater than or equal to 
the reference machine.

### Step 3: Start Hadoop and YARN
Initialize the name node.

```bash
$HADOOP_HOME/bin/hdfs namenode -format
```

Now start all daemons.
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

### Step 4: Install RHadoop
At a minimum, the environment variables `HADOOP_CMD` and `HADOOP_STREAMING`
need to be exported. These point to the Hadoop installation directory
and streaming jar, respectively. The streaming jar is what enables Hadoop
to speak to R. This can be appended to your `.bashrc`.

```bash
export HADOOP_CMD=$HADOOP_HOME/bin/hadoop
export HADOOP_STREAMING=$HADOOP_HOME/share/hadoop/tools/lib/hadoop-streaming-2.7.1.jar
```

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
result <- from.dfs(out.ptr)
```
https://github.com/RevolutionAnalytics/rmr2/blob/master/docs/getting-data-in-and-out.md



Iris
Export as CSV

Read as CSV

