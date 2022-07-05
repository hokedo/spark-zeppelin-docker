FROM ubuntu:20.04

ARG ZEPPELIN_VERSION="0.8.2"
ARG SPARK_VERSION="2.4.8"
ARG HADOOP_VERSION="2.7"

LABEL maintainer "mirkoprescha"
LABEL zeppelin.version=${ZEPPELIN_VERSION}
LABEL spark.version=${SPARK_VERSION}
LABEL hadoop.version=${HADOOP_VERSION}

# Install Java and some tools
RUN apt-get -y update &&\
    apt-get -y install software-properties-common && \
    add-apt-repository -y ppa:deadsnakes/ppa &&\
    apt-get -y install curl python3.7 python3-pip openjdk-8-jdk && \
    ln -s /usr/bin/python3.7 /usr/bin/python && \
    pip install pyspark==${SPARK_VERSION}

##########################################
# SPARK
##########################################
ARG SPARK_ARCHIVE=http://artfiles.org/apache.org/spark/spark-${SPARK_VERSION}/spark-${SPARK_VERSION}-bin-hadoop${HADOOP_VERSION}.tgz
RUN mkdir /usr/local/spark &&\
    mkdir /tmp/spark-events    # log-events for spark history server
ENV SPARK_HOME /usr/local/spark

ENV PATH $PATH:${SPARK_HOME}/bin
RUN curl -s ${SPARK_ARCHIVE} | tar -xz -C  /usr/local/spark --strip-components=1

COPY spark-defaults.conf ${SPARK_HOME}/conf/




##########################################
# Zeppelin
##########################################
RUN mkdir /usr/zeppelin &&\
    curl -s http://mirror.softaculous.com/apache/zeppelin/zeppelin-${ZEPPELIN_VERSION}/zeppelin-${ZEPPELIN_VERSION}-bin-all.tgz | tar -xz -C /usr/zeppelin
RUN echo '{ "allow_root": true }' > /root/.bowerrc

ENV ZEPPELIN_PORT 8080
EXPOSE $ZEPPELIN_PORT

ENV ZEPPELIN_HOME /usr/zeppelin/zeppelin-${ZEPPELIN_VERSION}-bin-all
ENV ZEPPELIN_CONF_DIR $ZEPPELIN_HOME/conf
ENV ZEPPELIN_NOTEBOOK_DIR $ZEPPELIN_HOME/notebook

RUN mkdir -p $ZEPPELIN_HOME \
  && mkdir -p $ZEPPELIN_HOME/logs \
  && mkdir -p $ZEPPELIN_HOME/run

RUN cat $ZEPPELIN_CONF_DIR/zeppelin-site.xml.template | sed 's/127.0.0.1/0.0.0.0/g' > $ZEPPELIN_CONF_DIR/zeppelin-site.xml

# my WorkDir
RUN mkdir /work
WORKDIR /work


COPY ./entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]

