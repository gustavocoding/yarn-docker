#!/bin/bash

docker run -d --name resolvable --hostname resolvable -v /var/run/docker.sock:/tmp/docker.sock -v /etc/resolv.conf:/tmp/resolv.conf mgood/resolvable
docker run -d --name master -h master -e "SLAVES=2" gustavonalle/yarn
docker run -d --link master:master -h slave1 gustavonalle/yarn
docker run -d --link master:master -h slave2 gustavonalle/yarn
docker exec -it master sh -c -l '/usr/local/hadoop/sbin/start-all.sh'

echo  "Cluster started. HDFS UI on http://master:50070/dfshealth.html#tab-datanode"
echo  "YARN UI on http://master:8088/cluster/nodes"
