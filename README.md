Hadoop Yarn dockerized
====

This is a set of scripts to create a full Hadoop Yarn cluster, each node inside a docker container.

Quick start
---

To create a 3 node YARN cluster, run:

```
bash <(curl -s https://raw.githubusercontent.com/gustavonalle/docker/master/yarn/cluster.sh)
```


Usage
---
Run the script cluster/cluster.sh passing the number of slaves: 

```
./cluster.sh 3
```

After the container creation the script will print the master ip address.

http://master:50070 for the HDFS console
http://master: 8088 for the YARN UI


Details
---

Each container is based on fedora 21, java 1.8. 
The master container will run the namenode, secondary namenode, and the resource manager. 
Each slave container will run the data node and the node manager. 
