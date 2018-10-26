#!/bin/bash

IP=$(ip addr list eth0 |grep "inet " |cut -d' ' -f6|cut -d/ -f1)
truncate -s 0 /usr/local/hadoop/etc/hadoop/slaves
sed -i s/namenode/$IP/g /usr/local/hadoop/etc/hadoop/core-site.xml
sed -i s/localhost/$IP/g /usr/local/hadoop/etc/hadoop/yarn-site.xml
START=1
for (( c=$START; c<=$SLAVES; c++))
do
   ssh slave$c "sed -i s/namenode/$IP/g /usr/local/hadoop/etc/hadoop/core-site.xml"
   ssh slave$c "sed -i s/localhost/$IP/g /usr/local/hadoop/etc/hadoop/yarn-site.xml"
   echo slave$c >> /usr/local/hadoop/etc/hadoop/workers
done

/usr/local/hadoop/sbin/start-dfs.sh
/usr/local/hadoop/sbin/start-yarn.sh
