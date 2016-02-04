#!/bin/bash

N=${1:-2}
CUR_DIR="$PWD"

docker run -d --name resolvable --hostname resolvable -v /var/run/docker.sock:/tmp/docker.sock -v /etc/resolv.conf:/tmp/resolv.conf mgood/resolvable
docker run -d --name master -h master -e "SLAVES=$N"  gustavonalle/yarn

START=1
for (( c=$START; c<=$N; c++)) 
do
   docker run -d --link master:master -h slave$c gustavonalle/yarn
done

sleep 10

docker exec -it master sh -c -l '/usr/local/hadoop/sbin/start-wrapper.sh'

echo  "Cluster started. HDFS UI on http://master:50070/dfshealth.html#tab-datanode"
echo  "YARN UI on http://master:8088/cluster/nodes"
