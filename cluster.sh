#!/bin/bash
set -e

N=${1:-2}
CUR_DIR="$PWD"

function run()
{
  echo "$(docker run -v $CUR_DIR:/usr/local/sample -d -it --name $1 gustavonalle/yarn)"
}

function ip()
{
  echo "$(docker inspect --format '{{ .NetworkSettings.IPAddress }}' $1)" 
}

function exec_cmd()
{
  $(docker exec -it $*)
}

function replace_hosts()
{
  exec_cmd $1 "sed -i s/namenode/$IP_MASTER/g /usr/local/hadoop/etc/hadoop/core-site.xml"
  exec_cmd $1 "sed -i s/localhost/$IP_MASTER/g /usr/local/hadoop/etc/hadoop/yarn-site.xml"
}

function add_slave()
{
  docker exec -it $1 sh -c "echo $2 >> /usr/local/hadoop/etc/hadoop/slaves"
}

function remove_slaves() 
{
 exec_cmd $1 "truncate -s 0 /usr/local/hadoop/etc/hadoop/slaves"
}

echo "Creating a cluster of $N slaves"
docker run -d --name resolvable --hostname resolvable -v /var/run/docker.sock:/tmp/docker.sock -v /etc/resolv.conf:/tmp/resolv.conf mgood/resolvable

IDMASTER=$(run master)

IP_MASTER=$(ip $IDMASTER)

echo "Master created, ip address is $IP_MASTER"

replace_hosts master
remove_slaves master

START=1
for (( c=$START; c<=$N; c++)) 
do
 IDSLAVE=$(run slave$c) 
 replace_hosts slave$c 
 echo  "Slave slave$c configured"
 IP_SLAVE=$(ip $IDSLAVE)
 add_slave master $IP_SLAVE
done

echo "Starting process"
docker exec -it master sh -c -l 'start-dfs.sh'
docker exec -it master sh -c -l 'start-yarn.sh'

echo  "Cluster started. HDFS UI on http://$IP_MASTER:50070/dfshealth.html#tab-datanode"
echo  "YARN UI on http://$IP_MASTER:8088/cluster/nodes"
