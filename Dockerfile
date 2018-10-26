FROM alpine:3.4
MAINTAINER gustavonalle

ENV HADOOP_VERSION 3.1.1

RUN apk add --update \
    findutils curl openjdk8 openssh ruby bash cracklib-words supervisor procps \
    && rm /var/cache/apk/*

RUN sed -i -e "s/bin\/ash/bin\/bash/" /etc/passwd

ENV HADOOP_HOME /usr/local/hadoop

RUN curl "https://archive.apache.org/dist/hadoop/common/hadoop-$HADOOP_VERSION/hadoop-$HADOOP_VERSION.tar.gz" | tar -C /usr/local/ -xz | ln -s /usr/local/hadoop-$HADOOP_VERSION/ /usr/local/hadoop && rm -Rf /usr/local/hadoop/share/doc/

ADD env.sh /etc/profile.d/env.sh

RUN echo "export JAVA_HOME=$(readlink -f /usr/bin/java | sed 's:/jre/bin/java::')" >> $HADOOP_HOME/etc/hadoop/hadoop-env.sh

COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
ADD core-site.xml /usr/local/hadoop/etc/hadoop/core-site.xml
ADD hdfs-site.xml /usr/local/hadoop/etc/hadoop/hdfs-site.xml
ADD mapred-site.xml /usr/local/hadoop/etc/hadoop/mapred-site.xml
ADD yarn-site.xml /usr/local/hadoop/etc/hadoop/yarn-site.xml
ADD start-wrapper.sh /usr/local/hadoop/sbin/start-wrapper.sh

USER root
RUN ssh-keygen -q -N "" -t dsa -f /etc/ssh/ssh_host_dsa_key
RUN ssh-keygen -q -N "" -t rsa -f /etc/ssh/ssh_host_rsa_key
RUN ssh-keygen -q -N "" -t rsa -f /root/.ssh/id_rsa
RUN cp /root/.ssh/id_rsa.pub /root/.ssh/authorized_keys

ADD ssh_config /root/.ssh/config
RUN chmod 600 /root/.ssh/config
RUN chown root:root /root/.ssh/config

RUN sed -i -e 's/JAVA=\$JAVA_HOME\/bin\/java/JAVA=\/usr\/lib\/jvm\/default-jvm\/bin\/java/' /usr/local/hadoop/etc/hadoop/yarn-env.sh
RUN sed -i -e 's/export JAVA_HOME=${JAVA_HOME}/export JAVA_HOME=\/usr\/lib\/jvm\/default-jvm\//' /usr/local/hadoop/etc/hadoop/hadoop-env.sh

RUN /bin/bash -l -c "hdfs namenode -format"

CMD ["/usr/bin/supervisord","-c","/etc/supervisor/conf.d/supervisord.conf"]

EXPOSE 22 80 443 8030 8031 8032 8033 8040 8044 8045 8046 8047 8048 8088 8089 8090 8091 8188 8190 8440 8441 8485 8788 9864 9865 9866 9867 9868 9869 9870 9871 10020 10033 10200 19888 19980 50020  
