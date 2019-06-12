#!/bin/bash

# DOWNLOAD_HOST=http://ftp.jaist.ac.jp/pub/apache
DOWNLOAD_HOST=http://apache.40b.nl
KAFKA_VERSION=2.1.1
SCALA_VERSION=2.12
KAFKA_TAR_FILENAME=kafka_${SCALA_VERSION}-${KAFKA_VERSION}

cd /opt
wget -q ${DOWNLOAD_HOST}/kafka/${KAFKA_VERSION}/${KAFKA_TAR_FILENAME}.tgz
tar -xzvf ${KAFKA_TAR_FILENAME}.tgz

wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | apt-key add -
echo "deb https://artifacts.elastic.co/packages/7.x/apt stable main" > /etc/apt/sources.list.d/elastic-7.x.list
apt-get update
DEBIAN_FRONTEND=noninteractive apt-get install filebeat metricbeat default-jre default-jdk -y

filebeat export config -E cloud.id=${CLOUD_ID} -E cloud.auth=${CLOUD_AUTH} -E filebeat.config.modules.path=/etc/filebeat/modules.d/*.yml > /etc/filebeat/filebeat.yml
metricbeat export config -E cloud.id=${CLOUD_ID} -E cloud.auth=${CLOUD_AUTH} -E metricbeat.config.modules.path=/etc/metricbeat/modules.d/*.yml > /etc/metricbeat/metricbeat.yml

filebeat modules enable kafka
metricbeat modules enable kafka

cd /opt/${KAFKA_TAR_FILENAME}
mkdir -p logs

echo server.0=kafka0:2888:3888 >> config/zookeeper.properties
echo server.1=kafka1:2888:3888 >> config/zookeeper.properties
echo server.2=kafka2:2888:3888 >> config/zookeeper.properties
echo initLimit=5 >> config/zookeeper.properties
echo syncLimit=15 >> config/zookeeper.properties

NODE_INDEX=$(hostname | sed 's/kafka//')

sed -i "s/broker.id=0/broker.id=${NODE_INDEX}/" config/server.properties

mkdir -p /tmp/zookeeper
echo ${NODE_INDEX} > /tmp/zookeeper/myid

nohup bin/zookeeper-server-start.sh config/zookeeper.properties > logs/zookeeper.log &
