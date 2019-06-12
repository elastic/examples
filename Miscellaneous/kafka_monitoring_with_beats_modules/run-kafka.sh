#!/bin/bash

KAFKA_VERSION=2.1.1
SCALA_VERSION=2.12
KAFKA_TAR_FILENAME=kafka_${SCALA_VERSION}-${KAFKA_VERSION}

cd /opt/${KAFKA_TAR_FILENAME}

bin/kafka-server-stop.sh
nohup bin/kafka-server-start.sh config/server.properties > /dev/null &

if [ "$(hostname)" == "kafka0" ]; then
  sleep 10
  bin/kafka-topics.sh --create --zookeeper localhost:2181 --replication-factor 2 --partitions 3 --topic beats

  filebeat setup -e
  metricbeat setup -e
fi

service filebeat start
service metricbeat start
