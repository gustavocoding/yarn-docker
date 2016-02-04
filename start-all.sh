IP=$(ip a s | sed -ne '/127.0.0.1/!{s/^[ \t]*inet[ \t]*\([0-9.]\+\)\/.*$/\1/p}')
truncate -s 0 /usr/local/hadoop/etc/hadoop/slaves
sed -i s/namenode/$IP/g /usr/local/hadoop/etc/hadoop/core-site.xml
sed -i s/localhost/$IP/g /usr/local/hadoop/etc/hadoop/yarn-site.xml
START=1
for (( c=$START; c<=$SLAVES; c++))
do
   ssh slave$c "sed -i s/namenode/$IP/g /usr/local/hadoop/etc/hadoop/core-site.xml"
   ssh slave$c "sed -i s/localhost/$IP/g /usr/local/hadoop/etc/hadoop/yarn-site.xml"
   echo slave$c >> /usr/local/hadoop/etc/hadoop/slaves
done

/usr/local/hadoop/sbin/start-dfs.sh
/usr/local/hadoop/sbin/start-yarn.sh
